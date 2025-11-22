#!/usr/bin/env bash
# LLM-assisted bootstrap for this Darwin/Home-Manager repo
# Usage: bin/bootstrap-llm.sh [--model MODEL] [--dry-run] [--no-new-machine] [--hostname NAME] [--username NAME]
# Requires: curl, jq, Codex CLI (auto-installed via nixpkgs#codex if missing)

set -euo pipefail

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

here() { echo "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; }
ROOT_DIR="$(dirname "$(here)")"
TOOLS_DIR="$ROOT_DIR/.tools/gum"

info()    { printf "${BLUE}ℹ${NC} %s\n"   "$*"; }
warn()    { printf "${YELLOW}⚠${NC} %s\n" "$*"; }
error()   { printf "${RED}✗${NC} %s\n"    "$*"; }
success() { printf "${GREEN}✓${NC} %s\n" "$*"; }
header()  { printf "\n${BOLD}${CYAN}%s${NC}\n\n" "$*"; }

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    error "Missing dependency: $1"
    exit 1
  fi
}

# Optionally fetch a Gum binary for macOS arm64 and add it to PATH
ensure_gum() {
  if command -v gum >/dev/null 2>&1; then
    return 0
  fi
  local os arch
  os="$(uname -s 2>/dev/null || echo unknown)"
  arch="$(uname -m 2>/dev/null || echo unknown)"
  if [[ "$os" != "Darwin" || "$arch" != "arm64" ]]; then
    warn "Gum not found; pretty UI disabled (auto-install only supported on Darwin/arm64)."
    return 0
  fi
  mkdir -p "$TOOLS_DIR"
  local release api url tmp
  info "Gum not found — fetching latest release for Darwin/arm64..."
  api="https://api.github.com/repos/charmbracelet/gum/releases/latest"
  if ! release=$(curl -fsSL "$api" 2>/dev/null); then
    warn "Could not query GitHub for gum; falling back to plain prompts."
    return 0
  fi
  url=$(echo "$release" | jq -r '.assets[] | select(.name | test("Darwin_arm64.*\\.tar\\.gz$")) | .browser_download_url' | head -n1)
  if [[ -z "$url" || "$url" == "null" ]]; then
    warn "Could not locate Darwin/arm64 gum asset; falling back to plain prompts."
    return 0
  fi
  tmp="$(mktemp -d)"
  if curl -fsSL "$url" -o "$tmp/gum.tar.gz"; then
    tar -xzf "$tmp/gum.tar.gz" -C "$tmp" || true
    # Find extracted gum binary
    local bin
    bin=$(find "$tmp" -type f -name gum -perm -u+x | head -n1 || true)
    if [[ -n "$bin" ]]; then
      cp "$bin" "$TOOLS_DIR/gum"
      chmod +x "$TOOLS_DIR/gum"
      export PATH="$TOOLS_DIR:$PATH"
      success "Installed gum to $TOOLS_DIR"
    else
      warn "Failed to extract gum binary; continuing without pretty UI."
    fi
  else
    warn "Failed to download gum; continuing without pretty UI."
  fi
  rm -rf "$tmp"
}

MODEL_DEFAULT="gpt-5"
MODEL="$MODEL_DEFAULT"
DRY_RUN=0
SKIP_NEW_MACHINE=0
HOSTNAME_ARG=""
USERNAME_ARG=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --model) MODEL="$2"; shift 2;;
    --dry-run) DRY_RUN=1; shift;;
    --no-new-machine) SKIP_NEW_MACHINE=1; shift;;
    --hostname) HOSTNAME_ARG="$2"; shift 2;;
    --username) USERNAME_ARG="$2"; shift 2;;
    -h|--help)
      cat <<EOF
${BOLD}LLM-assisted bootstrap${NC}

Usage: $(basename "$0") [options]
  --model MODEL          Model for Codex (default: ${MODEL_DEFAULT})
  --dry-run              Do not write files; just print planned actions
  --no-new-machine       Skip calling bin/new-machine.sh
  --hostname NAME        Explicit machine hostname key (e.g., macbook-pro)
  --username NAME        Username for home path (defaults to current user)

