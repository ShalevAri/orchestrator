#!/usr/bin/env bash

set -euo pipefail

readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

readonly GITHUB_USER="ShalevAri"
readonly GITHUB_REPO="orchestrator"
readonly REPO_URL="https://github.com/${GITHUB_USER}/${GITHUB_REPO}.git"
readonly GITHUB_TAG="v1.0.0"

readonly TARGET_DIR="${PWD}/.opencode"
readonly TEMP_DIR=$(mktemp -d)

error() { echo -e "${RED}ERR: $*${NC}"; }
warning() { echo -e "${YELLOW}WARNING: $*${NC}"; }
note() { echo -e "${BLUE}NOTE: $*${NC}"; }
success() { echo -e "${GREEN}$*${NC}"; }

cleanup() {
  note "Cleaning up temporary directory..."
  rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

check_git() {
  if ! command -v git &> /dev/null; then
    error "Git is required but not installed."
    exit 1
  fi
}

validate_repository() {
  if [ ! -d "$TEMP_DIR/dot_opencode" ]; then
    error "dot_opencode directory not found in repository"
    exit 1
  fi
}

prompt_user_choice() {
  local prompt="$1"
  local -n choices=$2
  local default_choice="${3:-1}"
  
  echo ""
  echo "$prompt"
  for i in "${!choices[@]}"; do
    echo "  $((i + 1))) ${choices[$i]}"
  done
  echo ""
  
  read -rp "Enter choice [1-${#choices[@]}]: " choice
  echo "${choice:-$default_choice}"
}

handle_existing_directory() {
  if [ ! -d "$TARGET_DIR" ]; then
    return 0
  fi
  
  warning "Installing/updating Orchestrator will override your existing .opencode directory and opencode.json file."
  warning "This is expected behavior."
  
  local options=("Abort" "Override" "Backup to .opencode.bak and install")
  local choice=$(prompt_user_choice "Please choose an option:" options)
  
  case $choice in
    1)
      note "Installation aborted. No changes were made."
      exit 0
      ;;
    2)
      warning "Overriding existing .opencode directory..."
      rm -rf "$TARGET_DIR"
      ;;
    3)
      local backup_dir="${TARGET_DIR}.bak"
      if [ -d "$backup_dir" ]; then
        warning "Backup directory $backup_dir already exists. Removing it..."
        rm -rf "$backup_dir"
      fi
      note "Backing up to $backup_dir..."
      mv "$TARGET_DIR" "$backup_dir"
      success "Backup created at $backup_dir"
      ;;
    *)
      error "Invalid choice. Aborting."
      exit 1
      ;;
  esac
}

clone_repository() {
  note "Installing version: $GITHUB_TAG"
  note "Cloning Orchestrator into temporary directory..."
  
  git clone --quiet --depth 1 --branch "$GITHUB_TAG" "$REPO_URL" "$TEMP_DIR" || {
    error "Failed to clone the Orchestrator repository"
    exit 1
  }
  
  validate_repository
}

select_provider() {
  local model_name="$1"
  local default_provider="$2"
  shift 2
  local providers=("$@")
  
  local options=()
  for provider in "${providers[@]}"; do
    if [ "$provider" == "$default_provider" ]; then
      options+=("$provider (default)")
    else
      options+=("$provider")
    fi
  done
  
  local choice=$(prompt_user_choice "Select provider for $model_name:" options)
  
  if [ "$choice" -ge 1 ] && [ "$choice" -le "${#providers[@]}" ]; then
    echo "${providers[$((choice - 1))]}"
  else
    warning "Invalid choice. Using $default_provider."
    echo "$default_provider"
  fi
}

get_provider_prefix() {
  local provider="$1"
  
  case "$provider" in
    "OpenCode Zen")
      echo "opencode/"
      ;;
    "Anthropic")
      echo "anthropic/"
      ;;
    "OpenAI")
      echo "openai/"
      ;;
    "Z.ai")
      echo "zai/"
      ;;
    "Other (specify manually)")
      read -rp "Enter provider prefix (e.g., 'custom/'): " custom_prefix
      echo "${custom_prefix:-opencode/}"
      ;;
    *)
      echo "opencode/"
      ;;
  esac
}

