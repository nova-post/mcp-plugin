#!/usr/bin/env bash
# Publishes the current state of origin/master to origin/main as ONE release commit.
# main has its own history, unrelated to master: one commit per release, authored by the release bot.
# The version is read from plugin.json on origin/master; all three manifests must agree.
#
# Usage:
#   scripts/release.sh            # build the commit, show it, ask before pushing
#   scripts/release.sh --dry-run  # build and show the commit, never push
#
# Optional: RELEASE_BOT_NAME (default release-bot), RELEASE_BOT_EMAIL (release-bot@novadigital.com),
#           RELEASE_REMOTE (origin), RELEASE_SOURCE (master), RELEASE_TARGET (main).
set -euo pipefail

remote="${RELEASE_REMOTE:-origin}"
source_branch="${RELEASE_SOURCE:-master}"
target_branch="${RELEASE_TARGET:-main}"
manifests=(plugin.json .claude-plugin/plugin.json .codex-plugin/plugin.json)

die() { echo "error: $*" >&2; exit 1; }

dry_run=false
case "${1:-}" in
  "") ;;
  -n|--dry-run) dry_run=true ;;
  -h|--help) sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
  *) die "unknown argument: $1 (see --help)" ;;
esac

RELEASE_BOT_NAME="${RELEASE_BOT_NAME:-release-bot}"
RELEASE_BOT_EMAIL="${RELEASE_BOT_EMAIL:-release-bot@novadigital.com}"
command -v jq >/dev/null || die "jq is required"

cd "$(dirname "${BASH_SOURCE[0]}")/.."

# --- Fetch the exact remote state; local branches are never used. -------------------------------
source_ref="refs/remotes/$remote/$source_branch"
target_ref="refs/remotes/$remote/$target_branch"
git fetch --no-tags "$remote" "+refs/heads/$source_branch:$source_ref"

set +e
git ls-remote --exit-code --heads "$remote" "$target_branch" >/dev/null
status=$?
set -e
case $status in
  0) git fetch --no-tags "$remote" "+refs/heads/$target_branch:$target_ref"
     parent="$(git rev-parse "$target_ref")" ;;
  2) parent="" ;;  # first release: main does not exist yet
  *) die "cannot query $remote" ;;
esac

# --- Version from the manifests on master. -------------------------------------------------------
version="$(git show "$source_ref:plugin.json" | jq -er .version)" || die "cannot read version from plugin.json"
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "version '$version' is not MAJOR.MINOR.PATCH"
for manifest in "${manifests[@]:1}"; do
  other="$(git show "$source_ref:$manifest" | jq -er .version)" || die "cannot read version from $manifest"
  [[ "$other" == "$version" ]] || die "$manifest has version $other, plugin.json has $version"
done

message="Release $version"
tree="$(git rev-parse "$source_ref^{tree}")"

# --- Guard main: independent, linear, bot-only history with increasing versions. -----------------
if [[ -n "$parent" ]]; then
  if git merge-base "$source_ref" "$parent" >/dev/null; then
    die "$target_branch shares history with $source_branch; it must be independent"
  fi

  while IFS=$'\t' read -r author_name author_email committer_name committer_email parents; do
    if [[ "$author_name" != "$RELEASE_BOT_NAME" || "$author_email" != "$RELEASE_BOT_EMAIL" ||
          "$committer_name" != "$RELEASE_BOT_NAME" || "$committer_email" != "$RELEASE_BOT_EMAIL" ]]; then
      die "$target_branch has a commit by '$author_name <$author_email>'; only the release bot may commit there"
    fi
    [[ "$parents" != *" "* ]] || die "$target_branch contains a merge commit; history must be linear"
  done < <(git log --format='%an%x09%ae%x09%cn%x09%ce%x09%P' "$parent")

  subjects="$(git log --format=%s "$parent")"
  if grep -qxF "$message" <<<"$subjects"; then
    if [[ "$(head -n1 <<<"$subjects")" == "$message" && "$(git rev-parse "$parent^{tree}")" == "$tree" ]]; then
      echo "$message is already published on $remote/$target_branch; nothing to do."
      exit 0
    fi
    die "$message already exists on $target_branch; bump the version in all manifests on $source_branch"
  fi

  previous="$(grep -m1 -xE 'Release [0-9]+\.[0-9]+\.[0-9]+' <<<"$subjects" | sed 's/^Release //' || true)"
  if [[ -n "$previous" ]]; then
    highest="$(printf '%s\n%s\n' "$previous" "$version" | sort -V | tail -n1)"
    [[ "$highest" == "$version" ]] || die "version $version must be greater than the last release $previous"
  fi
fi

# --- Build the release commit (nothing is pushed yet). -------------------------------------------
parent_args=()
[[ -z "$parent" ]] || parent_args=(-p "$parent")
commit="$(GIT_AUTHOR_NAME="$RELEASE_BOT_NAME" GIT_AUTHOR_EMAIL="$RELEASE_BOT_EMAIL" \
          GIT_COMMITTER_NAME="$RELEASE_BOT_NAME" GIT_COMMITTER_EMAIL="$RELEASE_BOT_EMAIL" \
          git commit-tree "$tree" "${parent_args[@]}" -m "$message")"

echo
echo "Release:  $version"
echo "Source:   $remote/$source_branch @ $(git rev-parse --short "$source_ref")"
if [[ -n "$parent" ]]; then
  echo "Target:   $remote/$target_branch @ $(git rev-parse --short "$parent") ($(head -n1 <<<"$subjects"))"
else
  echo "Target:   $remote/$target_branch (new branch, first release)"
fi
echo
git --no-pager log -1 --format=fuller "$commit"
echo
if [[ -n "$parent" ]]; then
  git --no-pager diff --stat "$parent" "$commit"
else
  echo "$(git ls-tree -r --name-only "$commit" | wc -l) files in the first release"
fi
echo

if $dry_run; then
  echo "Dry run: commit $commit was created locally and NOT pushed."
  exit 0
fi

read -r -p "Push $message to $remote/$target_branch? [y/N] " answer
[[ "$answer" == [yY] ]] || { echo "Aborted; nothing pushed."; exit 1; }

# No --force: if main moved since the fetch, the push is rejected and the script can be rerun.
git push "$remote" "$commit:refs/heads/$target_branch"
echo "Published $message: $commit"
