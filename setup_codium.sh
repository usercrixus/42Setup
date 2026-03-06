#!/usr/bin/env bash
set -e

APPDIR="$HOME/App"
APPIMAGE="$APPDIR/VSCodium-1.110.01571.glibc2.30-x86_64.AppImage"
BINDIR="$HOME/.local/bin"
BASHRC="$HOME/.bashrc"

mkdir -p "$APPDIR"
mkdir -p "$BINDIR"

wget -O "$APPIMAGE" "https://release-assets.githubusercontent.com/github-production-release-asset/144590939/04ef533b-99ca-4f44-869d-4cbc91da9424?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-03-06T16%3A30%3A22Z&rscd=attachment%3B+filename%3DVSCodium-1.110.01571.glibc2.30-x86_64.AppImage&rsct=application%2Foctet-stream"

chmod +x "$APPIMAGE"

ln -sfn "$APPIMAGE" "$BINDIR/codium"

# ensure ~/.local/bin is in PATH
if ! grep -q '.local/bin' "$BASHRC" 2>/dev/null; then
cat >> "$BASHRC" <<'EOF'

# Add user local bin
export PATH="$HOME/.local/bin:$PATH"

# Use VSCodium when typing "code"
alias code="codium"
EOF
fi

export PATH="$HOME/.local/bin:$PATH"

echo "Installation finished."
echo "Open a new terminal and run:"
echo "codium ."
