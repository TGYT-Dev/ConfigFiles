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

        set fullAlias "$argv[1] '$argv[2..-1]"
        echo "alias $fullAlias" >>~/.config/fish/aliases.fish

    end

    #    function vencord
    #
    #    argparse u/update d/discord-update -- $argv
    #
    #    if set -q _flag_update # Runs what used to be the alias vencordInject if -u / --update flag is passed
    #        sh -c "$(curl -sS https://vencord.dev/install.sh)"
    #    end
    #
    #    command discord # if command prefix isn't used it would call itself recursively
    #
    #end

    function rn

        mv $argv[1] $argv[2]

    end

    function checkRunning # Pretty self explanatory - checks if a process is running

        ps aux | grep -v grep | grep "$argv"

    end

    function sober

        if test "$argv[1]" = -u # Checks for -u flag - if passed updates sober instead of running it
            flatpak update org.vinegarhq.Sober
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

            set folder (string trim / $folder) # Removes slash becuase $gitRepoDir already has one at the end
            rm -r ~/.config/$folder
            cp -r $gitRepoDir$folder ~/.config/$folder

        end

    end

    function startMcServer

        # Creates a new tmux session in ~/servers/mcServers/

        tmux new-session -s mcServer -c $mcServerDir
        tmux send-keys -t mcServer './selectAndStartServer' Enter

        # I have a template MC server I made that runs paper and geyser + floodgate #
        # In each servers folder there is a startServer script that also runs playit.gg as I dont want to port foward that shit
        # INFO: I will probably switch that to a cloudflare tunnel with a custom domain once I get a card

    end
end
