#!/bin/bash

# Usage: ./insert-imports.sh /path/to/your/home-manager/config.nix
# This script inserts the imports snippet just before the last closing brace '}' in the file.
# Assumes the file is a valid Nix config with a single top-level attrset.
# Backup your file first! (e.g., cp file file.bak)

set -euo pipefail

file="${1:-}"
if [ -z "$file" ] || [ ! -f "$file" ]; then
  echo "Error: Provide a valid file path as argument (e.g., ~/.config/home-manager/home.nix)"
  exit 1
fi

# Find the line number of the last line matching '^\s*}$'
last_brace_line=$(grep -n '^[[:space:]]*}\?$' "$file" | tail -n1 | cut -d: -f1)
if [ -z "$last_brace_line" ]; then
  echo "Error: No closing brace '}' found in the file."
  exit 1
fi

# Create a temporary file
temp_file=$(mktemp)

# Write all lines before the last brace
head -n $((last_brace_line - 1)) "$file" > "$temp_file"

# Append the snippet (note: using <~/...> for Nix path resolution; adjust if needed)
cat << 'EOF' >> "$temp_file"
  imports = [
    ~/dotfiles/home.nix
  ];
EOF

# Append the last brace line and everything after (if any, though unlikely)
tail -n +"$last_brace_line" "$file" >> "$temp_file"

# Replace the original file (use -i for in-place if sed, but here atomic)
mv "$temp_file" "$file"

echo "Snippet inserted before line $last_brace_line in $file"
echo "Review the file for syntax (run 'home-manager switch' to test)."

