## Merge branch action

### On labeled

Merge PR branch using github labeld.

You can set label in a PR and this actinos merge the PR branch to other branch, usefult for develop branch or staging enviroments.

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
          base_branch: 'develop'
        env:
          GITHUB_TOKEN: ${{secrets.GITHUB_TOKEN}}
```
