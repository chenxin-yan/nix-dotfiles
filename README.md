# dotfiles

Nix flake for my Macs (nix-darwin) and NixOS machines, with Home Manager for everything user-level. Built with [flake-parts](https://flake.parts) in the [dendritic pattern](https://github.com/mightyiam/dendritic) and themed with Catppuccin Mocha.

- [Layout](#layout)
- [How it works](#how-it-works)
- [Setup](#setup)
- [Daily use](#daily-use)
- [Making changes](#making-changes)

## Layout

```
flake.nix            inputs; loads every module under modules/
justfile             everyday commands (`just --list`)
modules/
├── flake/           plumbing: the `features` and `hosts` options, system builders
├── hosts/           one file (or directory) per machine
├── profiles/        what hosts select: platforms/, roles/, and the blocks/ they share
└── features/        everything a host can have, grouped by kind
scripts/             onboarding wizard and the helpers behind the justfile
```

Under `features/`: `shell/`, `editor/`, `vcs/`, `agents/`, `tools/` (command-line tools), `languages/`, `apps/` (GUI apps), `desktop/` (window, bar and input integration) and `system/` (services and policy). `paths.nix` and `theme.nix` sit at the top because many features use them. Folders are only for navigation: moving a file never changes what a host gets. Use a single `.nix` file unless a feature has assets or helpers to keep beside it.

Every `.nix` file under `modules/` is a flake-parts module, loaded automatically by [import-tree](https://github.com/denful/import-tree). Paths containing `/_` are skipped; use them for assets and helpers.

## How it works

### Features

A feature (`features.<name>`) keeps its `darwin`, `nixos` and `homeManager` parts in one file, plus the other features it `includes`. There are no enable flags: a feature is on when a host selects it, directly or through a profile.

### Profiles

Profiles are features that select other features and hold no settings of their own, except OS-only settings in a platform. A host is its platform plus any combination of roles:

| Type                  | Profiles                           | Rule                                                        |
| --------------------- | ---------------------------------- | ----------------------------------------------------------- |
| `profiles/platforms/` | `darwin`, `nixos`                  | Added from `system`; may hold settings only that OS has     |
| `profiles/roles/`     | `server`, `workstation`, `desktop` | Any combination: runs unattended, I work on it, I sit at it |
| `profiles/blocks/`    | `base`, `fleet`, `development`     | Shared by roles; a host may add one directly                |

Roles overlap through `fleet` (maintenance, Tailscale, sshd), and a feature is selected once however many profiles include it. `desktop` lists both the macOS and future Linux desktop features; each one does nothing on the other OS.

### Hosts

A host (`hosts.<name>`) sets its platform, login, selected features and any machine-only config, under the same `darwin`, `nixos` and `homeManager` keys a feature uses. The name is both the flake target and the hostname.

```nix
# modules/hosts/work-macbook.nix
hosts.work-macbook = {
  system = "aarch64-darwin";
  login = "chenxin-yan";
  features = with config.features; [ workstation desktop ]; # + darwin, from system
  exclude = with config.features; [ podman ]; # an exception to the roles
  darwin = { /* nix-darwin: state version, account */ };
  homeManager = { /* Home Manager: machine-only packages */ };
};
```

The machinery is in `modules/flake/features.nix` and `modules/flake/hosts.nix`. To see what a host runs: `nix eval .#hosts.<name>.features --json`.

## Setup

### Prerequisites

- **All machines**: [Nix](https://nixos.org/download/) with flakes enabled, and Git.
- **macOS**: an Apple Silicon Mac and the Xcode Command Line Tools (`xcode-select --install`). Don't install Homebrew yourself: nix-homebrew manages it.
- **NixOS**: already installed and booted, logged in as your normal user. Its `/etc/nixos` config is kept, not replaced.

### Onboard a machine

```sh
git clone https://github.com/chenxin-yan/nix-dotfiles ~/dotfiles
cd ~/dotfiles
bash scripts/onboard.sh
```

For a new machine, the wizard writes `modules/hosts/<name>/`, keeping NixOS's own `/etc/nixos` config under `_installed/`. It then evaluates, builds and activates the machine, asking before every change. On a reinstalled machine that already has a host file, it reuses that file instead. The stages are described at the top of `scripts/onboard.sh`. A new Mac gets `workstation desktop`; a new NixOS machine gets only `base development`, so add its roles to the host file afterwards. Commit any new host files.

### After install

Nix doesn't manage secrets, logins or macOS permissions. Set these up on each machine.

**Secrets and logins**

- `~/.env`: API keys and other private environment variables, sourced by every zsh session. WakaTime (in pi and Neovim) reads `WAKATIME_API_KEY` from it. Create the file even if it's empty, or each shell starts with an error.
- SSH: create `~/.ssh/id_ed25519`, add the public key to GitHub, and add it to `openssh.authorizedKeys.keys` in the host files of the machines that should accept it.
- `gh auth login`, 1Password (app and `op`, on desktops), and the coding agents' own logins (pi, Claude Code, Codex).

**Network and sync**

- Tailscale: `sudo tailscale up` to join the tailnet.
- Syncthing: devices are declared by ID in `modules/features/system/syncthing.nix`. A new or reinstalled machine gets a new ID, so add it there and switch on the other machines. The Raspberry Pi isn't managed by this repo, so accept the new device in its Syncthing UI too.

**macOS permissions** (approve in System Settings when prompted)

- Karabiner driver extension (for kanata): _General → Login Items & Extensions_.
- Input Monitoring for kanata, Accessibility for AeroSpace and espanso: _Privacy & Security_.
- Background items for sketchybar and the other agents: _General → Login Items & Extensions_.

## Daily use

### Commands

| Command                | What it does                                                          |
| ---------------------- | --------------------------------------------------------------------- |
| `just switch`          | Rebuild and activate this machine (checks it matches its host entry)  |
| `just switch <target>` | Same, once, for a machine whose hostname doesn't match its target yet |
| `just update`          | Update flake inputs                                                   |
| `just update-pins`     | Update pinned `fetchFrom*` sources                                    |
| `just clean`           | Garbage-collect with this host's retention, then optimise the store   |
| `just fmt`             | Format Nix files                                                      |

### Things to know

- **`git add` new files before switching.** Git-backed flakes don't see untracked files.
- **Homebrew removes what isn't declared.** Activation runs with `cleanup = "zap"`, so declare casks in the feature they belong to (`darwin.homebrew.casks`).
- **Some config is linked, not copied.** Edits to the Neovim config (`modules/features/editor/nvim/config/`) and the shell scripts behind the zsh aliases (`modules/features/shell/zsh/scripts/`) apply without a rebuild.
- **`nix flake check` only evaluates the NixOS hosts.** A broken Mac config shows up at `just switch`.

## Making changes

### Add a feature

Create a file under `modules/features/<group>/` with the parts it needs:

```nix
# modules/features/apps/todoist.nix
{
  features.todoist = {
    darwin.homebrew.casks = [ "todoist-app" ];
    homeManager = { pkgs, ... }: {
      home.packages = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.todoist-electron ];
    };
  };
}
```

Then add it to a role's or block's `includes`, or to a host's `features`. Related features can nest: `agents/` owns shared skills and agent tools, and includes the separate `pi` feature in `agents/pi/`; `exclude = [ pi ]` leaves the other agents available.

### Leave a feature out on one host

Add it to that host's `exclude`, as `work-macbook` does with `podman`.

### Add a machine

Run the wizard, or copy an existing host file. Never reuse another machine's hardware configuration.

### Find where something is configured

`features.<name>` is defined in the file with that name under `modules/features/`, e.g. `features.syncthing` → `system/syncthing.nix`. Profiles are the exception: `features.workstation` → `modules/profiles/roles/workstation.nix`. The theme is in `theme.nix`, and shared paths and environment variables are in `paths.nix`.
