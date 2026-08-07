function nix --wraps nix
    if test $argv[1] = develop; and test -z $argv[2]
        nix develop --command fish
    else if test $argv[1] = update
        nix flake update --flake ~/.config/nixos
    else if test $argv[1] = switch
        echo "Switching to $NIXOS_HOST"
        sudo nixos-rebuild switch --flake ~/.config/nixos#$NIXOS_HOST
    else if test $argv[1] = boot
        sudo nixos-rebuild boot --flake ~/.config/nixos#$NIXOS_HOST
    else if test $argv[1] = gc
        nix-env --delete-generations +3
        nix-collect-garbage
    else
        command nix $argv
    end
end
