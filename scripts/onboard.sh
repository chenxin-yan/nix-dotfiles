#!/usr/bin/env bash
set -euo pipefail

if [[ -t 1 ]] && command -v tput >/dev/null 2>&1 && [[ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]]; then
  BOLD=$(tput bold); DIM=$(tput dim); RESET=$(tput sgr0)
  BLUE=$(tput setaf 4); GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3); RED=$(tput setaf 1)
else
  BOLD=""; DIM=""; RESET=""; BLUE=""; GREEN=""; YELLOW=""; RED=""
fi

_STAGE_INDEX=0

# _clear wipes the terminal so only the current step is on screen. No-op when
# output isn't a terminal, so piped logs stay readable.
_clear() {
  [[ -t 1 ]] || return 0
  if command -v tput >/dev/null 2>&1; then tput clear; else printf '\033[2J\033[3J\033[H'; fi
}

# stage "Name" clears the screen, then announces a stage and shows progress.
# Clearing keeps only the current step on screen.
stage() {
  _clear
  _STAGE_INDEX=$((_STAGE_INDEX + 1))
  printf '\n%s%s▸ Stage %s/%s · %s%s\n' \
    "$BOLD" "$BLUE" "$_STAGE_INDEX" "$TOTAL_STAGES" "$1" "$RESET"
}

say()  { printf '  %s\n' "$1"; }
step() { printf '  %s•%s %s\n' "$BLUE" "$RESET" "$1"; }
note() { printf '  %s%s%s\n' "$DIM" "$1" "$RESET"; }
warn() { printf '  %s⚠ %s%s\n' "$YELLOW" "$1" "$RESET"; }

ask() {
  printf '  %s%s%s ' "$BOLD" "$2" "$RESET"
  IFS= read -r "$1" || die "input ended; rerun when ready"
}

# Onboard this machine into the dotfiles flake: macOS, or NixOS that is
# already installed and booted. Run from the intended ~/dotfiles checkout as
# your normal user:  bash scripts/onboard.sh
# Needs only Bash, Nix and Git (never Just or NH); sudo is used for the final,
# separately confirmed activation and, when the target reads secrets, to
# create and read this machine's SSH host key. If asked to, it gives the
# login its own SSH key and, after activation, adds it to GitHub with gh.
#
# Stages: inspect; select/register; preserve the installation; compose the
# Nix-owned baseline; review and evaluate; build, then activate; verify.
# Every repo write, `git add`, build and activation has its own y/N gate();
# anything but a complete "y..." line, including EOF, answers no. It never
# resets or cleans the checkout, commits, pushes, updates flake.lock,
# garbage-collects, reboots, or edits /etc/nixos; it pulls (fast-forward only)
# only when you confirm an enrolment is pushed.
# Reruns reuse a registered target and stop on partial or conflicting state.
#
# Keep runnable by macOS /bin/bash 3.2: no mapfile, ${v,,}, GNU-only tool
# flags, or arrays.

TOTAL_STAGES=7

NAME_RE='^[a-z0-9]+(-[a-z0-9]+)*$'
PATH_RE='^/[A-Za-z0-9._/-]+$'
VERSION_RE='^[0-9]+\.[0-9]+$'
NIX_FILE_RE='^[A-Za-z0-9._/-]+\.nix$'
# Conservative, not a Nix parser: any hit sends the file to manual migration.
# Names are matched on non-comment lines whatever the value's formatting
# (multiline, lib.mkDefault, inherit); value shapes (crypt hashes, private
# keys, raw 64-hex PSKs, Tailscale keys) on every line, comments included.
SECRET_NAME_RE='password|passphrase|passwd|psk|secret|token|privatekey|private_key|authkey|apikey|api_key|sharedkey|credential'
# shellcheck disable=SC2016 # literal $ in crypt-hash prefixes
SECRET_VALUE_RE='\$(1|2[abxy]?|5|6|7|y|gy)\$|PRIVATE KEY|tskey-|[0-9A-Fa-f]{64}'
# Imports must stay relative inside the directory (modulesPath + "..." is fine).
EXTERNAL_RE='<[A-Za-z0-9._+/-]+>|\.\./|/etc/nixos|/nix/store|~/|fetchTarball|fetchGit|fetchurl|fetchzip|fetchFromGitHub|fetchTree|getFlake|storePath|home-manager'

die() {
  printf '  %s✗ %s%s\n' "$RED" "$1" "$RESET" >&2
  exit 1
}

# A partial "y" followed by EOF is not consent.
gate() {
  local reply=""
  printf '  %s? %s [y/N] %s' "$YELLOW" "$1" "$RESET"
  IFS= read -r reply || return 1
  [[ "$reply" =~ ^[Yy] ]]
}

# declined "what did not happen" "next step": a gate answered no (or EOF).
declined() {
  warn "Stopped: $1"
  note "$2"
  exit 1
}

# nixx: nix with flakes enabled for this invocation only. Every Nix and
# rebuild call passes --option builders '' so configured remote builders are
# never used silently.
nixx() {
  nix --extra-experimental-features 'nix-command flakes' --option builders '' "$@"
}

# locked_pkg ATTR: a package from the flake's locked nixpkgs, built for this
# machine; prints its store path.
locked_pkg() {
  nixx build --no-link --print-out-paths --impure --no-update-lock-file --no-write-lock-file --expr \
    "(builtins.getFlake \"git+file://$root\").inputs.nixpkgs.legacyPackages.\${builtins.currentSystem}.$1"
}

