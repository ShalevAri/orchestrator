#!/usr/bin/env bash

set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

error() { echo -e "${RED}ERR: $*${NC}"; }
warning() { echo -e "${YELLOW}WARNING: $*${NC}"; }
note() { echo -e "${BLUE}NOTE: $*${NC}"; }
success() { echo -e "${GREEN}$*${NC}"; }

GITHUB_USER="ShalevAri"
REPO_NAME="orchestrator"
RELEASE_TAG="v2.0.0"

GITHUB_REPO="${GITHUB_USER}/${REPO_NAME}"
RELEASE_URL="https://github.com/${GITHUB_REPO}/archive/refs/tags/${RELEASE_TAG}.tar.gz"
TEMP_DIR=$(mktemp -d)
TARGET_OPENCODE_DIR=".opencode"
TARGET_CONFIG_FILE="opencode.json"

BACKUP_DIR=".opencode-backup-$(date +%Y%m%d-%H%M%S)"

cleanup() {
  if [[ -d "$TEMP_DIR" ]]; then
    rm -rf "$TEMP_DIR"
  fi
}
trap cleanup EXIT

usage() {
  cat << EOF
Orchestrator Installation Script

This script installs the Orchestrator agent system for OpenCode.

Usage: $0 [OPTIONS]

Options:
  -f, --force         Overwrite existing files without prompting
  -b, --backup        Create backup before overwriting (default)
  -h, --help          Show this help message

Release Information:
  Repository: ${GITHUB_REPO}
  Tag: ${RELEASE_TAG}

EOF
}

FORCE_OVERWRITE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -f|--force)
      FORCE_OVERWRITE=true
      shift
      ;;
    -b|--backup)
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      error "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

download_release() {
  echo "" >&2
  note "Downloading release ${RELEASE_TAG} from ${GITHUB_REPO}..." >&2

  if ! curl -fsSL "$RELEASE_URL" -o "${TEMP_DIR}/release.tar.gz"; then
    error "Failed to download release from: $RELEASE_URL"
    exit 1
  fi

  success "Downloaded release archive" >&2

  note "Extracting archive..." >&2
  if ! tar -xzf "${TEMP_DIR}/release.tar.gz" -C "$TEMP_DIR"; then
    error "Failed to extract release archive"
    exit 1
  fi

  local extracted_dir="${TEMP_DIR}/${REPO_NAME}-${RELEASE_TAG#v}"

  if [[ ! -d "$extracted_dir" ]]; then
    error "Extracted directory not found: $extracted_dir"
    exit 1
  fi

  success "Extracted release files" >&2
  echo "$extracted_dir"
}

validate_sources() {
  local source_dir=$1
  local has_error=false

  if [[ ! -d "${source_dir}/dot_opencode" ]]; then
    error "Source directory not found: ${source_dir}/dot_opencode"
    has_error=true
  fi

  if [[ ! -f "${source_dir}/opencode.preset.json" ]]; then
    error "Source config file not found: ${source_dir}/opencode.preset.json"
    has_error=true
  fi

  if [[ "$has_error" == "true" ]]; then
    exit 1
  fi
}

check_existing_files() {
  local needs_action=false
  local opencode_exists=false
  local config_exists=false

  if [[ -e "$TARGET_OPENCODE_DIR" ]]; then
    opencode_exists=true
    needs_action=true
  fi

  if [[ -e "$TARGET_CONFIG_FILE" ]]; then
    config_exists=true
    needs_action=true
  fi

  if [[ "$needs_action" == "false" ]]; then
    return 0
  fi

  echo ""
  warning "The following files/directories already exist:"
  if [[ "$opencode_exists" == "true" ]]; then
    echo "  - $TARGET_OPENCODE_DIR"
  fi
  if [[ "$config_exists" == "true" ]]; then
    echo "  - $TARGET_CONFIG_FILE"
  fi
  echo ""

  if [[ "$FORCE_OVERWRITE" == "true" ]]; then
    note "Force mode enabled, will create backup and overwrite"
    return 0
  fi

  echo "Choose an action:"
  echo "  [b] Backup existing files and install (recommended)"
  echo "  [o] Overwrite without backup"
  echo "  [a] Abort installation"
  echo ""
  read -r -p "Your choice [b/o/a]: " choice

  case "$choice" in
    b|B|"")
      return 0
      ;;
    o|O)
      warning "Proceeding without backup"
      BACKUP_DIR=""
      return 0
      ;;
    a|A)
      note "Installation aborted by user"
      exit 0
      ;;
    *)
      error "Invalid choice: $choice"
      exit 1
      ;;
  esac
}

create_backup() {
  if [[ -z "$BACKUP_DIR" ]]; then
    return 0
  fi

  local backed_up=false

  if [[ -e "$TARGET_OPENCODE_DIR" ]] || [[ -e "$TARGET_CONFIG_FILE" ]]; then
    echo ""
    note "Creating backup in $BACKUP_DIR..."
    mkdir -p "$BACKUP_DIR"
    backed_up=true
  fi

  if [[ -e "$TARGET_OPENCODE_DIR" ]]; then
    mv "$TARGET_OPENCODE_DIR" "$BACKUP_DIR/"
    success "Backed up: $TARGET_OPENCODE_DIR -> $BACKUP_DIR/"
  fi

  if [[ -e "$TARGET_CONFIG_FILE" ]]; then
    mv "$TARGET_CONFIG_FILE" "$BACKUP_DIR/"
    success "Backed up: $TARGET_CONFIG_FILE -> $BACKUP_DIR/"
  fi

  if [[ "$backed_up" == "true" ]]; then
    echo ""
  fi
}

install_files() {
  local source_dir=$1

  echo "Installing Orchestrator..."
  echo ""

  note "Copying dot_opencode -> $TARGET_OPENCODE_DIR"
  cp -r "${source_dir}/dot_opencode" "$TARGET_OPENCODE_DIR"
  success "Installed: $TARGET_OPENCODE_DIR"

  note "Copying opencode.preset.json -> $TARGET_CONFIG_FILE"
  cp "${source_dir}/opencode.preset.json" "$TARGET_CONFIG_FILE"
  success "Installed: $TARGET_CONFIG_FILE"

  echo ""
  success "Installation complete! (${RELEASE_TAG})"
}

print_instructions() {
  echo ""
  note "Next steps:"
  echo "  1. Launch OpenCode: opencode"
  echo "  2. Select 'Orchestrator' as your primary agent"
  echo "  3. Start delegating tasks to specialized subagents!"
  echo ""

  if [[ -n "$BACKUP_DIR" ]] && [[ -d "$BACKUP_DIR" ]]; then
    note "Your previous configuration was backed up to: $BACKUP_DIR"
    echo ""
  fi
}

main() {
  echo ""
  echo "========================================"
  echo "  Orchestrator Installation"
  echo "========================================"
  echo ""
  note "Repository: ${GITHUB_REPO}"
  note "Release: ${RELEASE_TAG}"
  echo ""

  local source_dir
  source_dir=$(download_release)
  validate_sources "$source_dir"
  check_existing_files
  create_backup
  install_files "$source_dir"
  print_instructions
}

main
