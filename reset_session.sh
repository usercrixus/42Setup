

#!/usr/bin/env bash
set -euo pipefail

TARGETS=(
    "$HOME/snap"
    "$HOME/.local"
    "$HOME/.npm"
    "$HOME/.arduino15"
    "$HOME/.mozilla"
    "$HOME/.var"
    "$HOME/.vscode"
    "$HOME/.cargo"
    "$HOME/.keras"
    "$HOME/.atom"
    "$HOME/.config"
    "$HOME/.java"
    "$HOME/.dotnet"
    "$HOME/.docker"
    "$HOME/.arduinoIDE"
)

echo "WARNING: This will permanently delete these paths:"
for path in "${TARGETS[@]}"; do
    echo " - $path"
done
echo

read -r -p "Type RESET to continue: " confirm
if [ "$confirm" != "RESET" ]; then
    echo "Aborted. Nothing was deleted."
    exit 1
fi

for path in "${TARGETS[@]}"; do
    if [ -e "$path" ]; then
        rm -rf -- "$path"
        echo "Deleted: $path"
    else
        echo "Not found: $path"
    fi
done

echo "Reset complete."
