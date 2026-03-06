#!/usr/bin/env bash
set -euo pipefail

APPDIR="$HOME/App"
BINDIR="$HOME/.local/bin"
BASHRC="$HOME/.bashrc"

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <program-name>"
    echo "Example: $0 code"
    exit 1
fi

PROGRAM_NAME="$1"
INSTALL_DIR="$APPDIR/$PROGRAM_NAME"
BIN_PATH="$BINDIR/$PROGRAM_NAME"

if [ -L "$BIN_PATH" ] || [ -e "$BIN_PATH" ]; then
    rm -f "$BIN_PATH"
    echo "Removed binary link: $BIN_PATH"
else
    echo "No binary link found: $BIN_PATH"
fi

if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    echo "Removed app folder: $INSTALL_DIR"
else
    echo "No app folder found: $INSTALL_DIR"
fi

if [ -f "$BASHRC" ]; then
    grep -v "alias $PROGRAM_NAME=" "$BASHRC" > "$BASHRC.tmp" || true
    mv "$BASHRC.tmp" "$BASHRC"
    echo "Removed alias entries from $BASHRC (if any)"
fi

unalias "$PROGRAM_NAME" 2>/dev/null || true
hash -r

echo "Uninstall finished."
echo "Run this now:"
echo "source ~/.bashrc"
