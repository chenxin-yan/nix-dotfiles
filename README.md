# dotfiles

Nix flake for my Macs (nix-darwin) and NixOS machines, with Home Manager for everything user-level. Built with [flake-parts](https://flake.parts) in the [dendritic pattern](https://github.com/mightyiam/dendritic) and themed with Catppuccin Mocha.

## Layout

```
flake.nix            inputs; loads every module under modules/
justfile             everyday commands (`just --list`)
modules/
├── flake/           plumbing: the `features` and `hosts` options, system builders
├── hosts/           one file (or directory) per machine
├── profiles/        bundles of features: base, development, desktop, mac, server, …
└── features/        everything a host can select: core, cli, dev, apps, desktop, system
scripts/             onboarding wizard and the helpers behind the justfile
```

## How it works

- Every `.nix` file under `modules/` is a flake-parts module, loaded automatically by [import-tree](https://github.com/denful/import-tree). Paths containing `/_` are skipped; use them for assets and helpers.
- A **feature** (`features.<name>`) keeps its `darwin`, `nixos` and `homeManager` parts in one file, plus the other features it `includes`. There are no enable flags: a feature is on when a host selects it, directly or through a profile.
- A **host** (`hosts.<name>`) sets its platform, login, selected features and any machine-only config. The name is both the flake target and the hostname.

```nix
# modules/hosts/work-macbook.nix
hosts.work-macbook = {
  system = "aarch64-darwin";
  login = "chenxin-yan";
  features = with config.features; [ mac ];
  exclude = with config.features; [ podman ]; # an exception to the profile
  configuration = { /* nix-darwin: state version, account */ };
  home = { /* Home Manager: machine-only packages */ };
};
```

The machinery is in `modules/flake/features.nix` and `modules/flake/hosts.nix`. To see what a host runs: `nix eval .#hosts.<name>.features --json`.

## Setup

You need Nix with flakes and Git. On macOS you also need the Xcode Command Line Tools. Don't install Homebrew yourself: nix-homebrew manages it.

```sh
git clone https://github.com/chenxin-yan/nix-dotfiles ~/dotfiles
cd ~/dotfiles
bash scripts/onboard.sh
```

The wizard supports macOS and an already-installed NixOS. It writes `modules/hosts/<name>/` for a new machine (keeping NixOS's own `/etc/nixos` config under `_installed/`), then evaluates, builds and activates it. It asks before every change; the stages are described at the top of `scripts/onboard.sh`. Commit the new host files afterwards.

To bring up a Mac that is already registered, before `just` exists:

```sh
sudo nix --extra-experimental-features 'nix-command flakes' run --inputs-from ~/dotfiles \
  nix-darwin#darwin-rebuild -- switch --flake ~/dotfiles#<target>
```

Then set up by hand what Nix doesn't manage: SSH keys (`~/.ssh/id_ed25519`), `gh auth login`, 1Password sign-in, and device approval in the Syncthing UI (`http://localhost:8384`).

## Daily use

| Command                | What it does                                                          |
| ---------------------- | --------------------------------------------------------------------- |
| `just switch`          | Rebuild and activate this machine (checks it matches its host entry)  |
| `just switch <target>` | Same, once, for a machine whose hostname doesn't match its target yet |
| `just update`          | Update flake inputs                                                   |
| `just update-pins`     | Update pinned `fetchFrom*` sources                                    |
| `just clean`           | Garbage-collect with this host's retention, then optimise the store   |
| `just fmt`             | Format Nix files                                                      |

Worth knowing:

- **`git add` new files before switching.** Git-backed flakes don't see untracked files.
- **Homebrew removes what isn't declared.** Activation runs with `cleanup = "zap"`, so declare casks in the feature they belong to (`darwin.homebrew.casks`).
- **Some config is linked, not copied.** Edits to the Neovim config (`modules/features/core/nvim/config/`) and the shell scripts behind the zsh aliases (`modules/features/core/zsh/scripts/`) apply without a rebuild.
- **`nix flake check` only evaluates the NixOS hosts.** A broken Mac config shows up at `just switch`.

## Making changes

- **Add a feature**: create a file under `modules/features/<group>/` that sets `features.<name>.<part>`, then add it to a profile's `includes` or a host's `features`.
- **Leave a feature out on one host**: add it to that host's `exclude`.
- **Add a machine**: run the wizard, or copy an existing host file. Never reuse another machine's hardware configuration.
- **Find where something is configured**: `features.<name>` is defined in the file of that name under `modules/features/` (e.g. `features.syncthing` → `cli/syncthing.nix`). Theme is `core/theme.nix`; shared paths and environment variables are in `core/paths.nix`.
