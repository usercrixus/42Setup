#!/usr/bin/env bash
set -euo pipefail

APPDIR="$HOME/App"
BINDIR="$HOME/.local/bin"
BASHRC="$HOME/.bashrc"

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <tar.gz-url> <program-name>"
    echo "Example: $0 https://example.com/app.tar.gz code"
    exit 1
fi

URL="$1"
PROGRAM_NAME="$2"
ARCHIVE="$APPDIR/${PROGRAM_NAME}.tar.gz"
INSTALL_DIR="$APPDIR/$PROGRAM_NAME"
BIN_PATH="$BINDIR/$PROGRAM_NAME"

mkdir -p "$APPDIR"
mkdir -p "$BINDIR"

if command -v wget >/dev/null 2>&1; then
    wget -O "$ARCHIVE" "$URL"
elif command -v curl >/dev/null 2>&1; then
    curl -L -o "$ARCHIVE" "$URL"
else
    echo "Error: neither wget nor curl is installed."
    exit 1
fi

rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
tar -xzf "$ARCHIVE" --strip-components=1 -C "$INSTALL_DIR"

TARGET_BIN="$INSTALL_DIR/$PROGRAM_NAME"
if [ ! -x "$TARGET_BIN" ] && [ -x "$INSTALL_DIR/bin/$PROGRAM_NAME" ]; then
    TARGET_BIN="$INSTALL_DIR/bin/$PROGRAM_NAME"
fi

if [ ! -x "$TARGET_BIN" ]; then
    TARGET_BIN="$(find "$INSTALL_DIR" -maxdepth 2 -type f -perm -u+x | head -n 1 || true)"
fi

if [ -z "$TARGET_BIN" ] || [ ! -x "$TARGET_BIN" ]; then
    echo "Error: could not find an executable in $INSTALL_DIR"
    echo "Archive extracted, but symlink was not created."
    exit 1
fi

ln -sfn "$TARGET_BIN" "$BIN_PATH"

if [ -f "$BASHRC" ]; then
    grep -v "alias $PROGRAM_NAME=" "$BASHRC" > "$BASHRC.tmp" || true
    mv "$BASHRC.tmp" "$BASHRC"
fi

if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$BASHRC" 2>/dev/null; then
cat >> "$BASHRC" <<'EOF'

# Add user local bin
export PATH="$HOME/.local/bin:$PATH"
EOF
fi

export PATH="$HOME/.local/bin:$PATH"
unalias "$PROGRAM_NAME" 2>/dev/null || true
hash -r

rm -f "$ARCHIVE"

echo "Installation finished."
echo "Ensure ~/.local/bin is persisted in your PATH:"
echo "export PATH=\"\$HOME/.local/bin:\$PATH\""
echo "Run this now:"
echo "source ~/.bashrc"
echo "Then test:"
echo "which $PROGRAM_NAME"
echo "$PROGRAM_NAME --help"
