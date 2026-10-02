## Prerequisites

Install [Homebrew](https://brew.sh), then:
```bash
brew install just
```

Clone the configuration into `/etc/nix-darwin`:
```bash
sudo mkdir -p /etc/nix-darwin
```

```bash
sudo chown $(id -nu):$(id -ng) /etc/nix-darwin
```

```bash
git clone  https://github.com/NMJlam/nix-darwin-flake.git /etc/nix-darwin
```

```bash
cd /etc/nix-darwin
```

# Getting Started

To install nix and apply the configuration:
```bash
just setup
```

To apply configuration changes:
```bash
just switch
```

To check the configuration builds without applying it:
```bash
just build
```

To pull the latest configuration from the remote and apply it:
```bash
just sync
```

To update nixpkgs and nix-darwin to their latest versions, apply them, and commit the new `flake.lock`:
```bash
just update
```

To undo the last switch:
```bash
just rollback
```
