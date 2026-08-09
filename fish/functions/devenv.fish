function devenv --wraps devenv
    if test $argv[1] = init; and test -z $argv[2]
        command devenv init --include-envrc
    else
        command devenv $argv
    end
end
