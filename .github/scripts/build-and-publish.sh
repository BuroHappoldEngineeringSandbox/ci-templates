#!/bin/bash
# Builds and publishes a NuGet package
# Usage: build-and-publish.sh <project_path> <package_name> <version> <repo_url>

set -euo pipefail

PROJECT_PATH="$1"
PKG_NAME="$2"
VERSION="$3"
REPO_URL="$4"

# Build
echo "🔨 Building..." >&2
if ! dotnet build "$PROJECT_PATH" \
  -c Release \
  -p:Version="$VERSION" \
  --nologo \
  -v quiet; then
  echo "❌ Build failed" >&2
  exit 1
fi

# Pack
echo "📦 Packing..." >&2
if ! dotnet pack "$PROJECT_PATH" \
  -c Release \
  --no-build \
  -p:PackageId="$PKG_NAME" \
  -p:Version="$VERSION" \
  -p:RepositoryUrl="$REPO_URL" \
  -p:RepositoryType="git" \
  -o ./packages \
  --nologo \
  -v quiet; then
  echo "❌ Pack failed" >&2
  exit 2
fi

# Publish
echo "🚀 Publishing..." >&2
if dotnet nuget push "./packages/${PKG_NAME}.${VERSION}.nupkg" \
  --source "https://nuget.pkg.github.com/BuroHappoldEngineeringSandbox/index.json" \
  --api-key "$GITHUB_TOKEN" \
  --skip-duplicate \
  --no-symbols 2>&1 | grep -v "warn" >&2; then
  echo "✅ Success" >&2
  exit 0
else
  echo "❌ Publish failed" >&2
  exit 3
fi