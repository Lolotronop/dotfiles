# this is very much based on https://github.com/acomagu/fish-async-prompt

status is-interactive
or exit

set -g __prompt_tmp (mktemp -d)
set -g __prompt_gen 0
set -g __prompt_branch ""


function __prompt_async
    set -g __prompt_gen (math $__prompt_gen + 1)

    set -l gen $__prompt_gen
    set -l dir $PWD
    set -l file "$__prompt_tmp/$gen"

    begin
        git -C "$dir" branch --show-current 2>/dev/null >$file
        kill -s SIGUSR1 $fish_pid 2>/dev/null
    end &
end


function __prompt_repaint --on-signal SIGUSR1
    set -l file "$__prompt_tmp/$__prompt_gen"

    if test -f "$file"
        set -g __prompt_branch (string collect <"$file")
        commandline -f repaint >/dev/null 2>/dev/null
    end
end


function __prompt_on_pwd --on-variable PWD
    # The old branch is no longer relevant.
    set -g __prompt_branch ""

    __prompt_async
end


function __prompt_on_exec --on-event fish_postexec
    __prompt_async
end


function __prompt_start --on-event fish_prompt
    functions -e __prompt_start
    __prompt_async
end

function fish_prompt
        set -l last_status $status
        set -l normal (set_color --reset)
        set -l status_color (set_color brcyan)
        set -l cwd_color (set_color $fish_color_cwd)
        set -l vcs_color (set_color brpurple)
        set -l prompt_status ""

        set -q fish_prompt_pwd_dir_length
        or set -lx fish_prompt_pwd_dir_length 0

        # Color the prompt differently when we're root
        set -l suffix ' ❯'
        if functions -q fish_is_root_user; and fish_is_root_user
                if set -q fish_color_cwd_root
                        set cwd_color (set_color $fish_color_cwd_root)
                end
                set suffix '#'
        end

        # Color the prompt in red on error
        if test $last_status -ne 0
                set status_color (set_color $fish_color_error)
                set prompt_status $status_color "[" $last_status "]" $normal
        end

        echo -s -n \n $cwd_color (prompt_pwd)
        if test -n "$__prompt_branch"
                echo -s -n ' ' (set_color brpurple) '' $__prompt_branch
        end
        echo
        echo -n -s $status_color $suffix ' ' $normal
end

function __prompt_cleanup --on-event fish_exit
    rm -rf "$__prompt_tmp"
end
