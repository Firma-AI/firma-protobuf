# Print the unreleased changelog section to stdout (preview only), e.g. `just changelog_preview 0.1.2`
[group('changelog')]
changelog_preview version:
    git-cliff --config cliff.toml --unreleased --tag "v{{ version }}" --strip all

# Add a new entry to CHANGELOG.md from the unreleased conventional commits, e.g. `just changelog 0.1.2`
[group('changelog')]
changelog version:
    #!/usr/bin/env bash
    set -euo pipefail
    tag="v{{ version }}"
    section="$(git-cliff --config cliff.toml --unreleased --tag "$tag" --strip all)"
    if [ -z "$section" ]; then
        echo "No unreleased conventional commits found; nothing to add." >&2
        exit 0
    fi
    secfile="$(mktemp)"
    tmp="$(mktemp)"
    printf '%s\n' "$section" > "$secfile"
    # Insert the rendered section before the first existing version heading,
    # keeping the title intact.
    awk -v secfile="$secfile" '
        !body_done && /^## [0-9]/ {
            while ((getline line < secfile) > 0) print line
            print ""
            body_done = 1
        }
        { print }
    ' CHANGELOG.md > "$tmp"
    rm -f "$secfile"
    mv "$tmp" CHANGELOG.md
    echo "CHANGELOG.md updated for $tag"
