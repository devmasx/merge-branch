#

```yaml
name: Merge branch
on: [push]
jobs:
  merge-branch:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@master
      - name: Merge to develop
        uses: devmasxtest/merge-command-action@master
        with:
          base_branch: develop
        env:
          GITHUB_TOKEN: ${{secrets.GITHUB_TOKEN}}
```
