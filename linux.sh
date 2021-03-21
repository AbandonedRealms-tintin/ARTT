#!/usr/bin/env bash

# +------------------------------+
# | Abandoned realms tmux/tintin |
# +------------------------------+

# Q: What does this bash script do?

# A: execute fullscreen tmux/tt++ terminal and create desktop shortcut to game.

# GAME SERVER: https://abandonedrealms.com/

# GAME CLIENT: https://tintin.mudhalla.net/

# GAME SCRIPT: https://sourceforge.net/projects/artt/files/latest/download

# create shortcut, 0 or 1 ?

desktop_shortcut=1

show_256=yes

# No tt++ than exit.

which tt++ > /dev/null 2>&1 || { echo "Please install tintin++"; exit 1; }

# No tmux than exit.

which tmux > /dev/null 2>&1 || { echo "Please install tmux"; exit 1; }

# Set term variable. Thanks: https://stackoverflow.com/a/63721547

terminal=$(ps -o comm= -p "$(($(ps -o ppid= -p "$(($(ps -o sid= -p "$$")))")))" | grep -Eo 'wslbridge2-back|mate-terminal|xfce4-terminal|gnome-terminal|lxterminal|xterm|konsole|x-terminal-emul|qterminal|tmux: server')

# +------------------------------+
# | Create desktop file for ARTT |
# +------------------------------+

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
        
        if [ "$terminal" = "lxterminal" ]; then

            # lxterminal append this

            echo "Exec=lxterminal -e $HOME/ARTT/linux.sh" >> $desktop_file
        
        elif [ "$terminal" = "mate-terminal" ]; then
        
            # mate-terminal append this

            echo "Exec=mate-terminal -e $HOME/ARTT/linux.sh" >> $desktop_file
        
        else

            # other terminals append this

            echo "Exec=$HOME/ARTT/linux.sh" >> $desktop_file

        fi
        
        echo "Desktop shortcut created."
        
        chmod +x "$desktop_file"

        fi

    if [ ! -f "$HOME/Desktop/AbandonedRealms.desktop" ]; then

        # If no link on desktop than create link

        ln -s $HOME/.local/share/applications/AbandonedRealms.desktop $HOME/Desktop/.
    fi
fi

# +------------------------------+
# | For Windows Desktop shortcut |
# +------------------------------+

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

        # Read ~/.config/artt.conf to find values of qterminal setting variables

        qterm_max=$(cat $HOME/.config/artt.conf | grep -o 'isMaximized=.*')

        qterm_tab=$(cat $HOME/.config/artt.conf | grep -o 'HideTabBarWithOneTab=.*')

        qterm_menu=$(cat $HOME/.config/artt.conf | grep -o 'MenuVisible=.*')

        qterm_high=$(cat $HOME/.config/artt.conf | grep -o 'highlightCurrentTerminal=.*')

        qterm_bar=$(cat $HOME/.config/artt.conf | grep -o 'ScrollbarPosition=.*')

        if [ "$qterm_max" != "LastWindowMaximized=true" ]; then

            # If maximized is set to false, make true

            find ~/.config/ -name 'artt.conf' | xargs sed -i 's/LastWindowMaximized=.*/LastWindowMaximized=true/g'

        fi

        if [ "$qterm_tab" != "HideTabBarWithOneTab=true" ]; then

            # If hide tabs is not true, make true

            find ~/.config/ -name 'artt.conf' | xargs sed -i 's/HideTabBarWithOneTab=.*/HideTabBarWithOneTab=true/g'

        fi

        if [ "$qterm_menu" != "MenuVisible=false" ]; then

            # If menu visible is not false, make false

            find ~/.config/ -name 'artt.conf' | xargs sed -i 's/MenuVisible=.*/MenuVisible=false/g'

        fi

        if [ "$qterm_high" != "highlightCurrentTerminal=false" ]; then

            # If highlight current terminal is not false, make false

            find ~/.config/ -name 'artt.conf' | xargs sed -i 's/highlightCurrentTerminal=.*/highlightCurrentTerminal=false/g'

        fi

        if [ "$qterm_bar" != "ScrollbarPosition=0" ]; then

            # If scrollbarposition not set to 0, make 0

            find ~/.config/ -name 'artt.conf' | xargs sed -i 's/ScrollbarPosition=.*/ScrollbarPosition=0/g'

        fi

    fi

    qterminal -p artt -e "tmux new tt++ $HOME/ARTT/main.tin" -w $HOME/ARTT/

