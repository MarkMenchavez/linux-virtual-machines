# Hyprland 

Steps to setup Hyprland for Arch Linux (aarch64) on an M1 VMWare Fusion virtual machine.

### Installation

```
$ sudo pacman -S    hyprland \
          
                    mako \

                    mesa \

                    pipewire \
                    pipewire-alsa \
                    pipewire-pulse \
                    gst-plugin-pipewire \
                    wireplumber \

                    foot \

                    xdg-desktop-portal \
                    xdg-desktop-portal-hyprland \
                    xdg-desktop-portal-gtk \

                    hyprpolkitagent \

                    qt5-wayland \
                    qt6-wayland \

                    noto-fonts \
                    ttf-jetbrains-mono-nerd \

                    awww \
            
                    fuzzel \
            
                    brightnessctl \
                    playerctl \

                    dolphin \

$ yay -S            waypaper \
                    brave-bin
```

### Configuration

```
$ mkdir -p ~/.config/hypr
$ cp /usr/share/hypr/hyprland.lua ~/.config/hypr

$ nano ~/.config/hypr/hyprland.lua

    env
       LIBGL_ALWAYS_SOFTWARE = 1
    
    monitor
       output   = Virtual-1
       mode     = 2048x1152@60
       position = 0x0
       scale    = 1

    autostart
       systemctl --user start hyprpolkitagent
       foot --server

    terminal    = footclient
    browser     = brave
    menu        = fuzzel
    fileManager = dolphin
    wallpaper   = waypaper --random

    keybinds
       Return   = terminal
       B        = browser
       E        = fileManager
       R        = menu
       Q        = close
       W        = wallpaper
       X        = exit

$ sudo reboot
```

### Troubleshooting

```
$ start-hyprland

-- Verify if pipewire, pipewire-pulse and wireplumber are running.

systemctl --user enable --now pipewire.service
systemctl --user enable --now pipewire-pulse.service
systemctl --user enable --now wireplumber.service

-- if audio stutter
sudo nano /usr/share/wireplumber.conf.d/alsa-vm.conf
  audio.format "S16LE"
```

### Display Manager

```
$ sudo pacman -S sddm qt6-declarative qt6-svg
$ yay -S pixie-sddm-git

$ sudo mkdir -p /etc/sddm.conf.d
$ sudo nano /etc/sddm.conf.d/theme.conf
    [Theme]
    Current=pixie

$ sudo systemctl enable sddm
```


### Applications

```
$ sudo pacman -S    fastfetch htop gping \
                    
                    asciiquarium cmatrix \
                    
                    cava wiremix \
                    
                    starship \
                    bat eza ripgrep fg fzf zoxide\
                
                    kitty \
                    tmux \

$ yay -S            cbonsai
                    visual-studio-code-bin
```