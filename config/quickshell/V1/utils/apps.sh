#!/bin/bash

dirs=(
    "/usr/share/applications"
    "/usr/local/share/applications"
    "$HOME/.local/share/applications"
    "/var/lib/flatpak/exports/share/applications"
    "$HOME/.local/share/flatpak/exports/share/applications"
)

for dir in "${dirs[@]}"; do
    if [ -d "$dir" ]; then
        # Find all .desktop files in this directory
        for file in "$dir"/*.desktop; do
            [ -e "$file" ] || continue

            # Read the file content
            content=$(<"$file")

            # Check if NoDisplay is true (skip hidden apps)
            if echo "$content" | grep -q "^NoDisplay=true"; then
                continue
            fi

            # Extract Name
            name=$(echo "$content" | grep -m 1 "^Name=" | cut -d= -f2-)

            # Extract Exec and clean it (remove %u, %F, etc.)
            exec_cmd=$(echo "$content" | grep -m 1 "^Exec=" | cut -d= -f2- | sed 's/ %[a-zA-Z]//g' | sed 's/^"//g' | sed 's/" *$//g')

            # Extract Icon
            icon=$(echo "$content" | grep -m 1 "^Icon=" | cut -d= -f2-)

            if [ -n "$name" ] && [ -n "$exec_cmd" ]; then
                # Fallback for missing icon
                if [ -z "$icon" ]; then
                    icon="application-x-executable"
                fi

                # Print in format: Name|Exec|Icon
                echo "$name|$exec_cmd|$icon"
            fi
        done
    fi
done
