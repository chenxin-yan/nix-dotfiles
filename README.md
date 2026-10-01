# dotfiles

Nix flake for my Macs (nix-darwin) and NixOS machines, with Home Manager for everything user-level. Built with [flake-parts](https://flake.parts) in the [dendritic pattern](https://github.com/mightyiam/dendritic) and themed with Catppuccin Mocha.

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
- **Secrets**: an onboarded machine with 1Password, to enrol the new one.

### Onboard a machine

```sh
git clone https://github.com/chenxin-yan/nix-dotfiles ~/dotfiles
cd ~/dotfiles
bash scripts/onboard.sh
```

For a new machine, the wizard writes `modules/hosts/<name>/`, keeping NixOS's own `/etc/nixos` config under `_installed/`. It then evaluates, builds and activates the machine, asking before every change. Before building, it prints a `just secrets-enrol` command to run on a machine with 1Password, and waits until that's pushed. On a reinstalled machine that already has a host file, it reuses that file instead. The stages are described at the top of `scripts/onboard.sh`. A new Mac gets `workstation desktop`; a new NixOS machine gets only `base development`, so add its roles to the host file afterwards. Commit any new host files.

### After install

Nix can't sign in to accounts, approve macOS permissions or join networks. Do these on each machine, then check with `just doctor`.

**Logins**

- Desktops: sign in to 1Password, then in _Settings → Developer_ (on a Mac, `open onepassword://settings/developers`) turn on **Use the SSH agent** and **Integrate with 1Password CLI**.
- Servers: `ssh-keygen -t ed25519 -N ""`, put the public key (without its comment) in the host's `sshKey` so the fleet accepts it, and add it to GitHub. To use `just secret*` there, run `op account add` once.
- `gh auth login` and the coding agents' own logins (pi, Claude Code, Codex).

**Network**

- Tailscale: `sudo tailscale up` to join the tailnet. Keep the machine's Tailscale name auto-generated from its hostname; `ssh <name>` relies on it.

**macOS permissions** (approve in System Settings when prompted)

- Karabiner driver extension (for kanata): _General → Login Items & Extensions_.
- Input Monitoring for kanata, Accessibility for AeroSpace and espanso: _Privacy & Security_.
- Background items for sketchybar and the other agents: _General → Login Items & Extensions_.

## Daily use

### Commands

| Command                           | What it does                                                          |
| --------------------------------- | --------------------------------------------------------------------- |
| `just switch`                     | Rebuild and activate this machine (checks it matches its host entry)  |
| `just switch <target>`            | Same, once, for a machine whose hostname doesn't match its target yet |
| `just update`                     | Update flake inputs                                                   |
| `just update-pins`                | Update pinned `fetchFrom*` sources                                    |
| `just clean`                      | Garbage-collect with this host's retention, then optimise the store   |
| `just fmt`                        | Format Nix files                                                      |
| `just doctor`                     | Check this machine's secrets, SSH agent and GitHub access             |
| `just secret-set <name>`          | Set one secret from a hidden prompt                                   |
| `just secrets-edit`               | Edit `secrets/shared.yaml` in `$EDITOR`                               |
| `just secrets-enrol <name> <key>` | Let a machine decrypt secrets                                         |
| `just secrets-rekey`              | Re-encrypt every secrets file for the enrolled machines               |

### Secrets

API keys are encrypted in `secrets/`. Each enrolled machine decrypts them at activation with its SSH host key; the `just secret*` recipes use the recovery key, stored in 1Password as `sops-recovery`.

- **Change a key:** `just secret-set <name>`, commit, then `just switch` on each machine.
- **Use one in a feature:** include `secrets`, declare `sops.secrets.<name>.owner = host.login;` in the feature's `darwin` and `nixos` parts, and have the program read `osConfig.sops.secrets.<name>.path` when it runs. Never read the value during evaluation; it would end up in the Nix store.
- **Enrol a machine:** the onboarding wizard prints the command. By hand: `just secrets-enrol <name> '<key>'` with that machine's `/etc/ssh/ssh_host_ed25519_key.pub`, then commit and push before its first switch. Re-enrolling replaces the old key.
- **A machine is lost:** delete its line from `modules/hosts/_host-keys.json`, run `just secrets-rekey`, commit, and rotate the API keys with their providers.
- **The recovery key is lost:** create a new one. This prints only its public half; put it in `recovery` in `modules/flake/sops.nix`.

  ```sh
  nix shell nixpkgs#age -c sh -c 'age-keygen 2>/dev/null | op document create - --title sops-recovery --file-name keys.txt >/dev/null && op document get sops-recovery | age-keygen -y'
  ```

  Then re-encrypt from an enrolled machine, using its host key:

  ```sh
  install -m 0644 "$(nix build --no-link --print-out-paths .#sops-config)" .sops.yaml
  key="$(sudo "$(command -v ssh-to-age)" -private-key -i /etc/ssh/ssh_host_ed25519_key)"
  for f in secrets/*.yaml secrets/hosts/*.yaml; do [ -e "$f" ] && SOPS_AGE_KEY="$key" sops updatekeys --yes "$f"; done
  unset key
  ```

### Things to know

- **`git add` new files before switching.** Git-backed flakes don't see untracked files.
- **SSH accepts only keys declared in Nix.** No passwords, no root, and `~/.ssh/authorized_keys` is ignored. Every machine accepts `desktopKey` in `modules/features/system/sshd.nix` and each host's `sshKey`, so any fleet machine reaches any other as `ssh <name>`, with its host key pinned once enrolled.
- **Homebrew removes what isn't declared.** Activation runs with `cleanup = "zap"`, so declare casks in the feature they belong to (`darwin.homebrew.casks`).
- **Some config is linked, not copied.** Edits to the Neovim config (`modules/features/cli/nvim/config/`) and the shell scripts behind the zsh aliases (`modules/features/cli/zsh/scripts/`) apply without a rebuild.
- **`nix flake check` only evaluates the NixOS hosts.** A broken Mac config shows up at `just switch`.

## Making changes

### Add a feature

Create a file under `modules/features/<group>/` with the parts it needs:

```nix
# modules/features/gui/todoist.nix
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

`features.<name>` is defined in the file with that name under `modules/features/`, e.g. `features.tailscale` → `system/tailscale.nix`. Profiles are the exception: `features.workstation` → `modules/profiles/roles/workstation.nix`. The theme is in `theme.nix`, and shared paths and environment variables are in `paths.nix`.
