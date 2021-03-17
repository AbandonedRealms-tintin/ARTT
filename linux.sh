#!/usr/bin/env bash

# Abandoned Realms MUD launch script.

# GAME SERVER: https://abandonedrealms.com/

# GAME CLIENT: https://tintin.mudhalla.net/

# GAME SCRIPT: https://sourceforge.net/projects/artt/files/latest/download

# create shortcut, 0 or 1 ?

desktop_shortcut=1

# No tt++ than exit.

which tt++ > /dev/null 2>&1 || { echo "Please install tintin++"; exit 1; }

# No tmux than exit.

which tmux > /dev/null 2>&1 || { echo "Please install tmux"; exit 1; }

# Set term variable. Thanks: https://stackoverflow.com/a/63721547

terminal=$(ps -o comm= -p "$(($(ps -o ppid= -p "$(($(ps -o sid= -p "$$")))")))" | grep -Eo 'wslbridge2-back|mate-terminal|xfce4-terminal|gnome-terminal|lxterminal|xterm|konsole|x-terminal-emul|qterminal')

# ----------------------------
# Create desktop file for ARTT
# ----------------------------

if [ "$desktop_shortcut" = "1" ] && [ "$terminal" != "wslbridge2-back" ]; then

    # Files name/location
    
    desktop_file="$HOME/.local/share/applications/AbandonedRealms.desktop"

    # File exist yet?
    
    if [ ! -e "$desktop_file" ]; then

        # if no file locality, mkdir
        
        if [ ! -d "$HOME/.local/share/applications/" ]; then
        
            mkdir $HOME/.local/share/applications
            
            echo "Making directory $HOME/.local/share/applications"
            
        fi

        > $desktop_file
        
        echo '[Desktop Entry]' >> $desktop_file
        echo 'Encoding=UTF-8' >> $desktop_file
        echo 'Version=1.0' >> $desktop_file
        echo 'Name=AbandonedRealms' >> $desktop_file
        echo 'Comment=Play Abandoned Realms' >> $desktop_file

        # For lxterminal and mate-terminal
        
        if [ "$terminal" = "lxterminal" ] || [ "$terminal" = "mate-terminal" ]; then
        
            echo 'Terminal=false' >> $desktop_file

            # For all other terminals
        
        else
        
            echo 'Terminal=true' >> $desktop_file
            
        fi
        
        echo 'MimeType=text/plain' >> $desktop_file
        echo 'Type=Application' >> $desktop_file
        echo 'Categories=RolePlaying;ConsoleOnly;' >> $desktop_file
        echo "Path=$HOME/ARTT/." >> $desktop_file
        echo "Icon=$HOME/ARTT/ar.png" >> $desktop_file

        # For lxterminal, execute:
        
        if [ "$terminal" = "lxterminal" ]; then
        
            echo "Exec=lxterminal -e $HOME/ARTT/linux.sh" >> $desktop_file

        # For mate-terminal, execute:
        
        elif [ "$terminal" = "mate-terminal" ]; then
        
            echo "Exec=mate-terminal -e $HOME/ARTT/linux.sh" >> $desktop_file

        # Other terminals, execute:
        
        else
            echo "Exec=$HOME/ARTT/linux.sh" >> $desktop_file
        fi
        
        echo "Desktop shortcut created."
        
        chmod +x "$desktop_file"

        # If not on desktop, link it
        if [ ! -f "$HOME/Desktop/AbandonedRealms.desktop" ]; then
        
            ln -s $HOME/.local/share/applications/AbandonedRealms.desktop $HOME/Desktop/.
        fi
    fi
fi

