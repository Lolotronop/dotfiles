function __prompt_git_info --argument-names dir
    git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>/dev/null
    or return

    set -l normal (set_color --reset)
    set -l branch_color (set_color brpurple)
    set -l status_color (set_color bryellow)
    set -l state_color (set_color brred)

    set -l branch ""
    set -l upstream ""
    set -l oid ""
    set -l ahead 0
    set -l behind 0
    set -l stashes 0
    set -l conflicted 0
    set -l deleted 0
    set -l renamed 0
    set -l modified 0
    set -l staged 0
    set -l untracked 0

    for line in (git -C "$dir" status --porcelain=v2 --branch --show-stash 2>/dev/null)
        switch $line
            case '# branch.head *'
                set branch (string replace '# branch.head ' '' -- $line)
            case '# branch.oid *'
                set oid (string replace '# branch.oid ' '' -- $line)
            case '# branch.upstream *'
                set upstream (string replace '# branch.upstream ' '' -- $line)
            case '# branch.ab *'
                set -l ab (string match -r '^# branch\.ab \+([0-9]+) -([0-9]+)$' -- $line)
                if test (count $ab) -ge 3
                    set ahead $ab[2]
                    set behind $ab[3]
                end
            case '# stash *'
                set stashes (string replace '# stash ' '' -- $line)
            case '? *'
                set untracked (math $untracked + 1)
            case 'u *'
                set conflicted (math $conflicted + 1)
            case '1 *' '2 *'
                set -l xy (string sub -s 3 -l 2 -- $line)
                set -l x (string sub -s 1 -l 1 -- $xy)
                set -l y (string sub -s 2 -l 1 -- $xy)

                if test "$x" != "."
                    set staged (math $staged + 1)
                end
                if test "$y" != "."
                    set modified (math $modified + 1)
                end
                if contains -- D $x $y
                    set deleted (math $deleted + 1)
                end
                if test "$x" = R
                    set renamed (math $renamed + 1)
                end
        end
    end

    if test -z "$branch"; or test "$branch" = detached
        if test -n "$oid"; and test "$oid" != "(initial)"
            set branch (string sub -l 7 -- $oid)
        else
            set branch (git -C "$dir" rev-parse --short HEAD 2>/dev/null)
        end
    end

    set -l git "$branch_color$branch"

    set -l git_dir (git -C "$dir" rev-parse --git-dir 2>/dev/null)
    if test -d "$git_dir/rebase-merge"; or test -d "$git_dir/rebase-apply"
        set git $git' '$state_color'(REBASING)'
    else if test -f "$git_dir/MERGE_HEAD"
        set git $git' '$state_color'(MERGING)'
    else if test -f "$git_dir/CHERRY_PICK_HEAD"
        set git $git' '$state_color'(CHERRY-PICKING)'
    else if test -f "$git_dir/REVERT_HEAD"
        set git $git' '$state_color'(REVERTING)'
    else if test -f "$git_dir/BISECT_LOG"
        set git $git' '$state_color'(BISECTING)'
    end

    set -l bits
    if test $conflicted -gt 0; set -a bits "=$conflicted"; end
    if test $stashes -gt 0; set -a bits "\$$stashes"; end
    if test $deleted -gt 0; set -a bits "✘$deleted"; end
    if test $renamed -gt 0; set -a bits "»$renamed"; end
    if test $modified -gt 0; set -a bits "!$modified"; end
    if test $staged -gt 0; set -a bits "+$staged"; end
    if test $untracked -gt 0; set -a bits "?$untracked"; end

    if test $ahead -gt 0; and test $behind -gt 0
        set -a bits "⇕⇡$ahead⇣$behind"
    else
        if test $ahead -gt 0; set -a bits "⇡$ahead"; end
        if test $behind -gt 0; set -a bits "⇣$behind"; end
    end

    if test (count $bits) -gt 0
        set git $git' '$status_color(string join ' ' -- $bits)
    end

    echo -n -s $git $normal
end

function __prompt_render --argument-names last_status git
    set -l normal (set_color --reset)
    set -l status_color (set_color brcyan)
    set -l cwd_color (set_color green)
    set -l prompt_status ""

    set -q fish_prompt_pwd_dir_length
    or set -lx fish_prompt_pwd_dir_length 0

    set -l suffix ' ❯'
    if functions -q fish_is_root_user; and fish_is_root_user
        if set -q fish_color_cwd_root
            set cwd_color (set_color $fish_color_cwd_root)
        end
        set suffix '#'
    end

    if test $last_status -ne 0
        set status_color (set_color $fish_color_error)
        set prompt_status $status_color "[$last_status]" $normal
    end

    echo -s -n \n $cwd_color (prompt_pwd)
    if test -n "$git"
        echo -s -n ' ' $git
    end
    echo
    echo -n -s $status_color $suffix ' ' $normal
end

# This is the synchronous first pass: it must not call git.
function fish_prompt_loading_indicator
    set -l last_status $status
    __prompt_render $last_status ""
end

# fish-async-prompt runs this complete second pass in a background fish.
function fish_prompt
    set -l last_status $status
    set -l git (__prompt_git_info "$PWD")
    __prompt_render $last_status "$git"
end
