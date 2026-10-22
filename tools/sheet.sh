#!/usr/bin/env bash
# Usage: tools/sheet.sh <category> [cell] [cols]  -> docs/sheets/<category>.png
G="${GODOT:-/c/Users/HARSIDI BIN JUNICK/Desktop/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe}"
mkdir -p docs/sheets
"$G" --headless --path . -s tools/contact_sheet.gd -- "res://assets/art/$1" "docs/sheets/${1////_}.png" "${2:-128}" "${3:-10}" 2>&1 | grep -v "^Godot Engine\|^$"
