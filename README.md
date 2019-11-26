## Merge branch action

### On labeled

Merge PR branch using github labels.

When you set a label in a PR this action can merge the PR branch to other branch, useful for develop branch or staging enviroments.

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
        uses: devmasx/merge-branch@master
        with:
          label_name: 'merged in develop'
          target_branch: 'develop'
        env:
          GITHUB_TOKEN: ${{secrets.GITHUB_TOKEN}}
```