Notes:
- This script uses the Codex CLI. If it's not installed, we'll attempt to install it automatically and Codex will guide setup.
- On macOS arm64, this script auto-installs a local gum binary for a nicer UI.
EOF
      exit 0;;
    *) warn "Unknown arg: $1"; shift;;
  esac
done

# Core dependencies
require_cmd curl
require_cmd jq

# Optionally set up gum and helpers
ensure_gum || true
if command -v gum >/dev/null 2>&1; then
  GUM_PRESENT=1
else
  GUM_PRESENT=0
fi

# Ensure Codex is installed (install via Nix if possible)
ensure_codex() {
  if command -v codex >/dev/null 2>&1; then
    return 0
  fi
  warn "Codex CLI not found; attempting installation via Nix..."
  if command -v nix >/dev/null 2>&1; then
    if [[ $GUM_PRESENT -eq 1 ]]; then
      gum spin --spinner dot --title "Installing Codex via nixpkgs#codex..." -- \
        nix profile install nixpkgs#codex >/dev/null 2>&1 || true
    else
      nix profile install nixpkgs#codex || true
    fi
  fi
  if ! command -v codex >/dev/null 2>&1; then
    error "Codex is still not available. Please install it (e.g., 'nix profile install nixpkgs#codex') and re-run."
    exit 1
  fi
}

confirm() {
  local prompt="$1"
  if [[ $GUM_PRESENT -eq 1 ]]; then
    gum confirm "$prompt"
    return $?
  else
    read -r -p "$prompt [Y/n] " reply
    reply=${reply:-Y}
    [[ "$reply" =~ ^[Yy]$ ]]
  fi
}

prompt_input() {
  local prompt="$1" default="${2:-}"
  if [[ $GUM_PRESENT -eq 1 ]]; then
    if [[ -n "$default" ]]; then
      gum input --placeholder "$default" || true
    else
      gum input || true
    fi
  else
    if [[ -n "$default" ]]; then
      read -r -p "$prompt ($default): " val
      echo "${val:-$default}"
    else
      read -r -p "$prompt: " val
      echo "$val"
    fi
  fi
}

prompt_secret() {
  local prompt="$1"
  if [[ $GUM_PRESENT -eq 1 ]]; then
    gum input --password --placeholder "sk-..." || true
  else
    # Fallback without echo hiding
    read -r -p "$prompt: " val
    echo "$val"
  fi
}

# Infer defaults
CURRENT_USER="$(id -un || whoami)"
USERNAME="${USERNAME_ARG:-$CURRENT_USER}"

# Best-effort computer name detection (macOS)
DETECTED_COMPUTER_NAME="$( (scutil --get ComputerName 2>/dev/null || hostname || echo unknown) | tr -d '\n' )"
DEFAULT_HOST_KEY="$(echo "$DETECTED_COMPUTER_NAME" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g' | sed -E 's/^-+|-+$//g' )"
HOST_KEY="${HOSTNAME_ARG:-$DEFAULT_HOST_KEY}"

header "LLM-assisted Darwin bootstrap"
info "Model: $MODEL"
info "Proposed hostname key: $HOST_KEY"
info "Username: $USERNAME"

if ! confirm "Proceed with these values?"; then
  HOST_KEY=$(prompt_input "Enter hostname key (e.g., macbook-pro)" "$HOST_KEY")
  USERNAME=$(prompt_input "Enter username" "$USERNAME")
fi

# Persist the selected hostname (as flake attribute format) for later helpers
# Transform HOST_KEY (e.g., macbook-pro) into display/system form (e.g., Macbook-Pro)
HOSTNAME_SYSTEM="$(echo "$HOST_KEY" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1' | sed 's/ /-/g')"
CFG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
mkdir -p "$CFG_HOME/darwin"
echo "$HOSTNAME_SYSTEM" > "$CFG_HOME/darwin/host"
success "Saved selected hostname to $CFG_HOME/darwin/host"

