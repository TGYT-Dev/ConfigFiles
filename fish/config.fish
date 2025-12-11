if status is-interactive

    # Variables 

    set gitRepoDir "$HOME/ConfigFiles/"

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
    alias nano nvim

    # Functions

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

    function updateConfigInGitRepo # using this for easier updating - first arg is the config to replace

        rm -r $gitRepoDir/$argv[1] # Remove old config
        cp -r $HOME/.config/$argv[1] $gitRepoDir/ # Adds new config

        argparse 'c/commit=' p/push a/add-to-git -- $argv

        if set -q _flag_add_to_git # checks if add-to-git was passed

            git -C $gitRepoDir add $argv[1]

        end

        if set -q _flag_commit # checks if commit was passed

            if $argv[3] != '' # Checks if commit message was passed
                set commitMessage $argv[3]
            else
                set commitMessage "Updated $argv[1] config" # Provides default commit message
            end

            git -C $gitRepoDir commit -m "$commitMessage"

        end

        if set -q _flag_push # checks if push was passed

            git -C $gitRepoDir push origin configFilesBranch

        end

    end

end
