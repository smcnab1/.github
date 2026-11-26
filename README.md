# Repository standards

Shared contribution guidance and issue templates for Sam McNab’s repositories. Each project's README explains what it does and how to use it. Project-specific guidance takes precedence.

## Presenting a project

Lead with the project name, purpose and a working link to the app, download or documentation. Show an existing product image when it helps someone recognise or use the project. Follow with the shortest verified way to get started, supported platforms, development checks and relevant licence or attribution. Use UK English in original prose and preserve product names, upstream conventions and technical identifiers. Use badges only for information a visitor can act on.

## Reviewing a change

Use a branch and a focused pull request. Give workflow tokens the permissions each job needs and pin external actions to reviewed commit SHAs. Prefer grouped monthly dependency updates for routine maintenance. Require reliable checks that run on every relevant pull request. Keep release and deployment approvals specific to the project.

## Writing release notes

Use the existing changelog or GitHub’s **Generate release notes** when preparing a release. Lead with user-visible changes. Document upgrade steps, compatibility changes and known limitations when relevant. Preserve published notes and required store formats.

## Checking maintenance

Run the read-only command below from a checkout with GitHub CLI authenticated. It lists active public repositories with missing metadata, disabled branch cleanup or an unsuccessful latest default-branch workflow run. Review the named run in Actions and check whether its workflow still serves the project. Forks may intentionally follow upstream conventions.

```sh
sh check-portfolio.sh
```

For the periodic review, also open each changed project's README and check its installation and website links, security reporting route, rules and dependency settings. GitHub supplies the community defaults from this repository where a project has no override. Licences and Dependabot configuration belong in each project.