# Ensure Codex CLI is present (will attempt install) and let it guide setup as needed
ensure_codex

# Optionally create scaffolding using existing script
if [[ $SKIP_NEW_MACHINE -eq 0 ]]; then
  if [[ ! -x "$ROOT_DIR/bin/new-machine.sh" ]]; then
    error "Expected helper script not found: bin/new-machine.sh"
    exit 1
  fi
  header "Scaffolding machine configuration"
  if [[ $DRY_RUN -eq 1 ]]; then
    info "DRY RUN: would run: bin/new-machine.sh '$HOST_KEY' '$USERNAME'"
  else
    "$ROOT_DIR/bin/new-machine.sh" "$HOST_KEY" "$USERNAME"
  fi
else
  warn "Skipping creation of machine scaffolding (per --no-new-machine)"
fi

# Gather lightweight repo context for the LLM
header "Gathering context for LLM"
# List available modules and existing machines
HM_MODULES=$( (cd "$ROOT_DIR/modules/home-manager" 2>/dev/null && find . -maxdepth 2 -type d | sed 's#^./##' | sort) || true )
DARWIN_MODULES=$( (cd "$ROOT_DIR/modules/darwin" 2>/dev/null && find . -maxdepth 2 -type d | sed 's#^./##' | sort) || true )
EXISTING_HOSTS=$( (cd "$ROOT_DIR/hosts" 2>/dev/null && find . -maxdepth 1 -mindepth 1 -type d -print | sed 's#^./##' | sort) || true )
README_SUMMARY=$(sed -n '1,80p' "$ROOT_DIR/README.md" 2>/dev/null || true)

# Compose the prompt for Codex to produce a JSON plan
read -r -d '' SYS_MSG <<'SYS'
You are an expert assistant helping initialize a nix-darwin + home-manager repo for macOS.
Return ONLY minified JSON that matches the following schema:
{
  "hostname_key": "string",
  "username": "string",
  "machine_display_name": "string",
  "advice": "string",
  "host_overrides": "string",
  "home_overrides": "string",
  "packages": ["string"],
  "next_steps": ["string"]
}
Do not include backticks, markdown, or extra commentary.
SYS

# Build user content
read -r -d '' USER_MSG <<USER
Repository summary (truncated):
$README_SUMMARY

Existing hosts: [${EXISTING_HOSTS//\n/, }]
Darwin modules (top-level): [${DARWIN_MODULES//\n/, }]
Home-manager modules (top-level): [${HM_MODULES//\n/, }]

Inputs:
- desired hostname key: "$HOST_KEY"
- username: "$USERNAME"

Task:
1) Validate/adjust hostname_key and a pretty machine_display_name.
2) Recommend home_overrides and host_overrides snippets minimal yet useful.
3) Suggest a short package list for home.packages.
4) Provide 3–6 concrete next_steps to finish setup.
Keep output strictly JSON per schema.
USER

header "Calling Codex for a tailored plan"

# Prepare JSON Schema for strict validation via Codex
SCHEMA_FILE=$(mktemp -t bootstrap-llm-schema.XXXXXX.json)
cat >"$SCHEMA_FILE" <<'SCHEMA'
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "hostname_key",
    "username",
    "machine_display_name",
    "advice",
    "host_overrides",
    "home_overrides",
    "packages",
    "next_steps"
  ],
  "properties": {
    "hostname_key": {"type": "string"},
    "username": {"type": "string"},
    "machine_display_name": {"type": "string"},
    "advice": {"type": "string"},
    "host_overrides": {"type": "string"},
    "home_overrides": {"type": "string"},
    "packages": {"type": "array", "items": {"type": "string"}},
    "next_steps": {"type": "array", "items": {"type": "string"}}
  }
}
SCHEMA

PROMPT=$(cat <<EOF
System instructions:
$SYS_MSG

User context:
$USER_MSG
EOF
)

LAST_MSG_FILE=$(mktemp -t bootstrap-llm-last.XXXXXX.json)

