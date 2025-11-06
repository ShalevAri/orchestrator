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
GITHUB_REPO="orchestrator"
REPO_URL="https://github.com/${GITHUB_USER}/${GITHUB_REPO}.git"
GITHUB_TAG="v1.0.0"

TARGET_DIR="${PWD}/.opencode"
TEMP_DIR=$(mktemp -d)

if ! command -v git &> /dev/null; then
    error "Git is required but not installed."
    exit 1
fi

cleanup() {
    note "Cleaning up temporary directory..."
    rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

note "Installing version: $GITHUB_TAG"

note "Cloning Orchestrator into temporary directory..."
git clone --quiet --depth 1 --branch "$GITHUB_TAG" "$REPO_URL" "$TEMP_DIR" || {
    error "Failed to clone the Orchestrator repository"
    exit 1
}

if [ ! -d "$TEMP_DIR/dot_opencode" ]; then
    error "dot_opencode directory not found in repository"
    exit 1
fi

if [ -d "$TARGET_DIR" ]; then
    if [ -d "$TEMP_DIR/dot_opencode_diff" ]; then
        note "Checking for local customizations..."

        if diff -rq "$TARGET_DIR" "$TEMP_DIR/dot_opencode_diff" > /dev/null 2>&1; then
            note "No customizations detected. Auto-upgrading..."
            rm -rf "$TARGET_DIR"
        else
            warning "Customizations detected!"
            echo ""
            echo "Your .opencode directory differs from the previous release."
            echo "Choose an option:"
            echo "  1) Abort (keep current setup)"
            echo "  2) Override (lose your customizations)"
            echo "  3) Backup to .opencode.bak and install new version"
            echo ""
            read -rp "Enter choice [1-3]: " choice

            case $choice in
                1)
                    note "Installation aborted. No changes were made."
                    exit 0
                    ;;
                2)
                    warning "Overriding your customizations..."
                    rm -rf "$TARGET_DIR"
                    ;;
                3)
                    BACKUP_DIR="${TARGET_DIR}.bak"
                    if [ -d "$BACKUP_DIR" ]; then
                        warning "Backup directory $BACKUP_DIR already exists. Removing it..."
                        rm -rf "$BACKUP_DIR"
                    fi
                    note "Backing up to $BACKUP_DIR..."
                    mv "$TARGET_DIR" "$BACKUP_DIR"
                    success "Backup created at $BACKUP_DIR"
                    ;;
                *)
                    error "Invalid choice. Aborting."
                    exit 1
                    ;;
            esac
        fi
    else
        warning "No baseline found for comparison!"
        echo ""
        echo "Your .opencode directory exists but cannot be checked for customizations."
        echo "Choose an option:"
        echo "  1) Abort (keep current setup)"
        echo "  2) Override (lose any customizations)"
        echo "  3) Backup to .opencode.bak and install new version"
        echo ""
        read -rp "Enter choice [1-3]: " choice

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
                BACKUP_DIR="${TARGET_DIR}.bak"
                if [ -d "$BACKUP_DIR" ]; then
                    warning "Backup directory $BACKUP_DIR already exists. Removing it..."
                    rm -rf "$BACKUP_DIR"
                fi
                note "Backing up to $BACKUP_DIR..."
                mv "$TARGET_DIR" "$BACKUP_DIR"
                success "Backup created at $BACKUP_DIR"
                ;;
            *)
                error "Invalid choice. Aborting."
                exit 1
                ;;
        esac
    fi
fi

note "Copying files to .opencode directory..."
cp -r "$TEMP_DIR/dot_opencode" "$TARGET_DIR" || {
    error "Failed to copy files"
    exit 1
}

success "Orchestrator setup complete!"
