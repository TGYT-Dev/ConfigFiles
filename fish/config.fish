if status is-interactive

    # Variables 

    set gitRepoDir "$HOME/ConfigFiles/" #  NOTE: This reminds me of that one steam issue a while ago where some dude got his system rm -rf becuase his $STEAMROOT was blank. that might be able to happen to this?

    # Astetichs (change this to something better later)

    zfetch
    starship init fish | source

    # Alias - Maybe make them actual scripts later so I can use arguments

    alias roblox sober
    alias cat 'bat --theme="gruvbox-dark" --style=numbers,grid'
    alias ls 'eza --icons --no-permissions --no-user --no-time --no-filesize'
    alias chrome google-chrome-stable
    alias google google-chrome-stable
    alias vencordInject 'sh -c "$(curl -sS https://vencord.dev/install.sh)"'
    alias updateConfig updateConfigInGitRepo

    # Functions  NOTE: these should probably be in ~/.config/fish/functions but like oh well maybe later

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

        # Function got a little long so this is the flow:
        #
        # 1. Remove old config from git repo and add new config from ~/.config
        #
        # 2. check if addToGit flag was passed, if not nothing else should be needed
        #
        # 3. does the add to git stuff by cheking for commit flag (as if it exists there should be a commit message too)
        #
        #  NOTE: the entire thing may be fucked if a commit messagges is not passed and I don't feel like finding out, and it will throw errors if it isn't a string and has spaces in the commit message
        #
        # 4. checks for commit flag and commits if it was passed
        #
        # 5. checks for push flag and pushes if it was passed
        #
        #  INFO: updateConfigInGitRepo <configName> [-a / --add-to-git] [-c / --commit "commit message"] [-p / --push] <Files to stage>

        rm -r $gitRepoDir/$argv[1] # Remove old config
        cp -r $HOME/.config/$argv[1] $gitRepoDir/ # Adds new config

        argparse c/commit p/push a/add-to-git -- $argv

        if set -q _flag_add_to_git # checks if add-to-git was passed

            if set -q _flag_commit # checks if commit was passed to see when to start taking arguments as file to stage  NOTE: this is a mess

                for arg in $argv[4..-1]
                    git -C $gitRepoDir add $arg
                end

            else

                for arg in $argv[3..-1]
                    git -C $gitRepoDir add $arg
                end

            end

            if set -q _flag_commit # checks if commit was passed

                git -C $gitRepoDir commit -m "$argv[3]"

            end

            if set -q _flag_push # checks if push was passed

                git -C $gitRepoDir push origin configFilesBranch

            end

        end

    end

end