# github_accepts KEY: GitHub authenticates the private key KEY alone.
# accept-new trusts github.com's host key on first contact, as a first clone
# would. ssh -T exits 1 even on success, so the output decides.
github_accepts() {
  local out
  out="$(ssh -T -o BatchMode=yes -o ConnectTimeout=10 -o IdentitiesOnly=yes -o IdentityAgent=none \
    -o StrictHostKeyChecking=accept-new -i "$1" git@github.com 2>&1 || true)"
  case "$out" in *"successfully authenticated"*) return 0 ;; esac
  return 1
}

indent() { sed 's/^/    /'; }

# scan FILE ERE: line numbers of non-comment lines matching ERE. Never prints
# the matched text, so a secret value is not echoed.
scan() {
  grep -n -v -E '^[[:space:]]*(#|$)' "$1" | grep -i -E "$2" | cut -d: -f1 || true
}

# secret_lines FILE: line numbers that name or look like a secret.
secret_lines() {
  { scan "$1" "$SECRET_NAME_RE"; grep -n -E "$SECRET_VALUE_RE" "$1" | cut -d: -f1; } | sort -un || true
}

# external_lines FILE: line numbers referring outside the file's directory:
# EXTERNAL_RE, a quoted *.nix path, or an absolute path literal outside strings.
external_lines() {
  {
    scan "$1" "$EXTERNAL_RE"
    grep -n -v -E '^[[:space:]]*(#|$)' "$1" \
      | sed -E 's/modulesPath[[:space:]]*\+[[:space:]]*"[^"]*"//g' \
      | grep -E '"[^"]*\.nix"' | cut -d: -f1
    grep -n -v -E '^[[:space:]]*(#|$)' "$1" \
      | sed -E 's/"([^"\\]|\\.)*"//g; s/#.*$//' \
      | grep -E '(^|[^A-Za-z0-9._/+~-])/[A-Za-z0-9._+-]' | cut -d: -f1
  } | sort -un || true
}

# check_nix_tree DIR: DIR holds only regular, plainly named .nix files with no
# secret-looking or external lines. Sets $files; prints path[:line] problems
# (never the text) and returns 1 if there are any.
check_nix_tree() {
  local dir="$1" odd rel n hits=""
  odd="$(cd "$dir" && find . ! -name . \( -type l -o -name '.*' -o -name '*[!A-Za-z0-9._-]*' \
    -o ! -type d ! -name '*.nix' -o ! -type d ! -type f \) -print | sed 's|^\./||')"
  for rel in $odd; do hits="$hits$rel: not a regular .nix file (symlink, hidden or other file)
"; done
  files="$(cd "$dir" && find . -type f -name '*.nix' -print | sed 's|^\./||' | sort)"
  for rel in $files; do
    if ! [[ "$rel" =~ $NIX_FILE_RE ]] || [ ! -r "$dir/$rel" ]; then
      hits="$hits$rel: unsupported name or unreadable by $login
"
      continue
    fi
    for n in $(secret_lines "$dir/$rel"); do hits="$hits$rel:$n possible secret
"; done
    for n in $(external_lines "$dir/$rel"); do
      hits="$hits$rel:$n reference outside this directory, or its own Home Manager
"
    done
  done
  [ -n "$hits" ] || return 0
  printf '%s' "$hits" | indent
  return 1
}

# installed_state_version DIR: the single literal system.stateVersion in DIR.
installed_state_version() {
  find "$1" -type f -name '*.nix' -exec grep -h -E \
    '^[[:space:]]*system\.stateVersion[[:space:]]*=[[:space:]]*"[0-9]+\.[0-9]+"' {} + \
    | sed -E 's/.*"([0-9]+\.[0-9]+)".*/\1/' | sort -u || true
}

# ── Stage 1 ───────────────────────────────────────────────────────────────
stage "Inspect this machine"

[ "$(id -u)" != 0 ] || die "run as your normal login user, not root; activation elevates with sudo"
command -v nix >/dev/null 2>&1 \
  || die "nix not found. Install Nix first (https://nixos.org/download); this wizard does not install it."

case "$(uname -s)" in
  Darwin)
    os=darwin
    xcode-select -p >/dev/null 2>&1 \
      || die "Xcode Command Line Tools are missing (Git needs them). Run: xcode-select --install, then rerun."
    ;;
  Linux)
    grep -qx 'ID=nixos' "/etc/os-release" 2>/dev/null \
      || die "this Linux is not NixOS; only macOS and installed NixOS are supported (Raspberry Pi OS is not)."
    os=nixos
    command -v nixos-rebuild >/dev/null 2>&1 || die "nixos-rebuild not found on this NixOS system"
    ;;
  *) die "unsupported operating system: $(uname -s)" ;;
esac
command -v git >/dev/null 2>&1 || die "git not found. Install Git, then rerun."
case "$(uname -m)" in
  arm64 | aarch64) system="aarch64-$([ "$os" = darwin ] && echo darwin || echo linux)" ;;
  x86_64) system="x86_64-$([ "$os" = darwin ] && echo darwin || echo linux)" ;;
  *) die "unsupported architecture: $(uname -m)" ;;
esac

login="$(id -un)"
uid="$(id -u)"
home="${HOME:-}"
host_now="$(hostname)"
host_now="${host_now%%.*}"
root="$(cd -P "$(dirname "$0")/.." && pwd -P)"

[[ "$login" =~ ^[A-Za-z_][A-Za-z0-9._-]*$ ]] || die "login '$login' contains characters this wizard will not write into Nix"
[[ "$home" =~ $PATH_RE ]] && [ -d "$home" ] || die "HOME '$home' is not a plain existing absolute path"
[[ "$root" =~ $PATH_RE ]] || die "checkout path '$root' contains characters this wizard will not write into Nix"
[ "$(git -C "$root" rev-parse --show-toplevel 2>/dev/null)" = "$root" ] \
  || die "$root is not a Git checkout root; clone the dotfiles repository and run its scripts/onboard.sh"

