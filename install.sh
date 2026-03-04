#!/usr/bin/env bash
set -euo pipefail

# Conductor Plugin Installer for Claude Code
# Usage: curl -fsSL https://raw.githubusercontent.com/leansii/conductor-claude/main/install.sh | bash

REPO="leansii/conductor-claude"
REPO_URL="https://github.com/${REPO}.git"
MARKETPLACE_NAME="conductor-marketplace"
PLUGIN_NAME="conductor"
INSTALL_DIR="${HOME}/.claude/marketplace/conductor-claude"

# --- Colors (only when outputting to a terminal) ---
if [ -t 1 ]; then
  BOLD='\033[1m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  RED='\033[0;31m'
  CYAN='\033[0;36m'
  RESET='\033[0m'
else
  BOLD='' GREEN='' YELLOW='' RED='' CYAN='' RESET=''
fi

info()  { printf "${CYAN}%s${RESET}\n" "$*"; }
ok()    { printf "${GREEN}%s${RESET}\n" "$*"; }
warn()  { printf "${YELLOW}%s${RESET}\n" "$*"; }
err()   { printf "${RED}%s${RESET}\n" "$*" >&2; }

# --- Header ---
printf "\n${BOLD}  Conductor Plugin Installer${RESET}\n"
printf "  Context-Driven Development for Claude Code\n\n"

# --- Prerequisites ---
if ! command -v claude &>/dev/null; then
  err "Error: 'claude' CLI not found."
  err "Install Claude Code first: https://docs.anthropic.com/en/docs/claude-code"
  exit 1
fi

if ! command -v git &>/dev/null; then
  err "Error: 'git' is required but not found."
  exit 1
fi

# --- Try CLI approach ---
cli_ok=false

info "Attempting CLI install..."
if claude plugin marketplace add "${REPO}" 2>/dev/null; then
  if claude plugin install "${PLUGIN_NAME}@${MARKETPLACE_NAME}" 2>/dev/null; then
    cli_ok=true
  fi
fi

# --- Fallback: clone and print manual instructions ---
if [ "$cli_ok" = false ]; then
  warn "CLI install not available — falling back to local clone."
  printf "\n"

  if [ -d "$INSTALL_DIR" ]; then
    info "Updating existing clone at ${INSTALL_DIR}..."
    git -C "$INSTALL_DIR" pull --ff-only 2>/dev/null || {
      warn "Pull failed — re-cloning..."
      rm -rf "$INSTALL_DIR"
      git clone --depth 1 "$REPO_URL" "$INSTALL_DIR"
    }
  else
    info "Cloning repository..."
    mkdir -p "$(dirname "$INSTALL_DIR")"
    git clone --depth 1 "$REPO_URL" "$INSTALL_DIR"
  fi

  printf "\n"
  ok "Repository cloned to ${INSTALL_DIR}"
  printf "\n"
  info "To finish setup, run these commands inside Claude Code:"
  printf "\n"
  printf "  ${BOLD}/plugin marketplace add %s${RESET}\n" "$INSTALL_DIR"
  printf "  ${BOLD}/plugin install %s@%s${RESET}\n" "$PLUGIN_NAME" "$MARKETPLACE_NAME"
  printf "\n"
fi

# --- Success ---
if [ "$cli_ok" = true ]; then
  printf "\n"
  ok "Conductor plugin installed successfully!"
fi

printf "\n${BOLD}Available commands:${RESET}\n"
printf "  /conductor:setup       Initialize Conductor in your project\n"
printf "  /conductor:newTrack    Create a new feature/bug track\n"
printf "  /conductor:implement   Execute tasks from a track's plan\n"
printf "  /conductor:status      Display project progress overview\n"
printf "  /conductor:revert      Git-aware revert of tracks/phases/tasks\n"
printf "  /conductor:review      Review completed track against guidelines\n"
printf "\n"
