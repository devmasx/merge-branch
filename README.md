## Merge branch

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
      - name: Merge to develop
        uses: devmasxtest/merge-command-action@master
        with:
          type: labeled
          label_name: "merged in develop"
          base_branch: "develop"
        env:
          GITHUB_TOKEN: ${{secrets.GITHUB_TOKEN}}
```