if [ "$desktop_shortcut" = "1" ] && [ "$terminal" == "wslbridge2-back" ]; then

	desktop_file=$(ls /mnt/c/Users/*/Desktop | grep -o 'ARTT.lnk')
	
    if [ "$desktop_file" != "ARTT.lnk" ]; then

		echo "Creating shortcut...  Please wait"
		
		wslusc --name ARTT --icon ~/ARTT/ar.png "/mnt/c/Users/owner/AppData/Local/wsltty/bin/mintty.exe --WSL= --configdir="C:\Users\owner\AppData\Roaming\wsltty" -w max -t Abandoned_Realms -e tmux new -c ~/ARTT tt++ main.tin"
		
	fi
	
fi

# +------------------------------+
# | wslbridge2-back, launch ARTT |
# +------------------------------+

if [ "$terminal" = "wslbridge2-back" ]; then

    /mnt/c/Users/owner/AppData/Local/wsltty/bin/mintty.exe --WSL= --configdir="C:\Users\owner\AppData\Roaming\wsltty" -w max -T 'Abandoned Realms' -e tmux new -c ~/ARTT 'tt++ main.tin'

fi

# +--------------------+
# | xterm, launch ARTT |
# +--------------------+

if [ "$terminal" = "xterm" ]; then

    xterm -fa 'Monospace' -fs 14 -fullscreen -e 'tmux new "tt++ ~/ARTT/main.tin"'

fi

# +----------------------+
# | konsole, launch ARTT |
# +----------------------+

if [ "$terminal" = "konsole" ]; then

    konsole --workdir $HOME/ARTT/ --hide-menubar --fullscreen -e "tmux new 'tt++ $HOME/ARTT/main.tin'"

fi

# +-----------------------------+
# | Gnome-terminal, launch ARTT |
# +-----------------------------+

if [ "$terminal" = "gnome-terminal" ]; then

    gnome-terminal --command="tmux new 'tt++ main.tin'" --full-screen --hide-menubar --working-directory=$HOME/ARTT/

fi

# +----------------------------+
# | Mate-terminal, launch ARTT |
# +----------------------------+

if [ "$terminal" = "mate-terminal" ]; then

    mate-terminal --zoom=1.2 -e "tmux new 'tt++ $HOME/ARTT/main.tin'" --maximize --hide-menubar --title=AbandonedRealms --working-directory=$HOME/ARTT/

fi

# +-----------------------------+
# | xfce4-terminal, launch ARTT |
# +-----------------------------+

if [ "$terminal" = "xfce4-terminal" ]; then

    xfce4-terminal --maximize --hide-scrollbar --hide-menubar --hide-borders --hide-toolbar --default-working-directory="$HOME/ARTT/" --command="tmux new 'tt++ $HOME/ARTT/main.tin'"

fi

# +-------------------------+
# | Lxterminal, launch ARTT |
# +-------------------------+

if [ "$terminal" = "lxterminal" ]; then

    look_in_lxde_rc="$(grep -o 'AbandonedRealms' $HOME/.config/openbox/lxde-rc.xml)"
    
    if [ "$look_in_lxde_rc" != "AbandonedRealms" ]; then
    
        match='<applications>'
        
        insert='<!-- AbandonedRealms.com -->\n  <application name=\"lxterminal\" class=\"Lxterminal\">\n    <decor>no<\/decor>\n    <layer>normal<\/layer>\n    <fullscreen>true<\/fullscreen>\n  <\/application>'
        
        file="$HOME/.config/openbox/lxde-rc.xml"
        
        sed -i "s/$match/$match\n$insert/" $file
        
        openbox --reconfigure
    fi
    
    lxterminal --working-directory=$HOME/ARTT/ --title=AbandonedRealms -e "tmux new 'tt++ $HOME/ARTT/main.tin'"

fi

# +------------------------+
# | qterminal, launch ARTT |
# +------------------------+

if [ "$terminal" = "x-terminal-emul" ] || [ "$terminal" = "qterminal" ]; then

    if ! [ -f "$HOME/.config/artt.conf" ]; then

        cp $HOME/.config/qterminal.org/qterminal.ini $HOME/.config/artt.conf

        echo "Creating ~/.config/artt.conf"

        # Read artt.conf to find said variables
        qterm_max=$(cat $HOME/.config/artt.conf | grep -o 'isMaximized=.*')
        qterm_tab=$(cat $HOME/.config/artt.conf | grep -o 'HideTabBarWithOneTab=.*')
        qterm_menu=$(cat $HOME/.config/artt.conf | grep -o 'MenuVisible=.*')
        qterm_high=$(cat $HOME/.config/artt.conf | grep -o 'highlightCurrentTerminal=.*')
        qterm_bar=$(cat $HOME/.config/artt.conf | grep -o 'ScrollbarPosition=.*')

        # If maximized is set to false, make true

        if [ "$qterm_max" != "LastWindowMaximized=true" ]; then

            find ~/.config/ -name 'artt.conf' | xargs sed -i 's/LastWindowMaximized=.*/LastWindowMaximized=true/g'

        fi

        # If hide tabs is set to false, make true

        if [ "$qterm_tab" != "HideTabBarWithOneTab=true" ]; then

            find ~/.config/ -name 'artt.conf' | xargs sed -i 's/HideTabBarWithOneTab=.*/HideTabBarWithOneTab=true/g'

        fi

        # If menu vis is set to true, make false

        if [ "$qterm_menu" != "MenuVisible=false" ]; then

            find ~/.config/ -name 'artt.conf' | xargs sed -i 's/MenuVisible=.*/MenuVisible=false/g'

        fi

        # If hide highlight term is set to true, make false

        if [ "$qterm_high" != "highlightCurrentTerminal=false" ]; then

            find ~/.config/ -name 'artt.conf' | xargs sed -i 's/highlightCurrentTerminal=.*/highlightCurrentTerminal=false/g'

        fi

        # If scrollbarposition not set to 0, make 0

        if [ "$qterm_bar" != "ScrollbarPosition=0" ]; then

            find ~/.config/ -name 'artt.conf' | xargs sed -i 's/ScrollbarPosition=.*/ScrollbarPosition=0/g'

        fi

    fi

    qterminal -p artt -e "tmux new tt++ $HOME/ARTT/main.tin" -w $HOME/ARTT/

fi