say "Operating system  $os ($system)"
say "Account           $login (uid $uid), home $home"
say "Current hostname  $host_now"
say "Checkout          $root"
say "Just / NH         $(command -v just >/dev/null 2>&1 && echo present || echo absent) / $(command -v nh >/dev/null 2>&1 && echo present || echo absent) (not needed now)"
say "Git               $(git -C "$root" status --porcelain | wc -l | tr -d ' ') changed path(s), $(git -C "$root" diff --cached --name-only | wc -l | tr -d ' ') staged; all left as they are"
note "Evaluation may fetch locked inputs or build evaluation-time dependencies; full system build and activation have later gates."
gate "Continue with these facts?" || declined "nothing was changed." "Rerun bash scripts/onboard.sh when ready."

work="$(mktemp -d "${TMPDIR:-/tmp}/onboard.XXXXXX")"
trap 'rm -rf "$work"' EXIT
case "$(cd -P "$work" && pwd -P)/" in
  "$root"/*) die "temporary workspace is inside the checkout; set TMPDIR outside $root" ;;
esac

# ── Stage 2 ───────────────────────────────────────────────────────────────
stage "Select or register the target"

# Registration is the host file itself; see scripts/onboard-inventory.nix.
inventory="$(nixx eval --raw --impure --file "$root/scripts/onboard-inventory.nix" \
  --apply "f: f { dir = \"$root/modules/hosts\"; }")" \
  || die "could not read the host files in modules/hosts"
say "Registered targets (modules/hosts/):"
printf '%s\n' "$inventory" | indent
note "A target is one machine; login and architecture alone do not identify it."

suggest=""
if [[ "$host_now" =~ $NAME_RE ]]; then suggest="$host_now"; fi
ask target "Target name for this machine${suggest:+ [Enter: $suggest]}:"
[ -n "$target" ] || target="$suggest"
[[ "$target" =~ $NAME_RE ]] && [ "${#target}" -le 63 ] \
  || die "'$target' is not a valid target name (lowercase letters, digits, single hyphens)"

entry="$(printf '%s\n' "$inventory" | grep "^$target " || true)"
hostrel="modules/hosts/$target"
hostdir="$root/$hostrel"
if [ -n "$entry" ]; then
  mode=existing
  # shellcheck disable=SC2086 # entry is "name system login", all validated
  set -- $entry
  [ "$2" = "$system" ] || die "target $target is $2 but this machine is $system; nothing was changed"
  [ "$3" = "$login" ] || die "target $target expects login '$3' but you are '$login'; nothing was changed"
  say "Reusing registered target $target ($system, login $login)."
  if [ "$target" != "$host_now" ]; then
    warn "This machine is named '$host_now', not '$target'. Activating replaces its system configuration with $target's."
    gate "Is this machine really $target?" || declined "nothing was changed." "Rerun and choose (or register) this machine's own target."
  fi
else
  mode=new
  [ ! -e "$hostdir" ] && [ ! -L "$hostdir" ] && [ ! -e "$hostdir.nix" ] && [ ! -L "$hostdir.nix" ] \
    || die "$hostrel exists but does not register hosts.$target (partial earlier run?). Review it, then move it away or fix it by hand; nothing was changed."
  [ "$root" = "$home/dotfiles" ] \
    || die "a new home uses the checkout at $home/dotfiles, but this is $root. Clone or move it there (without overwriting another checkout), then rerun."
  say "New target $target ($system, login $login). Nothing is written before stage 4."
fi

# ── Stage 3 ───────────────────────────────────────────────────────────────
stage "Preserve the current installation"

automigrate=no
src="/etc/nixos"
if [ "$mode" = existing ]; then
  say "Reusing $hostrel; the installed configuration is not re-imported or overwritten."
elif [ "$os" = nixos ]; then
  if [ -L "$src" ] || [ ! -d "$src" ] || [ ! -f "$src/configuration.nix" ]; then
    die "$src is not a plain directory with configuration.nix; only a conventional /etc/nixos is migrated. Register this machine by copying a host file under modules/hosts/."
  fi
  [ ! -e "$src/flake.nix" ] \
    || die "$src/flake.nix is an independent flake with its own inputs; port it into $hostrel by hand instead."
  if ! check_nix_tree "$src"; then
    note "Nothing was copied. Only regular .nix files with relative imports are"
    note "migrated, and no password, key or token settings (even hashed or in a"
    note "file). Remove those from $src yourself (set passwords with passwd), or"
    note "write $hostrel by hand. Then rerun."
    die "the configuration has files or lines that must not be copied into the repository unreviewed"
  fi
  installed_state="$(installed_state_version "$src")"
  [[ "$installed_state" =~ $VERSION_RE ]] \
    || die "expected exactly one literal system.stateVersion in $src, found '${installed_state:-none}'; register by hand"
  say "Files to preserve verbatim under $hostrel/_installed/:"
  for rel in $files; do say "  $rel ($(wc -l <"$src/$rel" | tr -d ' ') lines)"; done
  say "Boot, disk, account, network and desktop lines they declare:"
  for rel in $files; do
    grep -n -v -E '^[[:space:]]*(#|$)' "$src/$rel" \
      | grep -E 'stateVersion|boot\.loader|fileSystems|luks|swapDevices|hostName|networkmanager|users\.users|xserver|displayManager|desktopManager' \
      | sed "s|^|$rel:|" | indent || true
  done
  note "Keeps system.stateVersion $installed_state. $src itself is never modified."
  note "No extra backup is made. Keep $src, or back it up yourself before deleting it."
  gate "Include these files in the repository, leaving the originals untouched?" \
    || declined "nothing was copied or written." "Review $src, then rerun."
else
  if [ -e "/run/current-system" ] || [ -e "/etc/nix-darwin" ]; then
    die "an existing nix-darwin installation was found. It is not replaced automatically: port its configuration (and its system.stateVersion) into a hand-written $hostrel, then rerun."
  fi
  brew=""
  for b in "/opt/homebrew/bin/brew" "/usr/local/bin/brew"; do
    if [ -x "$b" ]; then brew="$b" && break; fi
  done
  if [ -n "$brew" ]; then
    warn "Homebrew at $brew is not managed by nix-homebrew yet."
    say "nix-homebrew stops activation unless allowed to migrate it (autoMigrate:"
    say "it deletes the Homebrew repository and keeps installed packages)."
    if gate "Set nix-homebrew.autoMigrate = true for $target?"; then
      automigrate=yes
    else
      note "Not set: activation will stop at nix-homebrew's check until you decide."
    fi
  else
    say "No existing nix-darwin or Homebrew found; nothing to preserve."
  fi
  note "The shared Mac policy zaps undeclared Homebrew packages; you will see the list before activation."
fi

# ── Stage 4 ───────────────────────────────────────────────────────────────
stage "Compose the Nix-owned baseline"

if [ "$mode" = existing ]; then
  say "$hostrel already composes its baseline; nothing is written."
else
  locked="$(nixx eval --raw --impure --no-update-lock-file --no-write-lock-file --expr "
    let
      f = builtins.getFlake \"git+file://$root\";
      darwin = f.inputs.nix-darwin.lib.darwinSystem { modules = [ { nixpkgs.hostPlatform = \"$system\"; } ]; };
    in (builtins.fromJSON (builtins.readFile (f.inputs.home-manager + \"/release.json\"))).release
      + \" \" + (if \"$os\" == \"darwin\" then toString darwin.config.system.maxStateVersion else \"-\")")" \
    || die "could not read the locked Home Manager / nix-darwin versions"
  hm_default="${locked% *}"
  darwin_state="${locked#* }"
  # An existing Home Manager home keeps its own state version. Its effective
  # value cannot be read reliably from files (imports, comments, unused
  # files), so the operator must type it; only a new home gets a default.
  hm_found=""
  for d in "$home/.config/home-manager" "$home/.config/nixpkgs"; do
    if [ -f "$d/home.nix" ] || [ -f "$d/flake.nix" ]; then hm_found="$hm_found $d"; fi
  done
  for p in "$home/.local/state/nix/profiles/home-manager" "/nix/var/nix/profiles/per-user/$login/home-manager"; do
    if [ -e "$p" ] || [ -L "$p" ]; then hm_found="$hm_found $p"; fi
  done
  say "home.stateVersion fixes Home Manager's compatibility defaults for this home."
  if [ -z "$hm_found" ]; then
    note "No existing Home Manager found: a new home defaults to the locked release."
    ask hm_state "Home Manager state version [Enter: $hm_default]:"
    [ -n "$hm_state" ] || hm_state="$hm_default"
  else
    warn "Existing Home Manager found ($hm_found ). Keep its home.stateVersion: look up the"
    warn "value that home actually uses (not a comment or unused file) and type it."
    ask hm_state "Type that home's exact home.stateVersion (no default; Enter stops):"
    [ -n "$hm_state" ] \
      || declined "nothing was written." "Find the home.stateVersion your existing Home Manager uses, then rerun."
  fi
  [[ "$hm_state" =~ $VERSION_RE ]] || die "'$hm_state' is not a Home Manager state version like 25.11"
  hm_ok="$(nixx eval --raw --impure --no-update-lock-file --no-write-lock-file --expr "
    let
      f = builtins.getFlake \"git+file://$root\";
      m = f.inputs.nixpkgs.lib.evalModules { modules = [ (f.inputs.home-manager + \"/modules/misc/version.nix\") ]; };
    in if m.options.home.stateVersion.type.check \"$hm_state\" then \"yes\" else \"no\"")" \
    || die "could not check home.stateVersion against the locked Home Manager"
  [ "$hm_ok" = yes ] || die "home.stateVersion $hm_state is not supported by the locked Home Manager"

  # One file registers the host: inventory facts, features, and the system
  # and home modules. A new Mac gets workstation desktop; a NixOS machine
  # gets workstation, and its other roles are added to the host file after.
  # The installed NixOS files go under _installed/, which import-tree skips
  # (they are NixOS modules, not flake modules).
  mkdir "$work/host"
  if [ "$os" = nixos ]; then
    for rel in $files; do
      mkdir -p "$work/host/_installed/$(dirname "$rel")"
      cp "$src/$rel" "$work/host/_installed/$rel"
    done
    features="workstation"
  else
    features="workstation desktop"
  fi
  {
    if [ "$os" = nixos ]; then
      echo "# Generated by scripts/onboard.sh: the installed configuration (boot, disks,"
      echo "# users, network, desktop, system.stateVersion) kept verbatim in ./_installed,"
      echo "# plus the onboarding features and this account's facts."
    else
      echo "# Generated by scripts/onboard.sh for a fresh nix-darwin install."
    fi
    echo "{ config, ... }:"
    echo "{"
    echo "  hosts.\"$target\" = {"
    echo "    system = \"$system\";"
    echo "    login = \"$login\";"
    echo "    features = with config.features; [ $features ];"
    echo
    echo "    $os ="
    echo "      { host, ... }:"
    echo "      {"
    if [ "$os" = nixos ]; then
      echo "        imports = [ ./_installed/configuration.nix ];"
    else
      echo "        # First nix-darwin release on this Mac; read the changelog before changing."
      echo "        system.stateVersion = $darwin_state;"
    fi
    echo
    echo "        users.users.\${host.login} = {"
    echo "          uid = $uid;"
    echo "          home = \"$home\";"
    echo "        };"
    [ "$automigrate" = no ] || { echo; echo "        nix-homebrew.autoMigrate = true;"; }
    echo "      };"
    echo
    echo "    homeManager.home.stateVersion = \"$hm_state\";"
    echo "  };"
    echo "}"
  } >"$work/host/default.nix"

  say "$hostrel/default.nix:"
  indent <"$work/host/default.nix"
  [ "$os" = darwin ] || say "$hostrel/_installed/: $(printf '%s\n' "$files" | tr '\n' ' ')(verbatim copies)"
  note "No packages are listed here: they come from the selected features."
  gate "Write these files?" \
    || declined "nothing was written." "Rerun bash scripts/onboard.sh when ready."

  mkdir "$hostdir" || die "$hostrel appeared meanwhile; nothing was written"
  cp -R "$work/host/." "$hostdir/"
  say "Wrote $hostrel, which registers $target."
fi

# This login's own SSH key, for machines without 1Password's agent. Asked,
# not inferred: a new host has only its bootstrap roles so far. sshKey is
# written now so the host file is complete when committed; GitHub gets the
# key after activation (stage 7), because a gh login before it would leave a
# gh config file that Home Manager then refuses to replace.
sshkey="$home/.ssh/id_ed25519"
ssh_setup=no
say "SSH key: Macs and desktops with 1Password use its agent's key; other machines need their own."
if gate "Give this machine its own key ($sshkey, created if missing) for the fleet and GitHub?"; then
  ssh_setup=yes
  if [ ! -e "$sshkey" ]; then
    command -v ssh-keygen >/dev/null 2>&1 || die "ssh-keygen not found"
    [ -d "$home/.ssh" ] || mkdir -m 700 "$home/.ssh"
    ssh-keygen -q -t ed25519 -N "" -C "$login@$target" -f "$sshkey" </dev/null || die "could not create $sshkey"
  fi
  # From the private half, like the host key: a stale .pub would publish the wrong key.
  sshpub="$(ssh-keygen -y -f "$sshkey" | cut -d' ' -f1,2)"
  [[ "$sshpub" =~ ^ssh-ed25519\ [A-Za-z0-9+/=]+$ ]] || die "$sshkey is not a readable ed25519 key"
  [ -e "$sshkey.pub" ] || printf '%s %s\n' "$sshpub" "$login@$target" >"$sshkey.pub"
  hostfile="$hostdir/default.nix"
  [ -f "$hostfile" ] || hostfile="$hostdir.nix"
  sshline="    sshKey = \"$sshpub\";"
  current="$(grep -E '^[[:space:]]*sshKey[[:space:]]*=' "$hostfile" || true)"
  if [ "$current" = "$sshline" ]; then
    say "$hostrel already declares this key."
  elif [ -n "$current" ]; then
    warn "$hostrel declares a different sshKey; left unchanged. To use this key instead, set:"
    note "$sshline"
  else
    say "Adds to ${hostfile#"$root/"}, after its login line:"
    note "$sshline"
    if gate "Write it?"; then
      awk -v add="$sshline" -v after="    login = \"$login\";" \
        '{ print } $0 == after && !done { print add; done = 1 }' "$hostfile" >"$work/hostfile"
      if grep -qxF "$sshline" "$work/hostfile"; then
        cat "$work/hostfile" >"$hostfile"
        say "Declared the key in $hostrel."
      else
        warn "No '    login = \"$login\";' line in ${hostfile#"$root/"}; add the line above by hand."
      fi
    else
      note "Not written; other machines won't accept this key until sshKey is set."
    fi
  fi
fi

# ── Stage 5 ───────────────────────────────────────────────────────────────
stage "Review and evaluate"

untracked="$(git -C "$root" ls-files --others --exclude-standard -- "$hostrel" "$hostrel.nix")"
if [ -n "$untracked" ]; then
  # Offer only files this wizard generates, revalidated now: a resumed run may
  # find later edits, and anything else in the directory is left alone.
  unknown="" wrappers="" installed_untracked=no
  while IFS= read -r f; do
    case "$f" in
      "$hostrel/default.nix" | "$hostrel.nix") wrappers="$wrappers $f" ;;
      "$hostrel/_installed/"*.nix) installed_untracked=yes ;;
      *) unknown="$unknown$f
" ;;
    esac
    if [ -L "$root/$f" ] || [ ! -f "$root/$f" ]; then unknown="$unknown$f
"; fi
  done <<EOF
$untracked
EOF
  if [ -n "$unknown" ]; then
    printf '%s' "$unknown" | sort -u | indent
    die "$hostrel has untracked paths this wizard does not generate; move them out of the checkout (or review and track them yourself), then rerun. Nothing was staged."
  fi
  if [ "$installed_untracked" = yes ] && ! check_nix_tree "$hostdir/_installed"; then
    die "$hostrel/_installed has files or lines that must not be tracked unreviewed; fix them, then rerun. Nothing was staged."
  fi
  hits=""
  for f in $wrappers; do
    for n in $(secret_lines "$root/$f"); do hits="$hits$f:$n possible secret
"; done
  done
  if [ -n "$hits" ]; then
    printf '%s' "$hits" | indent
    die "$hostrel has lines that must not be tracked unreviewed; fix them, then rerun. Nothing was staged."
  fi
  say "Git-backed flakes ignore untracked files. Not yet tracked:"
  printf '%s\n' "$untracked" | indent
  say "Exact command: git add -- $(printf '%s\n' "$untracked" | tr '\n' ' ')"
  note "Only these paths are staged: no commit, push, or other files."
  gate "Run exactly that git add now?" \
    || declined "files are written but not tracked, so nothing was evaluated or built." \
      "Review them, run: git add -- $(printf '%s\n' "$untracked" | tr '\n' ' ')   then rerun bash scripts/onboard.sh."
  printf '%s\n' "$untracked" | while IFS= read -r f; do git -C "$root" add -- "$f"; done \
    || die "git add failed; nothing was evaluated or built"
fi

say "Evaluating $target (no full-system build or activation)..."
# shellcheck disable=SC2016
facts="$(nixx eval --raw --no-update-lock-file --no-write-lock-file "$root#hosts.$target" \
  --apply 'h: "${h.system}\n${h.login}\n${toString h.uid}\n${h.dotfiles}"')" \
  || die "evaluation failed (see above); nothing was built or activated. Fix $hostrel, then rerun."
{
  IFS= read -r want_system
  IFS= read -r want_login
  IFS= read -r want_uid
  IFS= read -r want_dotfiles
} <<EOF
$facts
EOF
kind=nixosConfigurations
[ "$os" = nixos ] || kind=darwinConfigurations
# shellcheck disable=SC2016
summary="$(nixx eval --raw --no-update-lock-file --no-write-lock-file "$root#$kind.$target.config" --apply "cfg: let
    hm = cfg.home-manager.users.\"$login\";
    yn = b: if b then \"yes\" else \"no\";
    line = k: v: k + \"=\" + v + \"\\n\";
    names = map (p: p.pname or \"\") (hm.home.packages ++ cfg.environment.systemPackages);
    nixos = \"$os\" == \"nixos\";
  in
    line \"drv\" cfg.system.build.toplevel.drvPath
    + line \"stateVersion\" (toString cfg.system.stateVersion)
    + line \"hostName\" cfg.networking.hostName
    + line \"home\" (toString cfg.users.users.\"$login\".home)
    + line \"hmStateVersion\" hm.home.stateVersion
    + line \"nh\" (yn ((cfg.programs.nh.enable or false) || hm.programs.nh.enable))
    + line \"just\" (yn (builtins.elem \"just\" names))
    + (if nixos then
        line \"bootLoader\" (if cfg.boot.loader.systemd-boot.enable then \"systemd-boot\" else if cfg.boot.loader.grub.enable then \"grub\" else \"other\")
        + line \"fileSystems\" (toString (builtins.attrNames cfg.fileSystems))
        + line \"luks\" (toString (builtins.attrNames cfg.boot.initrd.luks.devices))
        + line \"networkmanager\" (yn cfg.networking.networkmanager.enable)
        + line \"graphical\" (yn (cfg.services.xserver.enable || cfg.services.displayManager.enable))
      else \"\")
    + \"@files\\n\"
    + builtins.concatStringsSep \"\" (map (f: (if f.recursive then \"r \" else \"f \") + f.target + \"\\n\")
        (builtins.filter (f: f.enable) (builtins.attrValues hm.home.file)))
    + \"@brewfile\\n\" + (if nixos then \"\" else cfg.homebrew.brewfile)")" \
  || die "evaluation failed (see above); nothing was built or activated. Fix $hostrel, then rerun."

ev_drv="" ev_stateVersion="" ev_hostName="" ev_home="" ev_hmStateVersion="" ev_nh="" ev_just=""
ev_bootLoader="" ev_fileSystems="" ev_luks="" ev_networkmanager="" ev_graphical=""
section=facts
targets=""
brewfile=""
while IFS= read -r l; do
  case "$section:$l" in
    *:@files) section=files ;;
    *:@brewfile) section=brewfile ;;
    facts:*=*)
      [[ "${l%%=*}" =~ ^[A-Za-z]+$ ]] || die "unexpected evaluation output: $l"
      printf -v "ev_${l%%=*}" '%s' "${l#*=}"
      ;;
    files:*) targets="$targets$l
" ;;
    brewfile:*) brewfile="$brewfile$l
" ;;
  esac
done <<EOF
$summary
EOF

say "Evaluated $target:"
say "  $want_system, login $want_login uid $want_uid, home $ev_home, checkout $want_dotfiles"
say "  hostname $ev_hostName; system.stateVersion $ev_stateVersion; home.stateVersion $ev_hmStateVersion"
[ "$os" = darwin ] || say "  boot $ev_bootLoader; filesystems $ev_fileSystems; LUKS ${ev_luks:-none}; NetworkManager $ev_networkmanager; graphical $ev_graphical"
say "  NH $ev_nh, Just $ev_just; system derivation $ev_drv"
[ "$want_system" = "$system" ] || die "evaluated platform $want_system is not $system"
[ "$want_login" = "$login" ] || die "evaluated login $want_login is not $login"
[ "$want_uid" = "$uid" ] || die "evaluated uid '$want_uid' is not your uid $uid; set users.users.<login>.uid in $hostrel"
[ "$ev_home" = "$home" ] || die "evaluated home $ev_home is not your home $home"
[ "$want_dotfiles" = "$root" ] || die "evaluated checkout $want_dotfiles is not this checkout $root"
[ "$ev_hostName" = "$target" ] || die "evaluated hostname $ev_hostName is not $target"
[ "$ev_nh" = yes ] && [ "$ev_just" = yes ] || die "the evaluated baseline lacks NH or Just, so 'just switch' would not work"
if [ -d "$hostdir/_installed" ]; then
  kept="$(installed_state_version "$hostdir/_installed")"
  [ "$ev_stateVersion" = "$kept" ] \
    || die "evaluated system.stateVersion $ev_stateVersion differs from the installed configuration's $kept"
fi

# Home Manager refuses to replace files it does not own; list them now.
collisions=""
while read -r kind_flag t; do
  [ -n "$t" ] || continue
  p="$home/$t"
  if [ -L "$p" ]; then
    case "$(readlink "$p")" in /nix/store/*-home-manager-files/*) continue ;; esac
  elif [ ! -e "$p" ] || { [ -d "$p" ] && [ "$kind_flag" = r ]; }; then
    continue
  fi
  collisions="$collisions$p
"
done <<EOF
$targets
EOF
if [ -n "$collisions" ]; then
  printf '%s' "$collisions" | indent
  note "Home Manager will not overwrite these. Move each aside yourself, e.g."
  first="${collisions%%
*}"
  note "mv $first $first.before-dotfiles (pick a name that is not already taken),"
  note "then rerun. Nothing was built or activated."
  die "existing files occupy paths Home Manager manages"
fi
say "No unmanaged files in Home Manager's way."

# sops-nix decrypts the target's secrets with this machine's SSH host key at
# activation. If it can't, it publishes none of them and the switch fails
# partway (neither OS rolls back), so access is proven before building.
hostkey=/etc/ssh/ssh_host_ed25519_key
# read_sops_files: each sops file the target reads (store paths, so reread
# after a pull), one per line, into $sops_files.
read_sops_files() {
  sops_files="$(nixx eval --raw --no-update-lock-file --no-write-lock-file "$root#$kind.$target.config" --apply 'cfg:
      builtins.concatStringsSep "\n" (builtins.attrNames (builtins.listToAttrs (map
        (s: { name = toString s.sopsFile; value = null; }) (builtins.attrValues (cfg.sops.secrets or { })))))')" \
    || die "could not evaluate $target's secrets; nothing was built or activated"
}
# decrypts: every file in $sops_files decrypts with the host key alone. sudo
# reads the root-only key; env -i keeps the admin key and any personal age
# keys out of the test. Nothing decrypted is printed.
decrypts() {
  local f
  for f in $sops_files; do
    # shellcheck disable=SC2016
    sudo env -i HOME=/var/empty /bin/sh -c \
      'SOPS_AGE_KEY="$("$2" -private-key -i "$4")" exec "$1" decrypt "$3" >/dev/null 2>&1' \
      sh "$sops_bin" "$ssh_to_age" "$f" "$hostkey" || return 1
  done
}
read_sops_files
if [ -n "$sops_files" ]; then
  say "$target reads secrets, which this machine decrypts with its SSH host key."
  if [ ! -e "$hostkey" ]; then
    say "This machine has no $hostkey yet; sshd would only create it after activation."
    gate "Create it now? (sudo ssh-keygen -t ed25519 -N \"\" -f $hostkey)" \
      || declined "nothing was built or activated." "Create the host key, then rerun."
    command -v ssh-keygen >/dev/null 2>&1 || die "ssh-keygen not found"
    sudo ssh-keygen -q -t ed25519 -N "" -C "" -f "$hostkey" </dev/null || die "could not create $hostkey"
  fi
  sops_bin="$(locked_pkg sops)/bin/sops" || die "could not build sops"
  ssh_to_age="$(locked_pkg ssh-to-age)/bin/ssh-to-age" || die "could not build ssh-to-age"
  gate "Test-decrypt them now with sudo, using only the host key? (nothing is printed)" \
    || declined "nothing was built or activated." "Rerun when you're ready to check secrets access."
  # From the private half, which is what decrypts; a stale .pub would enrol
  # the wrong key.
  pubkey="$(sudo ssh-keygen -y -f "$hostkey" </dev/null | cut -d' ' -f1,2)"
  [[ "$pubkey" =~ ^ssh-ed25519\ [A-Za-z0-9+/=]+$ ]] || die "$hostkey is not a readable ed25519 key"
  say "Its public host key: $pubkey"
  if ! decrypts; then
    warn "This machine can't decrypt $(printf '%s\n' "$sops_files" | sed 's|^/nix/store/[^/]*/||' | tr '\n' ' ')yet."
    say "Enrol it from a machine with 1Password and this repo, then commit and push:"
    step "just secrets-enrol $target '$pubkey'"
    note "Copy the key from this screen or a trusted SSH session, not from ssh-keyscan."
    while :; do
      ask reply "Press Enter once it's pushed to pull (git pull --ff-only) and retest, or type q to stop:"
      [ "$reply" != q ] || declined "nothing was built or activated." "Enrol $target, then rerun."
      # --no-rebase: a rebasing pull refuses the staged host files.
      git -C "$root" pull --ff-only --no-rebase -q || warn "git pull failed; pull by hand, then press Enter."
      read_sops_files
      ! decrypts || break
      warn "Still can't decrypt. Check that the enrolment was pushed."
    done
  fi
  say "This machine can decrypt every secrets file $target reads."
