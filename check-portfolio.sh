#!/bin/sh
set -eu
# Check public metadata first. Query runs only for active public originals.
repos=$(gh api --paginate 'users/smcnab1/repos?per_page=100' --jq '.[] | select(.archived == false) | [.name, .default_branch, .fork, (.description != null and .description != ""), (.topics | length > 0), .delete_branch_on_merge] | @tsv')
printf '%s\n' "$repos" | while read -r repo branch fork description topics cleanup; do
  [ "$description" = true ] || echo "$repo: missing description"
  [ "$topics" = true ] || echo "$repo: missing topics"
  [ "$cleanup" = true ] || echo "$repo: check merged branch cleanup"
  [ "$fork" = false ] || continue
  runs=$(gh api -X GET "repos/smcnab1/$repo/actions/runs" -f branch="$branch" -F per_page=1 --jq '.workflow_runs[] | select(.conclusion != null and .conclusion != "success" and .conclusion != "skipped" and .conclusion != "neutral") | .html_url')
  [ -z "$runs" ] || echo "$repo: review $runs"
done
