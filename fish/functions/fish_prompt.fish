function fish_prompt_loading_indicator
    set -l normal (set_color --reset)
    set -l status_color (set_color cyan)
    set -l cwd_color (set_color green)

    set -q fish_prompt_pwd_dir_length
    or set -lx fish_prompt_pwd_dir_length 0

    set -l suffix ' ❯'

    echo -s -n \n $cwd_color (prompt_pwd)
    echo
    echo -n -s $status_color $suffix ' ' $normal
end

starship init fish --print-full-init | source
