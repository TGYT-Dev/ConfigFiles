complete -c updateConfigInGitRepo -n __fish_use_subcommand -a "(ls -d */ 2>/dev/null)" -d "Config to update"
complete -c mycmd -s c -d "Commits, stages, and pushes changes after config update"
complete -c mycmd \
    -n "__fish_seen_argument -c" \
    -a "''" \
    -d "Commit message"
