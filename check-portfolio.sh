#!/bin/sh
set -eu
# Check public metadata first. Query runs only for active public originals.
repos=$(gh api --paginate 'users/smcnab1/repos?per_page=100' --jq '.[] | select(.archived == false) | [.name, .default_branch, .fork, (.description != null and .description != ""), (.topics | length > 0)] | @tsv')
printf '%s\n' "$repos" | while read -r repo branch fork description topics; do
  [ "$description" = true ] || echo "$repo: missing description"
  [ "$topics" = true ] || echo "$repo: missing topics"
  cleanup=$(gh api "repos/smcnab1/$repo" --jq .delete_branch_on_merge)
  [ "$cleanup" = true ] || echo "$repo: check merged branch cleanup"
  [ "$fork" = false ] || continue
  runs=$(gh api -X GET "repos/smcnab1/$repo/actions/runs" -f branch="$branch" -F per_page=1 --jq '.workflow_runs[] | select(.conclusion != null and .conclusion != "success" and .conclusion != "skipped" and .conclusion != "neutral") | .html_url')
  [ -z "$runs" ] || echo "$repo: review $runs"
done
