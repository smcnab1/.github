#!/bin/sh
set -eu
# Check public metadata first. Query runs only for active public originals.
repos=$(gh api --paginate 'users/smcnab1/repos?per_page=100' --jq '.[] | select(.archived == false) | [.name, .default_branch, .fork, (.description != null and .description != ""), (.topics | length > 0)] | @tsv')
printf '%s\n' "$repos" | while read -r repo branch fork description topics; do
  [ "$description" = true ] || echo "$repo: missing description"
  [ "$topics" = true ] || echo "$repo: missing topics"
  base="repos/smcnab1/$repo"
  gh api "$base" --jq '
    if .delete_branch_on_merge != true then .name + ": check merged branch cleanup" else empty end,
    if .security_and_analysis.secret_scanning.status != "enabled" then .name + ": check secret scanning" else empty end,
    if .security_and_analysis.secret_scanning_push_protection.status != "enabled" then .name + ": check push protection" else empty end'
  [ "$fork" = false ] || continue
  files=$(gh api "$base/contents" --jq '.[].name')
  printf '%s\n' "$files" | grep -Eiq '^readme([.]|$)' || echo "$repo: check README location"
  if printf '%s\n' "$files" | grep -Eq '^(package.json|Package.swift)$'; then
    config=
    if printf '%s\n' "$files" | grep -Fxq .github; then
      config=$(gh api "$base/contents/.github" --jq '.[].name')
    fi
    printf '%s\n' "$config" | grep -Eq '^dependabot[.]ya?ml$' || echo "$repo: check dependency update configuration"
  fi
  runs=$(gh api -X GET "repos/smcnab1/$repo/actions/runs" -f branch="$branch" -F per_page=30 --jq '.workflow_runs | group_by(.workflow_id)[] | max_by(.created_at) | select(.conclusion != null and .conclusion != "success" and .conclusion != "skipped" and .conclusion != "neutral") | .html_url')
  [ -z "$runs" ] || printf '%s\n' "$runs" | sed "s|^|$repo: review |"
done