fi

# ── Stage 6 ───────────────────────────────────────────────────────────────
stage "Build, then activate"

gate "Build $target now? (as $login; downloads/builds packages; activates nothing)" \
  || declined "nothing was built or activated." "Rerun bash scripts/onboard.sh to build."
if [ "$os" = nixos ]; then
  (cd "$work" && nixos-rebuild build --flake "$root#$target" --option builders '' --no-update-lock-file --no-write-lock-file) \
    || die "build failed; nothing was activated and $hostrel is kept. Fix it, then rerun."
  help="$(env MANPAGER=cat nixos-rebuild --help 2>/dev/null || true)"
  if printf '%s\n' "$help" | grep -q -E -- '(^|[^-a-z])--sudo([^-a-z]|$)'; then
    elevate=--sudo
  elif printf '%s\n' "$help" | grep -q -- '--use-remote-sudo'; then
    elevate=--use-remote-sudo
  else
    die "this nixos-rebuild documents neither --sudo nor --use-remote-sudo; activate by hand: sudo nixos-rebuild switch --flake $root#$target --option builders \"\" --no-update-lock-file --no-write-lock-file"
  fi
  activate="nixos-rebuild switch $elevate --flake $root#$target --option builders \"\" --no-update-lock-file --no-write-lock-file"
  say "Built. Activation runs: $activate"
  say "It changes the running system now and makes it the boot default."
  note "('test' is not a dry run either: it also changes the live system.)"
  note "The previous generation stays in the boot menu; sudo nixos-rebuild switch --rollback"
  note "returns to it, but cannot undo data changes. Nothing reboots or garbage-collects."
