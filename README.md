## Merge branch action

### On labeled

Merge pull request branch using GitHub labels.

When you set a label in a pull request this action can merge the pull request branch to other branch, useful for develop branch or staging environments.

![PR](./screenshots/pr.png)
![Checker](./screenshots/checker.png)

```yaml
name: Merge branch
on:
  pull_request:
    types: [labeled]
jobs:
  merge-branch:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master

      - name: Merge by labeled
        uses: devmasx/merge-branch@v1.2.0
        with:
          label_name: 'merged in develop'
          target_branch: 'develop'
        env:
          GITHUB_TOKEN: ${{secrets.GITHUB_TOKEN}}
```

## On any GitHub event

```yaml
name: Merge any release branch to uat
on:
  push:
    branches:
      - 'release/*'
jobs:
  merge-branch:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master

      - name: Merge staging -> uat
        uses: devmasx/merge-branch@v1.2.0
        with:
          type: now
          target_branch: uat
        env:
          GITHUB_TOKEN: ${{secrets.GITHUB_TOKEN}}
```

```yaml
name: Sync multiple branches
on:
  push:
    branches:
      - '*'
jobs:
  sync-branch:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master

      - name: Merge development -> staging
        uses: devmasx/merge-branch@v1.2.0
        with:
          type: now
          head_to_merge: development
          target_branch: staging
        env:
          GITHUB_TOKEN: ${{secrets.GITHUB_TOKEN}}

      - name: Merge staging -> uat
        uses: devmasx/merge-branch@v1.2.0
        with:
          type: now
          head_to_merge: staging
          target_branch: uat
        env:
          GITHUB_TOKEN: ${{secrets.GITHUB_TOKEN}}
```
