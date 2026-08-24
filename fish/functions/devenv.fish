function devenv --wraps devenv
    if test $argv[1] = init; and test -z $argv[2]
        command devenv init --include-envrc
    else if test $argv[1] = shell; and test -z $argv[2]
        # TODO: remove this resolves https://github.com/cachix/devenv/issues/2793
        command devenv shell --no-reload
    else
        command devenv $argv
    end
end