else
  nixx build --no-update-lock-file --no-write-lock-file --out-link "$work/result" "$root#darwinConfigurations.$target.system" \
    || die "build failed; nothing was activated and $hostrel is kept. Fix it, then rerun."
  out="$(readlink "$work/result")"
  activate="sudo $out/sw/bin/darwin-rebuild switch --flake $root#$target --option builders \"\" --no-update-lock-file --no-write-lock-file"
  say "Built. Activation runs: $activate"
  say "Homebrew after activation (declared in Nix):"
  printf '%s' "$brewfile" | grep -E '^(tap|brew|cask|mas) ' | indent || true
  brew="$(command -v brew || true)"
  for b in "/opt/homebrew/bin/brew" "/usr/local/bin/brew"; do
    if [ -z "$brew" ] && [ -x "$b" ]; then brew="$b"; fi
  done
  if [ -n "$brew" ]; then
    say "Installed now:"
    { "$brew" list --formula -1; "$brew" list --cask -1; } 2>/dev/null | indent || true
  fi
  warn "cleanup = zap: activation removes undeclared Homebrew packages and may delete associated cask data."
  note "nix-darwin refuses to overwrite unrecognised /etc files and says which to rename."
  note "Rollback: sudo darwin-rebuild --rollback. Nothing reboots or garbage-collects."