configure_per_model_providers() {
  note "Configuring per-model providers..."
  
  local claude_provider=$(select_provider "Claude models (claude-sonnet-4-5, claude-haiku-4-5)" "OpenCode Zen" "OpenCode Zen" "Anthropic")
  local claude_prefix=$(get_provider_prefix "$claude_provider")
  
  local gpt_provider=$(select_provider "GPT models (gpt-5-codex)" "OpenCode Zen" "OpenCode Zen" "OpenAI")
  local gpt_prefix=$(get_provider_prefix "$gpt_provider")
  
  local glm_provider=$(select_provider "GLM-4.6 models" "OpenCode Zen" "OpenCode Zen" "Z.ai")
  local glm_prefix=$(get_provider_prefix "$glm_provider")
  
  local qwen_provider=$(select_provider "Qwen3-Coder models" "OpenCode Zen" "OpenCode Zen" "Other (specify manually)")
  local qwen_prefix=$(get_provider_prefix "$qwen_provider")
  
  update_model_providers "$claude_prefix" "$gpt_prefix" "$glm_prefix" "$qwen_prefix"
  success "Updated all agent configurations with per-model providers"
}

configure_provider_mode() {
  local options=("OpenCode Zen for all models (default)" "Per-model provider configuration")
  local choice=$(prompt_user_choice "Select your preferred model provider configuration:" options)
  
  case $choice in
    1)
      note "Using OpenCode Zen provider for all models..."
      ;;
    2)
      configure_per_model_providers
      ;;
    *)
      warning "Invalid choice. Using OpenCode Zen for all models (default)."
      ;;
  esac
}

copy_opencode_directory() {
  note "Setting up .opencode directory..."
  cp -r "$TEMP_DIR/dot_opencode" "$TARGET_DIR" || {
    error "Failed to setup .opencode directory"
    exit 1
  }
}

update_model_providers() {
  local claude_prefix="$1"
  local gpt_prefix="$2"
  local glm_prefix="$3"
  local qwen_prefix="$4"
  
  note "Updating model providers..."
  
  find "$TARGET_DIR/agent" -name "*.md" -type f | while read -r agent_file; do
    if [[ "$OSTYPE" == "darwin"* ]]; then
      sed -i '' "s|^model: opencode/claude-|model: ${claude_prefix}claude-|g" "$agent_file"
      sed -i '' "s|^model: opencode/gpt-|model: ${gpt_prefix}gpt-|g" "$agent_file"
      sed -i '' "s|^model: opencode/glm-|model: ${glm_prefix}glm-|g" "$agent_file"
      sed -i '' "s|^model: opencode/qwen|model: ${qwen_prefix}qwen|g" "$agent_file"
    else
      sed -i "s|^model: opencode/claude-|model: ${claude_prefix}claude-|g" "$agent_file"
      sed -i "s|^model: opencode/gpt-|model: ${gpt_prefix}gpt-|g" "$agent_file"
      sed -i "s|^model: opencode/glm-|model: ${glm_prefix}glm-|g" "$agent_file"
      sed -i "s|^model: opencode/qwen|model: ${qwen_prefix}qwen|g" "$agent_file"
    fi
  done
}

copy_opencode_preset() {
  if [ -f "$TEMP_DIR/opencode.preset.json" ]; then
    note "Setting up opencode.json file..."
    cp "$TEMP_DIR/opencode.preset.json" "${PWD}/opencode.json" || {
      warning "Failed to setup opencode.json"
    }
  else
    warning "opencode.json preset file was not found in repository"
  fi
}

main() {
  check_git
  clone_repository
  handle_existing_directory
  copy_opencode_directory
  configure_provider_mode
  copy_opencode_preset
  success "Orchestrator setup complete!"
}

main
