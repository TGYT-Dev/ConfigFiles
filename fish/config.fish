if status is-interactive
    
  # Astetichs

  zfetch
  
  # Alias - Maybe make them actual scripts later
  
  alias roblox 'flatpak run org.vinegarhq.Sober'
  alias sober 'flatpak run org.vinegarhq.Sober'
  alias cat 'bat --theme="gruvbox-dark" --style=numbers,grid' 
  alias ls 'eza --icons --no-permissions --no-user --no-time --no-filesize'
  alias chrome google-chrome-stable
  alias google google-chrome-stable
  alias vencordInject 'sh -c "$(curl -sS https://vencord.dev/install.sh)"'
  alias nano nvim
  # Commands to run in interactive sessions can go here
end
starship init fish | source
