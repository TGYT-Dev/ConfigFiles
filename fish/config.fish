if status is-interactive

    # Astetichs

    zfetch

    # Alias - Maybe make them actual scripts later

    alias roblox sober
    alias cat 'bat --theme="gruvbox-dark" --style=numbers,grid'
    alias ls 'eza --icons --no-permissions --no-user --no-time --no-filesize'
    alias chrome google-chrome-stable
    alias google google-chrome-stable
    alias vencordInject 'sh -c "$(curl -sS https://vencord.dev/install.sh)"'
    alias nano nvim

    # Functions

    function sober
        if test "$argv[1]" = -u
            flatpak update org.vinegarhq.Sober
        else
            flatpak run org.vinegarhq.Sober
        end

    end

end
starship init fish | source
