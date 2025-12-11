# TODO

1. Implement argument 4 for updateConfigInGitRepo function.

```fish
for arg in $argv[4..-1]
  git -C $gitRepoDir add arg
end
```