if [[ $DRY_RUN -eq 1 ]]; then
  info "DRY RUN: would run Codex exec with schema enforcement"
  printf "Command: codex exec -m '%s' --sandbox read-only --skip-git-repo-check --output-schema '%s' -o '%s' -\n" "$MODEL" "$SCHEMA_FILE" "$LAST_MSG_FILE"
  printf "Prompt (snipped): System [%d chars], User [%d chars]\n" "${#SYS_MSG}" "${#USER_MSG}"
  rm -f "$SCHEMA_FILE" "$LAST_MSG_FILE"
  exit 0
fi

CODEX_CMD=(codex exec -m "$MODEL" --sandbox read-only --skip-git-repo-check --output-schema "$SCHEMA_FILE" -o "$LAST_MSG_FILE" -)

set +e
if [[ $GUM_PRESENT -eq 1 ]]; then
  printf "%s" "$PROMPT" | gum spin --spinner dot --title "Contacting Codex..." -- "${CODEX_CMD[@]}"
  rc=$?
else
  printf "%s" "$PROMPT" | "${CODEX_CMD[@]}"
  rc=$?
fi
set -e

if [[ $rc -ne 0 ]]; then
  error "Codex invocation failed (exit $rc). If this is a first run, try: codex login"
  rm -f "$SCHEMA_FILE" "$LAST_MSG_FILE"
  exit $rc
fi

# Extract content safely (Codex wrote the final message to LAST_MSG_FILE)
if ! CONTENT=$(cat "$LAST_MSG_FILE" 2>/dev/null); then
  error "Failed to read Codex output."; rm -f "$SCHEMA_FILE" "$LAST_MSG_FILE"; exit 1
fi

# Validate JSON content is well-formed
if ! echo "$CONTENT" | jq . >/dev/null 2>&1; then
  error "Codex did not return valid JSON. Raw content:"; echo "$CONTENT"; rm -f "$SCHEMA_FILE" "$LAST_MSG_FILE"; exit 1
fi

# Cleanup temp files used for the call
rm -f "$SCHEMA_FILE" "$LAST_MSG_FILE"

PLAN_JSON_PRETTY=$(echo "$CONTENT" | jq '.')

# Save plan near the generated machine dirs if present
PLAN_DIR="$ROOT_DIR/home/$USERNAME/$HOST_KEY"
mkdir -p "$PLAN_DIR"
PLAN_JSON_PATH="$PLAN_DIR/_llm_plan.json"
PLAN_MD_PATH="$PLAN_DIR/_llm_README.md"

echo "$PLAN_JSON_PRETTY" > "$PLAN_JSON_PATH"

HOST_OVERRIDES=$(echo "$CONTENT" | jq -r '.host_overrides // ""')
HOME_OVERRIDES=$(echo "$CONTENT" | jq -r '.home_overrides // ""')
ADVICE=$(echo "$CONTENT" | jq -r '.advice // ""')
NEXT_STEPS=$(echo "$CONTENT" | jq -r '.next_steps // [] | to_entries | map("- " + (.value)) | join("\n")')

cat > "$PLAN_MD_PATH" <<EOF
# LLM-assisted bootstrap notes

Advice
------
$ADVICE

Suggested host overrides (paste into hosts/$HOST_KEY/default.nix)
-----------------------------------------------------------------

```nix
$HOST_OVERRIDES
```

Suggested home overrides (paste into home/$USERNAME/$HOST_KEY/default.nix)
--------------------------------------------------------------------------

```nix
$HOME_OVERRIDES
```

Next steps
----------
$NEXT_STEPS
EOF

success "Wrote plan: ${PLAN_JSON_PATH}"
success "Wrote guide: ${PLAN_MD_PATH}"

header "Summary"
info "Hostname key: $HOST_KEY"
info "Username: $USERNAME"
info "Open the files above and apply overrides as desired."

printf "\nTo rebuild after edits, run:\n  darwin-rebuild switch --flake .#%s\n\n" "${DETECTED_COMPUTER_NAME:-$HOST_KEY}"