fi
if [ -n "${SSH_CONNECTION:-}" ]; then
  warn "You're onboarding over SSH. Once active, sshd accepts only the keys declared in"
  warn "modules/features/system/sshd.nix and hosts' sshKey: no passwords. Make sure you"
  warn "can log in with one of those, or keep this session open until you've checked."
fi
gate "Activate $target on this machine now?" \
  || declined "built but not activated." "Rerun this wizard to activate later; temporary result links are removed on exit."
if [ "$os" = nixos ]; then
  nixos-rebuild switch "$elevate" --flake "$root#$target" --option builders '' --no-update-lock-file --no-write-lock-file \
    || die "activation failed: setup is NOT complete. $hostrel is kept and the previous generation is still bootable; fix the error above, then rerun."
else
  sudo "$out/sw/bin/darwin-rebuild" switch --flake "$root#$target" --option builders '' --no-update-lock-file --no-write-lock-file \
    || die "activation failed: setup is NOT complete. $hostrel is kept; fix the error above, then rerun."
fi

# ── Stage 7 ───────────────────────────────────────────────────────────────
stage "Verify and hand off"

problems=""
now="$(hostname)"
now="${now%%.*}"
[ "$now" = "$target" ] || problems="${problems}hostname is '$now', expected '$target'
"
[ "$(id -un)" = "$login" ] && [ "$(id -u)" = "$uid" ] || problems="${problems}account changed from $login ($uid)
"
for tool in just nh; do
  if [ ! -x "/etc/profiles/per-user/$login/bin/$tool" ] && [ ! -x "/run/current-system/sw/bin/$tool" ]; then
    problems="${problems}$tool is not in the new profile