fi

# Show colors for tmux

if [ "$terminal" == "tmux: server" ]; then

    set -eu # Fail on errors or undeclared variables

    printable_colours=256

    # Return a colour that contrasts with the given colour
    # Bash only does integer division, so keep it integral
    function contrast_colour {
        local r g b luminance
        colour="$1"

        if (( colour < 16 )); then # Initial 16 ANSI colours
            (( colour == 0 )) && printf "15" || printf "0"
            return
        fi

        # Greyscale # rgb_R = rgb_G = rgb_B = (number - 232) * 10 + 8
        if (( colour > 231 )); then # Greyscale ramp
            (( colour < 244 )) && printf "15" || printf "0"
            return
        fi

        # All other colours:
        # 6x6x6 colour cube = 16 + 36*R + 6*G + B  # Where RGB are [0..5]
        # See http://stackoverflow.com/a/27165165/5353461

        # r=$(( (colour-16) / 36 ))
        g=$(( ((colour-16) % 36) / 6 ))
        # b=$(( (colour-16) % 6 ))

        # If luminance is bright, print number in black, white otherwise.
        # Green contributes 587/1000 to human perceived luminance - ITU R-REC-BT.601
        (( g > 2)) && printf "0" || printf "15"
        return

        # Uncomment the below for more precise luminance calculations

        # # Calculate percieved brightness
        # # See https://www.w3.org/TR/AERT#color-contrast
        # # and http://www.itu.int/rec/R-REC-BT.601
        # # Luminance is in range 0..5000 as each value is 0..5
        # luminance=$(( (r * 299) + (g * 587) + (b * 114) ))
        # (( $luminance > 2500 )) && printf "0" || printf "15"
    }

    # Print a coloured block with the number of that colour
    function print_colour {
        local colour="$1" contrast
        contrast=$(contrast_colour "$1")
        printf "\e[48;5;%sm" "$colour"                # Start block of colour
        printf "\e[38;5;%sm%3d" "$contrast" "$colour" # In contrast, print number
        printf "\e[0m "                               # Reset colour
    }

    # Starting at $1, print a run of $2 colours
    function print_run {
        local i
        for (( i = "$1"; i < "$1" + "$2" && i < printable_colours; i++ )) do
            print_colour "$i"
        done
        printf "  "
    }

    # Print blocks of colours
    function print_blocks {
        local start="$1" i
        local end="$2" # inclusive
        local block_cols="$3"
        local block_rows="$4"
        local blocks_per_line="$5"
        local block_length=$((block_cols * block_rows))

        # Print sets of blocks
        for (( i = start; i <= end; i += (blocks_per_line-1) * block_length )) do
            printf "\n" # Space before each set of blocks
            # For each block row
            for (( row = 0; row < block_rows; row++ )) do
                # Print block columns for all blocks on the line
                for (( block = 0; block < blocks_per_line; block++ )) do
                    print_run $(( i + (block * block_length) )) "$block_cols"
                done
                (( i += block_cols )) # Prepare to print the next row
                printf "\n"
            done
        done
    }

    print_run 0 16 # The first 16 colours are spread over the whole spectrum
    printf "\n"
    print_blocks 16 231 6 6 3 # 6x6x6 colour cube between 16 and 231 inclusive
    print_blocks 232 255 12 2 1 # Not 50, but 24 Shades of Grey

fi
