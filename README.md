## Merge branch action

Runs a git merge in your CI.

Examples:

### Sync branches

```yaml
name: Sync multiple branches
on:
  push:
    branches:
      - '*'
jobs:
  sync-branch:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@master

      - name: Merge development -> staging
        uses: devmasx/merge-branch@master
        with:
          type: now
          from_branch: development
          target_branch: staging
          github_token: ${{ secrets.GITHUB_TOKEN }}

      - name: Merge staging -> uat
        uses: devmasx/merge-branch@master
        with:
          type: now
          from_branch: staging
          target_branch: uat
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Merge current branch

```yaml
name: Merge any release branch to uat
on:
  push:
    branches:
      - 'release/*'
jobs:
  merge-branch:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@master

      - name: Merge staging -> uat
        uses: devmasx/merge-branch@master
        with:
          type: now
          target_branch: uat
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Merge current branch with commit message

```yaml
name: Merge any release branch to uat
on:
  push:
    branches:
      - 'release/*'
jobs:
  merge-branch:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@master

      - name: Merge staging -> uat
        uses: devmasx/merge-branch@master
        with:
          type: now
          target_branch: uat
          message: Merge staging into uat
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

### On labeled

Merge pull request branch using GitHub labels.

When you set a label in a pull request this action can merge the pull request branch to other branch, useful for develop branch or staging environments.

![PR](./screenshots/pr.png)
![Checker](./screenshots/checker.png)

```yaml
name: Merge branch with labeled
on:
  pull_request:
    types: [labeled]
jobs:
  merge-branch:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@master

      - name: Merge by labeled
        uses: devmasx/merge-branch@master
        with:
          label_name: 'merged in develop'
          target_branch: 'develop'
          github_token: ${{ secrets.GITHUB_TOKEN }}
```