"
  fi
done
if [ -n "$problems" ]; then
  printf '%s' "$problems" | indent
  die "activation ran but verification is incomplete; setup is NOT complete. Open a new login shell and check the items above, then rerun."
fi

# Failures here don't fail setup: the closing screen gives the commands.
github=skip
if [ "$ssh_setup" = yes ]; then
  github=no
  if github_accepts "$sshkey"; then
    github=yes
  elif gh="$(locked_pkg gh)/bin/gh"; then
    say "Adding $sshkey to GitHub with gh..."
    if ! "$gh" auth status -h github.com >/dev/null 2>&1; then
      note "gh signs in through your browser, then offers to upload $sshkey.pub: accept that."
      "$gh" auth login -h github.com -p ssh || true
    elif ! "$gh" ssh-key add "$sshkey.pub" --title "$target"; then
      # Logins without this scope can't add keys; refresh asks for it in the browser.
      "$gh" auth refresh -h github.com -s admin:public_key \
        && "$gh" ssh-key add "$sshkey.pub" --title "$target" || true
    fi
    ! github_accepts "$sshkey" || github=yes
  fi
fi

_clear
printf '\n%s%s  ✓ Setup complete%s\n\n' "$BOLD" "$GREEN" "$RESET"
say "$target is active for $login. Next:"
step "Open a new login shell (or log out and in) so the new PATH and shell apply."
step "From now on: cd $root && just switch"
step "Reboot when convenient and check login and network (NixOS: also boot menu and disk unlock)."
if [ "$os" = nixos ] && [ "$mode" = new ]; then
  step "Keep /etc/nixos as your recovery copy; back it up yourself before deleting it."
fi
if [ "$github" = yes ]; then
  step "GitHub accepts $sshkey."
elif [ "$github" = no ]; then
  warn "GitHub doesn't accept $sshkey yet: gh auth login -p ssh, or gh ssh-key add $sshkey.pub --title $target"
fi
step "Commit $hostrel when you are satisfied (not done for you)."
if [ "$ssh_setup" = yes ]; then
  step "Once it's pushed, just switch the other machines so they accept this machine's key."
fi
