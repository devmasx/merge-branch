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
        uses: devmasx/merge-branch@v1.1.0
        with:
          label_name: 'merged in develop'
          target_branch: 'develop'
        env:
          GITHUB_TOKEN: ${{secrets.GITHUB_TOKEN}}
```

## On any GitHub event

```yaml
name: Merge staging branch to uat
on:
  push:
    branches:
      - 'staging'
jobs:
  merge-branch:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master
      - name: Merge to uat branch
        uses: devmasx/merge-branch@v1.1.0
        with:
          type: now
          target_branch: 'uat'
        env:
          GITHUB_TOKEN: ${{secrets.GITHUB_TOKEN}}
```
