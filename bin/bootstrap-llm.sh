#!/usr/bin/env bash
# LLM-assisted bootstrap for this Darwin/Home-Manager repo
# Usage: bin/bootstrap-llm.sh [--model MODEL] [--dry-run] [--no-new-machine] [--hostname NAME] [--username NAME]
# Requires: curl, jq, OPENAI_API_KEY in env (you can paste it interactively)

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

MODEL_DEFAULT="gpt-4o-mini"
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
  --model MODEL          OpenAI model (default: ${MODEL_DEFAULT})
  --dry-run              Do not write files; just print planned actions
  --no-new-machine       Skip calling bin/new-machine.sh
  --hostname NAME        Explicit machine hostname key (e.g., macbook-pro)
  --username NAME        Username for home path (defaults to current user)

Notes:
- If OPENAI_API_KEY is not set, you'll be guided to obtain one and may paste it securely for this run.
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
info "OpenAI model: $MODEL"
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

# API key guidance and capture (no storage), if absent
if [[ -z "${OPENAI_API_KEY:-}" ]]; then
  warn "OPENAI_API_KEY is not set."
  printf "\nTo use LLM assistance, you need an OpenAI API key.\n"
  printf "Get a key here: https://platform.openai.com/api-keys\n"
  printf "Docs: https://platform.openai.com/docs/quickstart\n\n"
  if [[ $GUM_PRESENT -eq 1 ]]; then
    if confirm "Open browser to create an API key now?"; then
      open "https://platform.openai.com/api-keys" >/dev/null 2>&1 || true
    fi
    local_key=$(prompt_secret "Paste your OpenAI API key (kept only for this run, not stored)")
    if [[ -n "$local_key" ]]; then
      export OPENAI_API_KEY="$local_key"
      success "API key captured for this run only."
    else
      error "No API key provided. You can set it later and re-run."
      printf "Example (replace with your secret):\n  export OPENAI_API_KEY=\"{{OPENAI_API_KEY}}\"\n"
      exit 1
    fi
  else
    printf "Set it in your shell and re-run, e.g.:\n  export OPENAI_API_KEY=\"{{OPENAI_API_KEY}}\"\n\n"
    exit 1
  fi
fi

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

# Compose the prompt for OpenAI to produce a JSON plan
read -r -d '' SYS_MSG <<'SYS'
You are an expert assistant helping initialize a nix-darwin + home-manager repo for macOS.
Return ONLY minified JSON that matches the following schema:
{
  "hostname_key": "string",                 // a safe key like "macbook-pro"
  "username": "string",                     // user name
  "machine_display_name": "string",         // pretty display name
  "advice": "string",                        // short guidance for the user
  "host_overrides": "string",                // Nix snippet to paste into hosts/<key>/default.nix
  "home_overrides": "string",                // Nix snippet to paste into home/<user>/<key>/default.nix
  "packages": ["string"],                    // suggested pkgs for home.packages
  "next_steps": ["string"]                   // actionable steps
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

header "Calling OpenAI for a tailored plan"

OPENAI_URL="${OPENAI_API_BASE:-https://api.openai.com}/v1/chat/completions"

REQ=$(jq -n \
  --arg model "$MODEL" \
  --arg sys "$SYS_MSG" \
  --arg usr "$USER_MSG" \
  '{model:$model, temperature: 0.3, response_format:{type:"json_object"}, messages:[{role:"system",content:$sys},{role:"user",content:$usr}] }')

if [[ $DRY_RUN -eq 1 ]]; then
  info "DRY RUN: would POST to OpenAI"
  echo "$REQ" | jq 'del(.messages[].content) + {messages:[{"role":"system","content":"<snip>"},{"role":"user","content":"<snip>"}]}'
  exit 0
fi

if [[ $GUM_PRESENT -eq 1 ]]; then
  RAW=$(gum spin --spinner dot --title "Contacting OpenAI..." -- \
    curl -sS \
      -H "Authorization: Bearer ${OPENAI_API_KEY}" \
      -H "Content-Type: application/json" \
      -d "$REQ" \
      "$OPENAI_URL")
else
  RAW=$(curl -sS \
      -H "Authorization: Bearer ${OPENAI_API_KEY}" \
      -H "Content-Type: application/json" \
      -d "$REQ" \
      "$OPENAI_URL")
fi

# Extract content safely
if ! CONTENT=$(echo "$RAW" | jq -r '.choices[0].message.content' 2>/dev/null); then
  error "Failed to parse OpenAI response."; echo "$RAW"; exit 1
fi

# Validate JSON content
if ! echo "$CONTENT" | jq . >/dev/null 2>&1; then
  error "OpenAI did not return valid JSON. Raw content:"; echo "$CONTENT"; exit 1
fi

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
