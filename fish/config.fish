if status is-interactive

    # Variables 

    set gitRepoDir "$HOME/ConfigFiles/"
    set mcServerDir "$HOME/servers/mcServers/"

    # Astetichs (change this to something better later)

    zfetch
    starship init fish | source

    source ~/.config/fish/fzfTheme.fish

    # Aliases 

    if test -f ~/.config/fish/aliases.fish
        source ~/.config/fish/aliases.fish
    end

    # Functions  NOTE: these should probably be in ~/.config/fish/functions but like oh well maybe later

    function saveAlias

        set fullAlias "$argv[1] '$argv[2..-1]'"
        echo "alias $fullAlias" >>~/.config/fish/aliases.fish

    end

    function discord

        argparse u/update -- $argv

        if set -q _flag_update
            sudo pacman -Syu vesktop-bin
        end

        command vesktop

    end

    function checkRunning # Pretty self explanatory - checks if a process is running

        ps aux | grep -v grep | grep "$argv"

    end

    function sober

        if contains -- $argv[1] -u --update
            flatpak update org.vinegarhq.Sober -y
            flatpak run org.vinegarhq.Sober
        else
            flatpak run org.vinegarhq.Sober
        end

    end

    function updateConfigInGitRepo # args - #1 Config to update, #2 flags, #3 commit message (required of -c is passed), #4 files to stage (opitonal - not implemented yet)

        rm -r $gitRepoDir/$argv[1] # Remove old config
        cp -r $HOME/.config/$argv[1] $gitRepoDir/ # Adds new config

        argparse c/commit p/push a/add-to-git -- $argv

        if set -q _flag_add_to_git # checks if add-to-git was passed

            for arg in $argv[2..-1] #  NOTE: this should correctly stage all the files due to the fact that the flags are gone after argparse

                git -C $gitRepoDir add $arg #  WARN: this makes git throw an error becuase it trys to stage the commit message as if it was a file but its harmless so oh well
            end

            if set -q _flag_commit # checks if commit was passed

                git -C $gitRepoDir commit -m "$argv[2]"

            end

            if set -q _flag_push # checks if push was passed

                git -C $gitRepoDir push origin configFilesBranch

            end

        end

    end

    function backupFromGitRepo # Backs up config files from git repo to ~/.config

        set configsInGitRepo (ls $gitRepoDir | grep -v images | grep -v README.md)

        ls $gitRepoDir
        echo $configsInGitRepo

        for folder in $configsInGitRepo

            set folder (string trim --chars '/' $folder) # Removes slash because $gitRepoDir already has one at the end
            rm -r ~/.config/$folder
            cp -r $gitRepoDir$folder ~/.config/$folder

        end

    end

    function _tsm_notify # Internal: notify the Discord bot of an MC status event
        set -l type $argv[1]
        set -l secret (cat ~/projects/tsm/config.json | python3 -c "import sys,json; print(json.load(sys.stdin)['statusSecret'])")
        set -l port (cat ~/projects/tsm/config.json | python3 -c "import sys,json; print(json.load(sys.stdin).get('statusPort', 4444))")
        curl -s -X POST http://localhost:$port \
            -H "Content-Type: application/json" \
            -d "{\"type\":\"$type\",\"secret\":\"$secret\"}" >/dev/null
    end

    function tsm # Controls TSM services: tsm <service> [-s|-c|-r|-t|-h]
        argparse h/help s/start c/stop r/restart t/status -- $argv
        or return

        if set -q _flag_help
            echo "Usage: tsm <service(s)|all> [options]"
            echo ""
            echo "Services:"
            echo "  mc       Minecraft server (tsm-mc.service)"
            echo "  bot      Discord bot (tsm-bot.service)"
            echo "  playit   PlayIt tunnel (tsm-playit.service)"
            echo "  web      Management Web UI (tsm-management.service)"
            echo "  all      All of the above"
            echo ""
            echo "Options:"
            echo "  -s, --start    Start the service(s)"
            echo "  -c, --stop     Stop the service(s)"
            echo "  -r, --restart  Restart the service(s)"
            echo "  -t, --status   Show status of the service(s)"
            echo "  -h, --help     Show this help message"
            echo "  (No option)    Show status of the service(s)"
            return 0
        end

        if test (count $argv) -eq 0
            echo "Usage: tsm <service|all> [-s|-c|-r|-t|-h]"
            echo "Run 'tsm --help' for details."
            return 1
        end

        set -l target_services
        set -l mc_included 0
        for srv in $argv
            if test "$srv" = all
                set -a target_services tsm-mc tsm-bot tsm-playit tsm-management
                set mc_included 1
            else if test "$srv" = web
                set -a target_services tsm-management
            else if contains "$srv" mc bot playit
                set -a target_services "tsm-$srv"
                if test "$srv" = mc
                    set mc_included 1
                end
            else
                echo "Error: Unknown service '$srv'."
                echo "Valid options are: mc, bot, playit, web, all"
                return 1
            end
        end

        if set -q _flag_start
            systemctl --user start $target_services
            if test $mc_included -eq 1
                _tsm_notify manualStart
            end
        else if set -q _flag_stop
            if test $mc_included -eq 1
                _tsm_notify manualStop
            end
            systemctl --user stop $target_services
        else if set -q _flag_restart
            if test $mc_included -eq 1
                _tsm_notify restart
            end
            systemctl --user restart $target_services
        else if set -q _flag_status
            systemctl --user status $target_services
        else
            systemctl --user status $target_services
        end
    end
end

# Added by Antigravity CLI installer
set -gx PATH "/home/dev/.local/bin" $PATH
