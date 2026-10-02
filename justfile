config := "macbook"
flake := justfile_directory() + "#" + config
nix := "/nix/var/nix/profiles/default/bin/nix"

# First-time setup on a fresh Mac
setup: install-nix bootstrap

# Install Nix if it isn't already installed
install-nix:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -x "{{nix}}" ]; then
        echo "Nix already installed, skipping."
        exit 0
    fi
    curl --proto '=https' --tlsv1.2 -sSfL -o /tmp/install-nix https://nixos.org/nix/install
    sh /tmp/install-nix --daemon --yes
    rm /tmp/install-nix

# First nix-darwin activation
bootstrap:
    #!/usr/bin/env bash
    set -euo pipefail
    # Move aside files nix-darwin wants to manage (only real files, not its own symlinks)
    for f in /etc/nix/nix.conf /etc/bashrc /etc/zshrc; do
        if [ -f "$f" ] && [ ! -L "$f" ] && [ ! -e "$f.before-nix-darwin" ]; then
            echo "Moving $f -> $f.before-nix-darwin"
            sudo mv "$f" "$f.before-nix-darwin"
        fi
    done
    sudo {{nix}} --extra-experimental-features 'nix-command flakes' \
        run nix-darwin/master#darwin-rebuild -- switch --flake {{flake}}
    echo "Done. Quit and reopen your terminal to pick up the new environment."

# Apply config changes
switch:
    sudo darwin-rebuild switch --flake {{flake}}

# Pull the latest config from the remote and apply it
sync:
    git pull --ff-only
    just switch

# Check the config builds without activating it
build:
    darwin-rebuild build --flake {{flake}}

# Pull, bump pinned inputs, apply, then commit and push the new lock file
update:
    #!/usr/bin/env bash
    set -euo pipefail
    git pull --ff-only
    nix flake update
    just switch
    if git diff --quiet flake.lock; then
        echo "flake.lock unchanged, nothing to commit."
    else
        git commit -m "Update flake inputs" flake.lock
        git push
    fi

# Undo the last switch
rollback:
    sudo darwin-rebuild --rollback
