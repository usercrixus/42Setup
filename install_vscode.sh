#!/usr/bin/env bash
set -e

APPDIR="$HOME/App"
ARCHIVE="$APPDIR/vscode.tar.gz"
EXTRACTED="$APPDIR/VSCode-linux-x64"
BINDIR="$HOME/.local/bin"
BASHRC="$HOME/.bashrc"

mkdir -p "$APPDIR"
mkdir -p "$BINDIR"

wget -O "$ARCHIVE" "https://vscode.download.prss.microsoft.com/dbazure/download/stable/0870c2a0c7c0564e7631bfed2675573a94ba4455/code-stable-x64-1772587898.tar.gz"

rm -rf "$EXTRACTED"
tar -xzf "$ARCHIVE" -C "$APPDIR"

ln -sfn "$EXTRACTED/code" "$BINDIR/code"

if [ -f "$BASHRC" ]; then
    grep -v 'alias code=' "$BASHRC" > "$BASHRC.tmp" || true
    mv "$BASHRC.tmp" "$BASHRC"
fi

if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$BASHRC" 2>/dev/null; then
cat >> "$BASHRC" <<'EOF'

# Add user local bin
export PATH="$HOME/.local/bin:$PATH"
EOF
fi

export PATH="$HOME/.local/bin:$PATH"
unalias code 2>/dev/null || true
hash -r

rm -rf $ARCHIVE

echo "Installation finished."
echo "Run this now:"
echo "source ~/.bashrc"
echo "Then test:"
echo "which code"
echo "code ."
