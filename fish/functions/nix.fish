function nix --wraps nix
    if test $argv[1] = develop; and test -z $argv[2]
        nix develop --command fish
    else if test $argv[1] = dev; and test -z $argv[2]
        set nixpkgs_ref (
            nix flake metadata --json ~/.config/nixos |
            jq -r '.locks.nodes.nixpkgs.locked |
            "github:\(.owner)/\(.repo)/\(.rev)"'
        )
        echo "Using nixpkgs $nixpkgs_ref"
        nix develop --override-input nixpkgs "$nixpkgs_ref" --command fish 
    else if test $argv[1] = update
        nix flake update --flake ~/.config/nixos
    else if test $argv[1] = switch
        echo "Switching to $NIXOS_HOST"
        sudo nixos-rebuild switch --flake ~/.config/nixos#$NIXOS_HOST
    else if test $argv[1] = boot
        echo "Booting $NIXOS_HOST"
        sudo nixos-rebuild boot --flake ~/.config/nixos#$NIXOS_HOST
    else if test $argv[1] = test
        echo "Testing $NIXOS_HOST"
        sudo nixos-rebuild test --flake ~/.config/nixos#$NIXOS_HOST
    else if test $argv[1] = gc
        nix-env --delete-generations +3
        sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations +3
        sudo nix-collect-garbage
    else
        command nix $argv
    end
end
