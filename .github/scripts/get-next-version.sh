#!/bin/bash
# Calculates next alpha version for a package
# Usage: get-next-version.sh <package_name> <milestone> <commit_sha>
# Output: Version string (e.g., "2.1.0-alpha.5+a1b2c3d")

set -euo pipefail

PACKAGE_NAME="$1"
MILESTONE="$2"
COMMIT_SHA="$3"
REPO_OWNER="BHoM"

echo "🔍 Checking existing versions..." >&2

# Query GitHub Packages API
VERSIONS=$(gh api \
  -H "Accept: application/vnd.github+json" \
  "/orgs/$REPO_OWNER/packages/nuget/$PACKAGE_NAME/versions" \
  --jq '.[].name' 2>/dev/null || echo "")

# Filter for current milestone alpha versions
ALPHA_VERSIONS=$(echo "$VERSIONS" | grep "^${MILESTONE}\.0-alpha\." || echo "")

if [ -z "$ALPHA_VERSIONS" ]; then
  NEXT_ALPHA=0
  echo "   Starting at alpha.0" >&2
else
  HIGHEST=$(echo "$ALPHA_VERSIONS" | \
    sed "s/${MILESTONE}\.0-alpha\.//" | \
    cut -d'+' -f1 | \
    sort -n | \
    tail -1)
  NEXT_ALPHA=$((HIGHEST + 1))
  echo "   Latest: alpha.$HIGHEST → Next: alpha.$NEXT_ALPHA" >&2
fi

# Output version
VERSION="${MILESTONE}.0-alpha.${NEXT_ALPHA}+${COMMIT_SHA}"
echo "   Version: $VERSION" >&2
echo "$VERSION"