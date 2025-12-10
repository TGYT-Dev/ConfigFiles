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

    function checkRunning # lowk just got tired of typing ts out

        ps aux | grep -v grep | grep "$argv"

    end

    function sober

        if test "$argv[1]" = -u # updates it cuz i hate the flatpak command 
            flatpak update org.vinegarhq.Sober
        else
            flatpak run org.vinegarhq.Sober
        end

    end

    function updateConfigInGitRepo # using this for easier updating - first arg is the config to replace

        rm -r $gitRepoDir/$argv[1]
        cp -r $HOME/.config/$argv[1] $gitRepoDir/

    end

end
