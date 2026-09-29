# dotfiles

Nix Flakes + Home Manager dotfiles for macOS and NixOS, themed with Catppuccin Mocha.

Everything is declarative — no symlink managers, no install scripts, no imperative setup. A single `just switch` rebuilds the machine you run it on from this repo.

## Table of Contents

- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Module Architecture](#module-architecture)
- [Neovim](#neovim)
- [Shell](#shell)
- [Scripts](#scripts)
- [Syncthing](#syncthing)
- [Window Management](#window-management)
- [Keyboard](#keyboard)
- [Flake Inputs](#flake-inputs)
- [Environment Variables](#environment-variables)
- [Customization](#customization)

## Overview

This repo manages three machines from a single Nix flake. Each machine is registered once in `hosts/default.nix`; its key is the flake target and its managed hostname. Home Manager handles all user-level configuration, while nix-darwin and NixOS modules handle system-level settings. Catppuccin Mocha with Lavender accent is applied globally across the terminal, editor, status bar, and all CLI tools.

|                  | `macbook`                   | `work-macbook`              | `minipc`                    |
| ---------------- | --------------------------- | --------------------------- | --------------------------- |
| **OS**           | macOS (nix-darwin)          | macOS (nix-darwin)          | NixOS (headless server)     |
| **Architecture** | aarch64-darwin              | aarch64-darwin              | x86_64-linux                |
| **User**         | yanchenxin                  | chenxin-yan                 | cyan                        |
| **Profiles**     | base + development + desktop | base + development + desktop | base + development         |
| **Syncthing**    | yes                         | no                          | yes                         |
| **Shell**        | Zsh                         | Zsh                         | Zsh                         |
| **Desktop**      | Aerospace, Sketchybar, Ghostty | Aerospace, Sketchybar, Ghostty | — (SSH/mosh only)      |
| **Editor**       | Neovim                      | Neovim                      | Neovim                      |
| **Theme**        | Catppuccin Mocha (Lavender) | Catppuccin Mocha (Lavender) | Catppuccin Mocha (Lavender) |

## Repository Structure

```
dotfiles/
├── flake.nix                  # Inputs + native nixosSystem/darwinSystem constructors per registered host
├── flake.lock                 # Locked flake dependencies
├── justfile                   # Task runner (switch, update, clean, fmt)
├── hosts/
│   ├── default.nix            # Host inventory: target name -> platform + login (the only machine list)
│   ├── macbook/               # Personal Mac: account (UID 501), state versions, sync on
│   ├── work-macbook/          # Work Mac: separate login, same baseline, sync off
│   └── minipc/                # NixOS server: account, hardware, firewall, services
│       ├── configuration.nix
│       ├── hardware-configuration.nix
│       └── home.nix
├── profiles/home/
│   ├── base.nix               # Shared paths, theme, core tools (git, nvim, zsh, nushell, agents)
│   ├── development.nix        # Language toolchains and developer CLIs
│   ├── desktop.nix            # Opt-in GUI apps (Darwin-only apps guarded by platform)
│   └── darwin.nix             # Both Macs: base + development + desktop, macOS packages, SSH peers, nh
├── profiles/darwin/default.nix # Shared Mac system policy and feature selections
├── profiles/nixos/
│   ├── base.nix               # Minimal flakes + nh prerequisites for onboarding
│   └── default.nix            # Mini PC: base + 1Password, Bluetooth, Mosh, Podman
├── modules/
│   ├── home/                  # Home Manager feature modules (each has an enable option, off by default)
│   │   ├── core/              # Shell, editor, git
│   │   ├── cli/               # CLI tools and services (incl. syncthing)
│   │   ├── app/               # GUI applications
│   │   │   ├── shared/        # Cross-platform (ghostty, vesktop, espanso, zen-browser, todoist, telegram)
│   │   │   └── darwin/        # macOS-only (iina, kanata, sketchybar)
│   │   └── dev/               # Language toolchains and LSPs
│   ├── darwin/                # Optional nix-darwin system features
│   └── nixos/                 # NixOS system modules (1password, bluetooth, mosh, podman)
├── config/
│   └── nvim/                  # Neovim configuration (Lua, lazy.nvim)
└── scripts/
    ├── dev/                   # Session management
    ├── onboard.sh             # Onboarding wizard for a new or reinstalled machine (+ onboard.test.sh)
    ├── utils/                 # Utilities (switch, update-pins, rg+fzf, md2pdf)
    └── notes/                 # Note search
```

## Prerequisites

### Both Platforms

- [Nix](https://nixos.org/download/) with flakes enabled (`nix-command` and `flakes` experimental features)
- Git

### macOS

- macOS on Apple Silicon (aarch64-darwin)
- Xcode Command Line Tools (`xcode-select --install`)
- **Do NOT install Homebrew manually** — it is managed declaratively via [nix-homebrew](https://github.com/zhaofengli/nix-homebrew)

### NixOS

- NixOS already installed and booted, logged in as your normal user. Its installed `/etc/nixos` configuration is kept, not replaced: never overwrite another host's `hardware-configuration.nix`.

## Installation

### Onboarding a machine (macOS or installed NixOS)

From the intended checkout at `~/dotfiles`, as your normal user:

```sh
git clone https://github.com/<your-username>/dotfiles ~/dotfiles
cd ~/dotfiles
bash scripts/onboard.sh
```

The wizard needs only Bash, Nix and Git (not Just or NH) and walks through seven stages, with separate `y/N` gates for changes (a complete line starting with `y` or `Y` is yes; a failed read, including partial input followed by EOF, is no):

1. **Inspect**: OS, architecture, login, UID, home, hostname, checkout, Git state (read-only).
2. **Select/register**: choose a target name. A registered target is reused after checking platform/login; a new one gets a single entry appended to `hosts/default.nix`, which Nix must confirm equals the old inventory plus that entry.
3. **Preserve**: NixOS reviews the `/etc/nixos` `.nix` files for a verbatim copy into `hosts/<name>/installed/` at the write step (boot, disks, LUKS, users, network, desktop, `system.stateVersion`). The originals remain your recovery copy; no extra backup is made, so back them up yourself before later deleting them. It refuses flakes, symlinks, non-`.nix` files, imports that are not relative (channels, `../`, absolute or store paths), and any password/key/token setting or secret-looking value, printing only `file:line`; move those out of `/etc/nixos` or write the host by hand. `/etc/nixos` is never modified. macOS stops on an existing nix-darwin install and asks before setting `nix-homebrew.autoMigrate` for an existing Homebrew.
4. **Compose**: small `hosts/<name>/configuration.nix` and `home.nix`. NixOS: installed config + `profiles/nixos/base.nix` (flakes, NH) + your real UID/home, and base + development home profiles; you decide on unfree packages. macOS: `profiles/darwin/default.nix` + `profiles/home/darwin.nix`, `system.stateVersion` from the locked nix-darwin; no authorized SSH keys are copied. Home Manager's `home.stateVersion` defaults to the locked release for a new home. If an existing Home Manager is found, you must type the value that home actually uses (there is no default). Either way the value is checked against the locked Home Manager.
5. **Review and evaluate**: offers `git add --` for exactly the generated host files, rechecked first (untracked files are invisible to the flake; other untracked files in the host directory stop the run), then evaluates the target and checks platform, login, UID, home, checkout, hostname, state versions, NH and Just, and existing files in Home Manager's way.
6. **Build, then activate**: builds as your user; activation is a separate prompt (`nixos-rebuild switch --sudo`, or the built `darwin-rebuild switch` with sudo on macOS, after showing the Homebrew `zap` effect).
7. **Verify**: hostname, account, Just and NH in the new profile; then open a new login shell and use `just switch` from then on.

Evaluation may download locked inputs or realize evaluation-time dependencies; the separate build gate controls the full system build. It never resets, pulls or cleans the checkout, commits, pushes, updates `flake.lock` (flake evaluations/builds use `--no-update-lock-file --no-write-lock-file`), uses remote builders (`--option builders ''`), garbage-collects or reboots. Scratch files and build-result links use a private temporary directory (`$TMPDIR`, or `/tmp`), outside the checkout, removed on exit. No persistent wizard state directory is created. Nix store packages remain subject to normal garbage collection; if you decline activation, rerun the wizard when ready. Rerun it any time: it reuses a registered target and stops on partial or conflicting state instead of repairing it. Commit the new host files yourself. `bash scripts/onboard.test.sh` runs focused lifecycle checks with stubbed Nix and system tools; it does not evaluate real configurations, build packages or activate anything.

### macOS (registered target, manual)

1. Install Nix using the [official installer](https://nixos.org/download/)

   ```sh
   sh <(curl -L https://nixos.org/nix/install)
   ```

2. Clone the repository:

   ```sh
   git clone https://github.com/<your-username>/dotfiles ~/dotfiles
   cd ~/dotfiles
   ```

3. Pick the registered target for this machine from `hosts/default.nix` (`macbook` or `work-macbook`) and make sure you are logged in as its user. Build and apply for the first time (`just` and `nh` are not installed yet, and root does not have flakes enabled until this activates). `--inputs-from` runs the `darwin-rebuild` pinned in `flake.lock` instead of a moving branch:

   ```sh
   sudo nix --extra-experimental-features 'nix-command flakes' run --inputs-from ~/dotfiles nix-darwin#darwin-rebuild -- switch --flake ~/dotfiles#macbook
   ```

   The first build will take a while as it downloads the entire package closure. Activation sets the macOS `HostName`/`LocalHostName` to the target name.

   > **Homebrew cleanup is destructive.** Both Macs use `homebrew.onActivation.cleanup = "zap"`: activation removes packages absent from the effective Homebrew configuration and can delete associated cask data. Declare anything you want to keep in `profiles/darwin/default.nix` or its owning feature module before activation.

4. For all subsequent rebuilds:

   ```sh
   just switch
   ```

   This runs `scripts/utils/switch.sh`, which checks that the hostname is a registered target and that the platform, login, UID and checkout path match it, then runs `nh darwin switch --hostname <target>` with the full nix-darwin + Home Manager configuration.

### NixOS

Use `bash scripts/onboard.sh` (above). An existing target reuses its stored configuration: after a reinstall or disk-layout change, review and update that target's hardware/boot configuration before activating it. The wizard does not refresh existing targets from `/etc/nixos`. After a successful new-machine migration and reboot, `/etc/nixos` is still the untouched installer copy; the repo is the source of truth. Pointing `/etc/nixos/flake.nix` at the checkout is optional and manual. Subsequent rebuilds:

```sh
just switch
```

This runs `nh os switch --hostname <target>` after the same preflight checks as on macOS. Other Linux distributions (including Raspberry Pi OS) are rejected; there is no target for them.

### Post-Install

- **SSH keys**: Set up `~/.ssh/id_ed25519` for GitHub and remote machines
- **GitHub CLI**: Run `gh auth login` to authenticate
- **Syncthing**: Open the web UI at `http://localhost:8384` to approve device connections
- **Neovim**: Plugins install automatically on first launch via lazy.nvim
- **1Password**: Log in to set up SSH agent integration

## Usage

| Command                 | Description                                                                          |
| ----------------------- | ------------------------------------------------------------------------------------ |
| `just switch`           | Rebuild and apply this machine's configuration (system + Home Manager)               |
| `just switch <target>`  | Same, selecting a registered target explicitly (one-time bootstrap before the hostname matches) |
| `just update`       | Update all flake inputs to latest                  |
| `just update-pins`  | Update pinned fetchFromGitHub dependencies         |
| `just clean`        | Garbage collect old generations and optimize store |
| `just fmt`          | Format all Nix files with treefmt                  |
| `just search <pkg>` | Search nixpkgs for a package                       |
| `just show <pkg>`   | Show package information                           |

Native Nix cleanup is defined once in [`profiles/cleanup-policy.nix`](profiles/cleanup-policy.nix), imported by both system profiles and read by `just clean`. All machines collect weekly with 14-day generation retention; the current generation is preserved, with no minimum-count guarantee. Store optimization runs separately (daily on MiniPC, weekly on Macs). `just clean` uses sudo to run native GC, then optimization; NH remains the rebuild CLI, not the collector. Retention protects profile generations, not arbitrary unreferenced build outputs.

## Module Architecture

Every Home Manager feature leaf under `modules/home/` defines an `enable` option and does nothing until enabled; the `modules/home/*/default.nix` aggregators only import. Selections live in `profiles/home/`:

- `base.nix` enables the core tools (git, nvim, zsh, nushell, agents) and defines shared paths/theme.
- `development.nix` enables every language toolchain and developer CLI.
- `desktop.nix` enables the GUI apps; Darwin-only apps are guarded by `pkgs.stdenv.hostPlatform.isDarwin`.

Each host's `home.nix` imports the profiles it wants and owns its `home.stateVersion` and Syncthing enrollment (`cli.syncthing.enable`). A headless host is simply base + development; no GUI opt-out list is needed. Profiles use `lib.mkDefault`, so a host can still override any single feature:

```nix
# In hosts/<name>/home.nix
app.shared.zen-browser.enable = false;
```

System modules follow the same split: `modules/darwin/default.nix` and `modules/nixos/default.nix` only import feature definitions. Profiles select features with `lib.mkDefault`, so hosts can override them:

- `profiles/darwin/default.nix`: both Macs' shared settings and 1Password, AeroSpace, Kanata, SketchyBar selections.
- `profiles/nixos/base.nix`: only flakes + NH; new NixOS hosts layer this over their preserved installation.
- `profiles/nixos/default.nix`: base + 1Password, Bluetooth, Mosh and Podman; selected by the mini PC.

Host system files retain machine-specific hardware, account facts, state versions and overrides.

### Switching

`just switch` runs `scripts/utils/switch.sh`. It reads the inventory from the flake's `hosts` output (never a second list in shell), then refuses to activate unless the OS is macOS or NixOS, the target is registered, and the target's platform, login, UID and `~/dotfiles` path match the running machine and checkout. It never updates `flake.lock`, deploys over SSH, or falls back to a default target. `scripts/utils/switch.test.sh` exercises these branches with stubbed `nix`/`nh`/`uname`/`hostname`/`id` and never builds anything.

New configuration files must be tracked by Git before switching; Git-backed flakes omit untracked files. Deploy the changes to `~/dotfiles` rather than activating a separate development checkout. On an existing Mac whose hostname has not changed yet, use `just switch macbook` or `just switch work-macbook` once, after checking its declared UID/home and the Homebrew cleanup policy.

### Inter-machine SSH (follow-up)

The goal is password-less SSH between all managed machines. Today the repo carries the existing authorized key on both Macs and the existing client aliases (`cyan-minipc`, `cyan-macbook`, `cyanpi`). A full mesh is deferred until each device's public key and reachable address are known: use one key per device, authorize public keys explicitly, and keep host-key verification as is. Never copy private keys between machines.

### Agent Modules

`modules/home/agents/`

| Module   | Purpose                                                    |
| -------- | ---------------------------------------------------------- |
| `agents` | Shared agent instructions and `~/.agents/skills/` symlinks |

### Core Modules

`modules/home/core/`

| Module    | Purpose                                                                   |
| --------- | ------------------------------------------------------------------------- |
| `zsh`     | Zsh with vi keybindings, oh-my-posh prompt, fzf, direnv, modern CLI tools |
| `git`     | Git config, delta diffs, GitHub CLI, gh-dash, lazygit                     |
| `nvim`    | Neovim with out-of-store symlink to `config/nvim/`                        |
| `nushell` | Nushell shell                                                             |

### CLI Modules

`modules/home/cli/`

| Module      | Purpose                                |
| ----------- | -------------------------------------- |
| `zellij`    | Terminal multiplexer                   |
| `yazi`      | Terminal file manager with plugins     |
| `mise`      | Polyglot runtime/tool version manager  |
| `syncthing` | File sync across 3 devices (enabled on `macbook` and `minipc`; not the work Mac) |
| `gcloud`    | Google Cloud SDK                       |
| `pandoc`    | Document conversion                    |
| `pi`        | Pi coding agent runtime and extensions |
| `podman`    | Rootless containers                    |

### App Modules

`modules/home/app/`

**Shared** (all platforms):

| Module        | Purpose                 |
| ------------- | ----------------------- |
| `ghostty`     | Terminal emulator       |
| `vesktop`     | Discord client          |
| `telegram`    | Telegram Desktop        |
| `espanso`     | Text expander           |
| `zen-browser` | Privacy-focused browser |
| `todoist`     | Task management         |

**Darwin only** (macOS):

| Module       | Purpose                            |
| ------------ | ---------------------------------- |
| `iina`       | Video player                       |
| `kanata`     | Keyboard remapping (home-row mods) |
| `sketchybar` | Custom status bar with plugins     |

### Dev Modules

`modules/home/dev/`

| Module       | Includes                                     |
| ------------ | -------------------------------------------- |
| `python`     | Python 3.13, uv, ruff, basedpyright          |
| `typescript` | TypeScript/JavaScript tooling                |
| `go`         | Go toolchain                                 |
| `java`       | Java development tools                       |
| `lua`        | Lua toolchain                                |
| `nix`        | Nix language tools, nixfmt                   |
| `c`          | C/C++ development                            |
| `bash`       | Bash scripting tools                         |
| `markdown`   | Markdown tools                               |
| `sql`        | SQL tools                                    |
| `latex`      | LaTeX (tectonic, texlab)                     |
| `web`        | HTML/CSS/Emmet, Astro, Prisma                |

### System Modules

**nix-darwin** (`modules/darwin/`):

| Module      | Purpose                  |
| ----------- | ------------------------ |
| `1password` | 1Password integration    |
| `aerospace` | Tiling window manager    |
| `kanata`    | Keyboard remapper daemon |

**NixOS** (`modules/nixos/`):

| Module      | Purpose             |
| ----------- | ------------------- |
| `1password` | 1Password CLI       |
| `bluetooth` | Bluetooth support   |
| `mosh`      | Mobile shell server |
| `podman`    | Podman with Docker compatibility (host account joins the `podman` group) |

## Neovim

Lua-based configuration in `config/nvim/` using [lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager. Space is the leader key.

Vite+ integration lives in `config/nvim/lua/cyan/plugins/languages/web/viteplus.lua`; `web/init.lua` wires its project detection, Oxlint configuration, and Conform override into the shared web setup. Vite+ projects use the workspace-local `node_modules/.bin/vp`: `vp lint --lsp` for diagnostics and `vp fmt --stdin-filepath` through Conform for formatting (including Markdown/MDX). Detection checks the package-manager workspace/lockfile root's `package.json` for a `vite-plus` dependency, falling back to the nearest package when there is no workspace marker. Install project dependencies first; keep shared lint/format settings in the root `vite.config.ts`. Plain Vite projects are not opted in. Other projects retain standalone Oxc, Biome, and Prettier selection. Oxfmt is configured only in Conform, not as an LSP server.

After changing this configuration, restart Neovim. `:ConformInfo` shows the formatter executable and `:checkhealth vim.lsp` shows attached servers. Run the routing checks with installed plugins/tools using `nvim --headless -u NONE -l config/nvim/tests/viteplus.lua` from this repo.

<details>
<summary><b>Coding</b> (8 plugins)</summary>

- **conform.nvim** — Format on save
- **nvim-lint** — Async linting
- **nvim-lspconfig** — LSP configuration
- **refactoring.nvim** — Code refactoring
- **dial.nvim** — Increment/decrement (numbers, booleans, dates)
- **coerce.nvim** — String case conversion
- **debugprint.nvim** — Debug print statements
- **ts-comments.nvim** — Treesitter-aware commenting

</details>

<details>
<summary><b>Editor</b> (18 plugins)</summary>

- **fzf-lua** — Fuzzy finder (files, buffers, diagnostics, git)
- **flash.nvim** — Enhanced motion/search
- **nvim-treesitter** — Syntax highlighting, text objects, context
- **blink.cmp** — Completion engine (LSP, snippets, paths)
- **snacks.nvim** — Dashboard, file explorer, lazygit, indent guides, zen mode
- **mini.nvim** — AI text objects, surround, splitjoin, move, autopairs
- **trouble.nvim** — Diagnostics and quickfix panel
- **which-key.nvim** — Keymap hints
- **gitsigns.nvim** — Git change indicators
- **grug-far.nvim** — Find and replace
- **multicursor.nvim** — Multi-cursor editing
- **arrow.nvim** — File navigation
- **nvim-ufo** — Code folding
- **guess-indent.nvim** — Auto-detect indentation
- **gx.nvim** — Open URLs
- **numb.nvim** — Line number preview
- **import.nvim** — Auto imports
- **colorscheme** — Catppuccin Mocha

</details>

<details>
<summary><b>UI</b> (5 plugins)</summary>

- **noice.nvim** — Enhanced messages and command line
- **lualine.nvim** — Status line
- **rainbow-delimiters.nvim** — Colorful bracket matching
- **todo-comments.nvim** — TODO/FIXME/NOTE highlighting
- **nvim-lsp-endhints** — End-of-block type hints

</details>

<details>
<summary><b>Languages</b> (12 configs)</summary>

| Language   | LSP Server(s)               | Formatter          |
| ---------- | --------------------------- | ------------------ |
| Python     | basedpyright, ruff          | ruff               |
| TypeScript | vtsls                       | Vite+/Oxfmt, Biome, or prettierd |
| Go         | gopls                       | goimports, gofumpt |
| Java       | jdtls                       | -                  |
| Lua        | lua_ls                      | stylua             |
| Nix        | nil_ls                      | nixfmt             |
| C          | clangd                      | clang-format       |
| Bash       | bashls                      | shfmt              |
| SQL        | sqls                        | -                  |
| Markdown   | -                           | Vite+/Oxfmt, markdownlint-cli2 |
| Web        | emmet_ls, astro             | Vite+/Oxfmt, Biome, or prettierd |
| Docker     | dockerls, docker_compose_ls | -                  |

</details>

<details>
<summary><b>Extras</b> (5 plugins)</summary>

- **yazi.nvim** — Terminal file manager integration
- **leetcode.nvim** — LeetCode practice
- **cord.nvim** — Discord Rich Presence
- **vim-wakatime** — Code time tracking
- **sidekick.nvim** — Code companion

</details>

## Shell

Zsh with vi mode (`viins` keymap) and [oh-my-posh](https://ohmyposh.dev/) prompt using Catppuccin colors.

### Modern CLI Replacements

| Traditional | Replacement | Alias/Integration         |
| ----------- | ----------- | ------------------------- |
| `ls`        | eza         | `ls`, `ll`, `tree`        |
| `cat`       | bat         | `cat`                     |
| `cd`        | zoxide      | `cd` (via `--cmd cd`)     |
| `find`      | fd          | Used by fzf               |
| `grep`      | ripgrep     | `rg`                      |
| `diff`      | hunk        | Git integration           |
| `top`       | btop        | Vim keybindings           |
| `man`       | tlrc        | Community-maintained tldr |

### Key Bindings

| Binding   | Action                       |
| --------- | ---------------------------- |
| `Ctrl+P`  | History search backward      |
| `Ctrl+N`  | History search forward       |
| `Ctrl+Y`  | Accept autosuggestion        |
| `Ctrl+G`  | Open lazygit                 |
| `Alt+D`   | fzf directory picker         |
| `Esc Esc` | Prepend `sudo` to command    |
| `H` / `L` | Line start/end (vi cmd mode) |

### Per-Project Environments

[direnv](https://direnv.net/) with [nix-direnv](https://github.com/nix-community/nix-direnv) is enabled — drop a `.envrc` with `use flake` in any project to get automatic Nix dev shells.

## Scripts

All scripts live in `scripts/` and are symlinked to `~/.local/bin/scripts`. Shell aliases are defined in `modules/home/core/zsh/scripting.nix`.

| Alias    | Script                  | Purpose                                   |
| -------- | ----------------------- | ----------------------------------------- |
| `se`     | `dev/attach.sh`         | Attach to or create a Zellij dev session  |
| `dvc`    | `dev/clone.sh`          | Clone a repo into organized dev directory |
| `scu`    | `dev/cleanup.sh`        | Clean up orphaned Zellij sessions         |
| `srm`    | `dev/session-remove.sh` | Remove a project with safety checks       |
| `fzg`    | `utils/rg_with_fzf.sh`  | Ripgrep with fzf preview, opens in Neovim |
| `md2pdf` | `utils/md2pdf.sh`       | Interactive markdown to PDF conversion    |
| `notes`  | `notes/search.sh`       | Search and open notes with fzf            |
| `cdv`    | _(alias)_               | `cd $DEV_PATH`                            |

Dev repos are organized as `~/dev/<host>/<owner>/<repo>` (e.g., `~/dev/github.com/user/project`).

## Syncthing

File synchronization across three devices, managed declaratively in `modules/home/cli/syncthing/` and enabled per host (`macbook`, `minipc`; the work Mac stays out).

| Folder   | macbook | minipc | raspberry-pi |
| -------- | :-----: | :----: | :----------: |
| `~/dev`  |    x    |   x    |      x       |
| `~/PARA` |    x    |        |      x       |

The `.stignore` files are generated by Nix and exclude build artifacts (`node_modules`, `dist`, `build`, `target`, `__pycache__`, `.venv`, `.git`, etc.).

## Window Management

### macOS — Aerospace

Tiling window manager configured in `modules/darwin/aerospace/`. Uses Alt-based keybindings (Alt+HJKL for focus, Alt+Shift+HJKL for move). Workspaces integrate with Sketchybar for visual indicators.

## Keyboard

[Kanata](https://github.com/jtroo/kanata) provides home-row modifiers on macOS (config at `modules/home/app/darwin/kanata/config/kanata.kbd`):

| Key  | Tap | Hold        |
| ---- | --- | ----------- |
| A    | a   | Cmd         |
| S    | s   | Shift       |
| D    | d   | Alt         |
| F    | f   | Ctrl        |
| G/H  | g/h | Hyper       |
| J    | j   | Ctrl        |
| K    | k   | Alt         |
| L    | l   | Shift       |
| ;    | ;   | Cmd         |
| Caps | Esc | Super layer |

The ZSA Voyager keyboard is excluded from Kanata remapping.

## Flake Inputs

| Input              | Source                                 | Purpose                                  |
| ------------------ | -------------------------------------- | ---------------------------------------- |
| `nixpkgs`          | `nixos-unstable`                       | Package repository                       |
| `home-manager`     | follows nixpkgs                        | User environment management              |
| `nix-darwin`       | `nix-darwin/nix-darwin/master`         | macOS system configuration               |
| `nix-homebrew`     | `zhaofengli/nix-homebrew`              | Declarative Homebrew management          |
| `catppuccin`       | `catppuccin/nix`                       | Global theming                           |
| `pi-catppuccin`    | `otahontas/pi-coding-agent-catppuccin` | Catppuccin theme for the pi coding agent |
| `zen-browser`      | `0xc000022070/zen-browser-flake`       | Zen Browser for NixOS                    |
| `hunk`             | `modem-dev/hunk`                       | Diff viewer (Home Manager module)        |

## Environment Variables

Set in `profiles/home/base.nix` and available in all shells:

| Variable        | Default              | Purpose                       |
| --------------- | -------------------- | ----------------------------- |
| `DOTFILES_PATH` | `~/dotfiles`         | Location of this repo         |
| `DEV_PATH`      | `~/dev`              | Development repositories      |
| `PROJECTS_PATH` | `~/PARA/01 Projects` | Active projects (PARA method) |
| `AREAS_PATH`    | `~/PARA/02 Areas`    | Areas of responsibility       |
| `NOTES_PATH`    | `~/notes`            | Notes directory               |
| `EDITOR`        | `nvim`               | Default editor                |
| `VISUAL`        | `nvim`               | Default visual editor         |

## Customization

### Forking for Your Own Use

1. **Register your machine**: Run `bash scripts/onboard.sh`, or add an entry to `hosts/default.nix` (the key becomes the hostname and flake target) with its platform and login, then create `hosts/<name>/configuration.nix` (UID, authorized keys, state version) and `hosts/<name>/home.nix` (profiles, `home.stateVersion`)

2. **Hardware config**: Never reuse `hosts/minipc/hardware-configuration.nix`; `scripts/onboard.sh` keeps your machine's own installed configuration

3. **Disable modules**: Set `<category>.<module>.enable = false` in your host's `home.nix`:

   ```nix
   dev.latex.enable = false;
   cli.podman.enable = false;
   app.shared.vesktop.enable = false;
   ```

4. **Add a new module**: Follow the pattern in any existing module directory — create a `default.nix` with an `enable` option, then import it in the category's `default.nix`

5. **Change the theme**: Modify `catppuccin.flavor` and `catppuccin.accent` in `profiles/home/base.nix`

6. **Neovim plugins**: Add plugin specs under `config/nvim/lua/cyan/plugins/` in the appropriate category directory

7. **Syncthing devices**: Update device IDs and folder config in `modules/home/cli/syncthing/default.nix`
