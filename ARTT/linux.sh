#!/usr/bin/env bash

# Quick launch Abandoned Realms MUD in TinTin++/tmux w/ maximized/fullscreen.

# Dependencies:

# THE MMORPG SERVER
# https://abandonedrealms.com/

# THE GAME CLIENT
# https://tintin.mudhalla.net/

# THE ARTT SCRIPTS
# https://sourceforge.net/projects/artt/files/latest/download

# Create desktop quick launch shortcut (1 for yes, 0 for no)
desktop_shortcut=1

# Get tintin++ installation status.
which tt++ > /dev/null 2>&1 || { echo "Please install tintin++"; exit 1; }

# Set xterm installation status.
xterm="$(dpkg -s xterm > /dev/null 2>&1 | grep -o 'Status: install' | cut -c9-15)"

# Set tmux installation status.
tmux="$(dpkg -s tmux 2> /dev/null | grep -o 'Status: install' | cut -c9-15)"

# Set interface.
if [ -z "$DISPLAY" ]; then
    interface="CLI"
else
    interface="GUI"
fi

# Is tmux running?
if [ -z "$TMUX" ]; then
    tmux_open="no"
else
    tmux_open="yes"
fi

# Set desktop environment.
if [ "$XDG_CURRENT_DESKTOP" = "" ]; then
    desktop="$(echo "$XDG_DATA_DIRS" | grep -Eo 'mate|lxde|xfce|kde|gnome')"
    desktop="$(echo $desktop | tr '[:upper:]' '[:lower:]')"
else
    desktop="$XDG_CURRENT_DESKTOP"
    desktop="$(echo $desktop | tr '[:upper:]' '[:lower:]')"
fi

# Set terminal emulator.
process_ID="$(ps -p$PPID | grep -o '[0-9]*' | head -1)"
terminal="$(pstree -p | grep $process_ID | grep -Eo 'mate-terminal|xfce4-terminal|gnome-terminal|lxterminal|xterm|konsole' | tail -1)"

# Run tmux with CLI, launching tt++ and vim within.
if [ -z "$TMUX" ] && [ "$interface" = "CLI" ] && [ "$tmux" = "install" ]; then
    tmux kill-window -t :1
    tmux new-window \; splitw -h
    tmux new-session -c $HOME/ARTT/ -d 'tt++ main.tin' \; split-window -h -c $HOME/ARTT/ 'vi *.tin' \; attach \; lastp
fi

# ----------------------------
# Create desktop file for ARTT
# ----------------------------
# if applications directory doesn't exist, create it
if [ ! -d "$HOME/.local/share/applications/" ]; then
    mkdir $HOME/.local/share/applications
    echo "Making directory $HOME/.local/share/applications"
fi;

# Where is desktop file saved?
desktop_file="$HOME/.local/share/applications/AbandonedRealms.desktop"

# Does desktop file exist yet?
if [ ! -e "$desktop_file" ]; then

    # Create desktop file
    > $desktop_file
    echo '[Desktop Entry]' >> $desktop_file
    echo 'Encoding=UTF-8' >> $desktop_file
    echo 'Version=1.0' >> $desktop_file
    echo 'Name=AbandonedRealms' >> $desktop_file
    echo 'Comment=Portal to Abandoned Realms' >> $desktop_file

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
        echo "Exec=lxterminal --command $HOME/ARTT/linux.sh" >> $desktop_file

    # For mate-terminal, execute:
    elif [ "$terminal" = "mate-terminal" ]; then
        echo "Exec=mate-terminal --zoom=1.4 --command=\"tmux new 'tt++ $HOME/ARTT/main.tin'\" --window-with-profile=abandonedrealms --maximize --hide-menubar --title=AbandonedRealms --working-directory=$HOME/ARTT/" >> $desktop_file

    # For all other terminals, execute:
    else
        echo "Exec=$HOME/ARTT/linux.sh" >> $desktop_file
    fi
    echo "Desktop shortcut created."
    chmod +x "$desktop_file"

    # If link to desktop file is not on desktop, link it
    if [ ! -f "$HOME/Desktop/AbandonedRealms.desktop" ] && [ "$desktop_shortcut" = "1" ]; then
        ln -s $HOME/.local/share/applications/AbandonedRealms.desktop $HOME/Desktop/.
    fi
fi

# ---------------------------
# Add ARTT to gnome favorites
# ---------------------------
if [ "$desktop" = "gnome" ]; then

    # List favorite-apps
    apps_list="gsettings get org.gnome.shell favorite-apps"

    # If AbandonedRealms.desktop has not been set, set
    if [[ ! "$apps_list" =~ 'AbandonedRealms.desktop' ]]; then
        apps_list="$(gsettings get org.gnome.shell favorite-apps | tr -d '[]| ')"
        apps_list="['AbandonedRealms.desktop', $apps_list]"
        gsettings set org.gnome.shell favorite-apps "$apps_list"
    fi
fi

# -------------------------------------
# Configure gnome-terminal, launch ARTT
# -------------------------------------
if [ "$terminal" = "gnome-terminal" ] && [ "$desktop" = "gnome" ]; then

    # Newest versions of gnome-terminal use dconf
    which dconf > /dev/null 2>&1 || { echo "Please install dconf-cli"; exit 1; }

    # Need this to create random ID for new profile
    which uuidgen > /dev/null 2>&1 || { echo "Please install uuid-runtime"; exit 1; }

    # Get profiles from dconf to see if my_profile exists
    my_profile="$(dconf dump /org/gnome/terminal/legacy/profiles:/ | grep -Eo 'abandonedrealms')"

    # If profile exists, launch app
    if [ -n "$my_profile" ]; then
	    echo "Entering Abandoned Realms..."

        # Launch app in gnome-terminal
        gnome-terminal --command='tt++ main.tin' --window-with-profile=abandonedrealms --full-screen --hide-menubar --working-directory=$HOME/ARTT/

    # If profile does not exist, create it
    else

        # Base16 - Gnome Terminal color scheme install script
        # Source:
        # http://pastebin.com/h3p3awiT 
        # (edited for use with ARTT scripts)
        [[ -z "$PROFILE_NAME" ]] && PROFILE_NAME="abandonedrealms"
        [[ -z "$PROFILE_SLUG" ]] && PROFILE_SLUG="abandonedrealms"
        [[ -z "$DCONF" ]] && DCONF=dconf
        [[ -z "$UUIDGEN" ]] && UUIDGEN=uuidgen

        dset() {
            local key="$1"; shift
            local val="$1"; shift

            if [[ "$type" == "string" ]]; then
                val="'$val'"
            fi

            "$DCONF" write "$PROFILE_KEY/$key" "$val"
        }

        # because dconf still doesn't have "append"
        dlist_append() {
            local key="$1"; shift
            local val="$1"; shift

            local entries="$(
                {
                    "$DCONF" read "$key" | tr -d '[]' | tr , "\n" | fgrep -v "$val"
                    echo "'$val'"
                } | head -c-1 | tr "\n" ,
            )"

            "$DCONF" write "$key" "[$entries]"
        }

        [[ -z "$BASE_KEY_NEW" ]] && BASE_KEY_NEW=/org/gnome/terminal/legacy/profiles:

        if [[ -n "`$DCONF list $BASE_KEY_NEW/`" ]]; then

            PROFILE_SLUG=`uuidgen`

            if [[ -n "`$DCONF read $BASE_KEY_NEW/default`" ]]; then
                DEFAULT_SLUG=`$DCONF read $BASE_KEY_NEW/default | tr -d \'`
            else
                DEFAULT_SLUG=`$DCONF list $BASE_KEY_NEW/ | grep '^:' | head -n1 | tr -d :/`
            fi

            DEFAULT_KEY="$BASE_KEY_NEW/:$DEFAULT_SLUG"
            PROFILE_KEY="$BASE_KEY_NEW/:$PROFILE_SLUG"

            # copy existing settings from default profile
            $DCONF dump "$DEFAULT_KEY/" | $DCONF load "$PROFILE_KEY/"

            # add new copy to list of profiles
            dlist_append $BASE_KEY_NEW/list "$PROFILE_SLUG"

            # update profile values with theme options
            dset visible-name "'$PROFILE_NAME'"
            dset palette "['#222d3f', '#a82320', '#32a548', '#e58d11', '#3167ac', '#781aa0', '#2c9370', '#b0b6ba', '#212c3c', '#d4312e', '#2d9440', '#e5be0c', '#3c7dd2', '#8230a7', '#35b387', '#e7eced']"
            dset background-color "'#000000'"
            dset foreground-color "'#BBBBBB'"
            dset bold-color "'#DDDDDD'"
            dset bold-color-same-as-fg "true"
            dset use-theme-colors "false"
            dset use-theme-background "false"
            dset scrollbar-policy "'never'"

            unset PROFILE_NAME
            unset PROFILE_SLUG
            unset DCONF
            unset UUIDGEN

            echo "abandonedrealms profile created."
            echo "Entering Abandoned Realms..."

            # Launch Abandoned Realms in gnome-terminal
            gnome-terminal --command='tt++ main.tin' --window-with-profile=abandonedrealms --full-screen --hide-menubar --working-directory=$HOME/ARTT/

        fi
    fi
fi

# ---------------------------------
# Configure lxterminal, launch ARTT
# ---------------------------------
if [ "$terminal" = "lxterminal" ]; then

    # Does USER own the lxterminal.conf directory?
    lxterminal_owner="$(ls -alG $HOME/.config/ | grep lxterminal | cut -d' ' -f4)"
    if [ ! -f "$HOME/.config/lxterminal/lxterminal.conf" ] && [ "$lxterminal_owner" != "$USER" ]; then

        echo -e "\033[1mEnter root passwd to change ownership of ~/.config/lxterminal/, or exit shell using CTRL-D and run:\033[0m"
        echo -e "su -c \"chown -R \$USER:\$USER \$HOME/.config/lxterminal/\""
        su -c "chown -R $USER:$USER $HOME/.config/lxterminal/"
    elif [ -f "$HOME/.config/lxterminal/lxterminal.conf" ] && [ "$lxterminal_owner" = "$USER" ]; then
        if ! [ -f "$HOME/.config/lxterminal/lxterminal.conf.bak" ]; then
            cp $HOME/.config/lxterminal/lxterminal.conf $HOME/.config/lxterminal/lxterminal.conf.bak
            echo "Creating lxterminal.conf.bak"
        fi;

        # Read lxterminal.conf to find said variables
        scrollbar=$(cat $HOME/.config/lxterminal/lxterminal.conf | grep -o 'hidescrollbar=.*')
        menubar=$(cat $HOME/.config/lxterminal/lxterminal.conf | grep -o 'hidemenubar=.*')

        if [ -n "$scrollbar" ]; then

            # If scrollbar is set to false, make true
            if [ "$scrollbar" != "hidescrollbar=true" ]; then
                find ~/.config/lxterminal/ -name 'lxterminal.conf' | xargs sed -i 's/hidescrollbar=.*/hidescrollbar=true/g'
            fi
        else

            # If scrollbar is not set, set true
            printf "hidescrollbar=true\n" >> $HOME/.config/lxterminal/lxterminal.conf
        fi;

        if [ -n "$menubar" ]; then

            # If menubar is set to false, make true
            if [ "$menubar" != "hidemenubar=true" ]; then
                find ~/.config/lxterminal/ -name 'lxterminal.conf' | xargs sed -i 's/hidemenubar=.*/hidemenubar=true/g'
            fi
        else

            # If menubar is not set, set true
            printf "hidemenubar=true\n" >> $HOME/.config/lxterminal/lxterminal.conf
        fi
    else
        echo "file ~/.config/lxterminal/lxterminal.conf not fond"
    fi;

    # Check for lxde-rc.xml files presence
    if [ -d "$HOME/.config/openbox/" ]; then
        if [ -f "$HOME/.config/openbox/lxde-rc.xml" ]; then
            if ! [ -f "$HOME/.config/openbox/lxde-rc.xml.bak" ]; then

                # Create lxde-rc.xml backup before modifying
                cp $HOME/.config/openbox/lxde-rc.xml $HOME/.config/openbox/lxde-rc.xml.bak
                echo "Creating ~/.config/openbox/lxde-rc.xml.bak'"
            fi;

            look_in_lxderc="$(grep -o 'AbandonedRealms' $HOME/.config/openbox/lxde-rc.xml)"
            if [ "$look_in_lxderc" != "AbandonedRealms" ]; then
                match='<applications>'
                insert='<!-- AbandonedRealms.com -->\n  <application name=\"lxterminal\" class=\"Lxterminal\">\n    <decor>no<\/decor>\n    <layer>normal<\/layer>\n    <fullscreen>true<\/fullscreen>\n  <\/application>'
                file="$HOME/.config/openbox/lxde-rc.xml"
                sed -i "s/$match/$match\n$insert/" $file
            fi
        else
            echo " ~/.config/openbox/lxde-rc.xml not found."
        fi
    else
        echo "~/.config/openbox/ not found."
    fi
    openbox --reconfigure
	echo "Entering Abandoned Realms..."
    lxterminal --working-directory=$HOME/ARTT/ --title=AbandonedRealms -e tt++ $HOME/ARTT/main.tin
fi

# -------------------------------------
# Configure xfce4-terminal, launch ARTT
# -------------------------------------
if [ "$terminal" = "xfce4-terminal" ]; then

    # If directory for xfce4-terminal config does not exist, create it
    if [ ! -d "$HOME/.config/xfce4/terminal/" ]; then
        mkdir $HOME/.config/xfce4/terminal/
        echo "Making xfce4-terminal config directory."
    fi;

    # If file:terminalrc does not exist, create it
    if [ ! -f "$HOME/.config/xfce4/terminal/terminalrc" ]; then
        > $HOME/.config/xfce4/terminal/terminalrc
        echo '[Configuration]' >> $HOME/.config/xfce4/terminal/terminalrc
        echo 'ScrollingBar=FALSE' >> $HOME/.config/xfce4/terminal/terminalrc
        echo "Making xfce4-terminal config file."

    # If file:terminalrc does exist, examine it
    else

        # If Scrollingbar value is TRUE set to FALSE
        scrollbar_value="$(grep Scrolling $HOME/.config/xfce4/terminal/terminalrc | cut -d'=' -f2)"
        if [ -n "$scrollbar_value" ] && [ "$scrollbar_value" = "TRUE" ]; then
            find ~/.config/xfce4/terminal/ -name 'terminalrc' | xargs sed -i 's/\ScrollingBar=.*/\ScrollingBar=FALSE/g'

        # If Scrollingbar value is unset, set it
        elif [ -z "$scrollbar_value" ]; then
            echo 'ScrollingBar=FALSE' >> $HOME/.config/xfce4/terminal/terminalrc
        fi
    fi

    # Launch AbandonedRealms in xfce4-terminal
	echo "Entering Abandoned Realms..."
    xfce4-terminal --maximize --hide-menubar --hide-borders --hide-toolbar --default-working-directory="$HOME/ARTT/" --command="tt++ $HOME/ARTT/main.tin"

fi

# ------------------------------
# Configure konsole, launch ARTT
# ------------------------------
if [ "$terminal" = "konsole" ] && [ "$desktop" = "kde" ]; then

    # If konsole profile abandonedrealms does not exist, create it
    konsole_profile="$HOME/.kde/share/apps/konsole/abandonedrealms.profile"
    if [ ! -f "$konsole_profile" ]; then

        > "$konsole_profile"
        echo '[Appearance]' >> $konsole_profile
        echo 'ColorScheme=Linux' >> $konsole_profile
        echo 'Font=Monospace,12,-1,5,50,0,0,0,0,0' >> $konsole_profile
        echo ' ' >> $konsole_profile
        echo '[General]' >> $konsole_profile
        echo 'Name=abandonedrealms' >> $konsole_profile
        echo 'Parent=FALLBACK/' >> $konsole_profile
        echo ' ' >> $konsole_profile
        echo '[Scrolling]' >> $konsole_profile
        echo 'ScrollBarPosition=2' >> $konsole_profile
        echo "abandonedrealms profile created."

        # Launch Abandoned Realms in konsole
	    echo "Entering Abandoned Realms..."
        konsole --profile abandonedrealms --workdir $HOME/ARTT/ --hide-menubar --fullscreen -e tt++ $HOME/ARTT/main.tin
    else

        # Launch Abandoned Realms in konsole
	    echo "Entering Abandoned Realms..."
        konsole --profile abandonedrealms --workdir $HOME/ARTT/ --hide-menubar --fullscreen -e tt++ $HOME/ARTT/main.tin
    fi
fi

# ------------------------------------
# Configure mate-terminal, launch ARTT
# ------------------------------------
if [ "$terminal" = "mate-terminal" ] && [ "$desktop" = "mate" ]; then

    # Create mate-terminal profile
    # Source:
    # https://github.com/oz123/solarized-mate-terminal
    # (modified for use in ARTT scripts)

    which dconf > /dev/null 2>&1 || { echo "Please install dconf-cli"; exit 1; }

    if [[ $1 == "--reset" ]]; then
       dconf reset -f /org/mate/terminal/global/profile-list
       dconf reset -f /org/mate/terminal/profiles
       exit 0
    fi

    # Read profiles as string
    PROFILES=`dconf read /org/mate/terminal/global/profile-list`

    # Add new profiles
    if [ -z "${PROFILES}" ]; then
	    PROFILES="['default','abandonedrealms']"
    else	
        if [[ "${PROFILES}" =~ 'abandonedrealms' ]]; then

            # Launch Abandoned Realms in mate-terminal
	        echo "Entering Abandoned Realms..."
            mate-terminal --zoom=1.4 --command="tmux new 'tt++ $HOME/ARTT/main.tin'" --window-with-profile=abandonedrealms --maximize --hide-menubar --title=AbandonedRealms --working-directory=$HOME/ARTT/
            exit 1

        else
	        M="'abandonedrealms']"
	        PROFILES=${PROFILES/\']/, $M}
        fi
    fi

    dconf write /org/mate/terminal/global/profile-list "${PROFILES}"

    PROFILE="abandonedrealms"
    # Do not use theme color
    dconf write /org/mate/terminal/profiles/${PROFILE}/use-theme-colors false

    # Set palette
    dconf write /org/mate/terminal/profiles/${PROFILE}/palette \"#070736364242:#DCDC32322F2F:#858599990000:#B5B589890000:#26268B8BD2D2:#D3D336368282:#2A2AA1A19898:#EEEEE8E8D5D5:#00002B2B3636:#CBCB4B4B1616:#58586E6E7575:#65657B7B8383:#838394949696:#6C6C7171C4C4:#9393A1A1A1A1:#FDFDF6F6E3E3\"
    # Set highlighted color to be different from foreground-color
    dconf write /org/mate/terminal/profiles/${PROFILE}/bold-color-same-as-fg false
    dconf write /org/mate/terminal/profiles/${PROFILE}/background-color \"#000000\"
    dconf write /org/mate/terminal/profiles/${PROFILE}/foreground-color \"#BBBBBB\"
    dconf write /org/mate/terminal/profiles/${PROFILE}/bold-color \"#DDDDDD\"
    dconf write /org/mate/terminal/profiles/${PROFILE}/visible-name \"abandonedrealms\"
    dconf write /org/mate/terminal/profiles/${PROFILE}/scrollbar-position \"hidden\"

    echo -e "\e[37;41mTerminal must be restarted\e[0m"

fi

if [ "$terminal" = "gnome-terminal" ] && [ "$desktop" = "x-cinnamon" ]; then

    # Newest versions of gnome-terminal use dconf
    which dconf > /dev/null 2>&1 || { echo "Please install dconf-cli"; exit 1; }

    # Need this to create random ID for new profile
    which uuidgen > /dev/null 2>&1 || { echo "Please install uuid-runtime"; exit 1; }

    # Get profiles from dconf to see if my_profile exists
    my_profile="$(dconf dump /org/gnome/terminal/legacy/profiles:/ | grep -Eo 'abandonedrealms')"

    # If profile exists, launch app
    if [ -n "$my_profile" ]; then
	    echo "Entering Abandoned Realms..."

        # Launch app in gnome-terminal
        gnome-terminal --command='tt++ main.tin' --window-with-profile=abandonedrealms --full-screen --hide-menubar --working-directory=$HOME/ARTT/

    # If profile does not exist, create it
    else

        # Next two lines added just for x-cinnamon gnome-terminal
        first_uuid="$(uuidgen)"
        dconf write /org/gnome/terminal/legacy/profiles:/:"$first_uuid"/visible-name "'artt'"

        # Base16 - Gnome Terminal color scheme install script
        # Source:
        # http://pastebin.com/h3p3awiT 
        # (edited for use with ARTT scripts)
        [[ -z "$PROFILE_NAME" ]] && PROFILE_NAME="abandonedrealms"
        [[ -z "$PROFILE_SLUG" ]] && PROFILE_SLUG="abandonedrealms"
        [[ -z "$DCONF" ]] && DCONF=dconf
        [[ -z "$UUIDGEN" ]] && UUIDGEN=uuidgen

        dset() {
            local key="$1"; shift
            local val="$1"; shift

            if [[ "$type" == "string" ]]; then
                val="'$val'"
            fi

            "$DCONF" write "$PROFILE_KEY/$key" "$val"
        }

        # because dconf still doesn't have "append"
        dlist_append() {
            local key="$1"; shift
            local val="$1"; shift

            local entries="$(
                {
                    "$DCONF" read "$key" | tr -d '[]' | tr , "\n" | fgrep -v "$val"
                    echo "'$val'"
                } | head -c-1 | tr "\n" ,
            )"

            "$DCONF" write "$key" "[$entries]"
        }

        [[ -z "$BASE_KEY_NEW" ]] && BASE_KEY_NEW=/org/gnome/terminal/legacy/profiles:

        if [[ -n "`$DCONF list $BASE_KEY_NEW/`" ]]; then

            PROFILE_SLUG=`uuidgen`

            if [[ -n "`$DCONF read $BASE_KEY_NEW/default`" ]]; then
                DEFAULT_SLUG=`$DCONF read $BASE_KEY_NEW/default | tr -d \'`
            else
                DEFAULT_SLUG=`$DCONF list $BASE_KEY_NEW/ | grep '^:' | head -n1 | tr -d :/`
            fi

            DEFAULT_KEY="$BASE_KEY_NEW/:$DEFAULT_SLUG"
            PROFILE_KEY="$BASE_KEY_NEW/:$PROFILE_SLUG"

            # copy existing settings from default profile
            $DCONF dump "$DEFAULT_KEY/" | $DCONF load "$PROFILE_KEY/"

            # add new copy to list of profiles
            dlist_append $BASE_KEY_NEW/list "$PROFILE_SLUG"

            # update profile values with theme options
            dset visible-name "'$PROFILE_NAME'"
            dset palette "['#222d3f', '#a82320', '#32a548', '#e58d11', '#3167ac', '#781aa0', '#2c9370', '#b0b6ba', '#212c3c', '#d4312e', '#2d9440', '#e5be0c', '#3c7dd2', '#8230a7', '#35b387', '#e7eced']"
            dset background-color "'#000000'"
            dset foreground-color "'#BBBBBB'"
            dset bold-color "'#DDDDDD'"
            dset bold-color-same-as-fg "true"
            dset use-theme-colors "false"
            dset use-theme-background "false"
            dset scrollbar-policy "'never'"

            unset PROFILE_NAME
            unset PROFILE_SLUG
            unset DCONF
            unset UUIDGEN

            echo "abandonedrealms profile created."
            echo "Entering Abandoned Realms..."

            # Launch Abandoned Realms in gnome-terminal
            gnome-terminal --command='tt++ main.tin' --window-with-profile=abandonedrealms --full-screen --hide-menubar --working-directory=$HOME/ARTT/

        fi
    fi

fi

if [ "$terminal" = "gnome-terminal" ] && [ "$desktop" = "unity" ]; then

    # Newest versions of gnome-terminal use dconf
    which dconf > /dev/null 2>&1 || { echo "Please install dconf-cli"; exit 1; }

    # Need this to create random ID for new profile
    which uuidgen > /dev/null 2>&1 || { echo "Please install uuid-runtime"; exit 1; }

    # Get profiles from dconf to see if my_profile exists
    my_profile="$(dconf dump /org/gnome/terminal/legacy/profiles:/ | grep -Eo 'abandonedrealms')"

    # If profile exists, launch app
    if [ -n "$my_profile" ]; then
	    echo "Entering Abandoned Realms..."

        # Launch app in gnome-terminal
        gnome-terminal --command='tt++ main.tin' --window-with-profile=abandonedrealms --full-screen --hide-menubar --working-directory=$HOME/ARTT/

    # If profile does not exist, create it
    else

        # Next two lines added just for x-cinnamon gnome-terminal
        first_uuid="$(uuidgen)"
        dconf write /org/gnome/terminal/legacy/profiles:/:"$first_uuid"/visible-name "'artt'"

        # Base16 - Gnome Terminal color scheme install script
        # Source:
        # http://pastebin.com/h3p3awiT 
        # (edited for use with ARTT scripts)
        [[ -z "$PROFILE_NAME" ]] && PROFILE_NAME="abandonedrealms"
        [[ -z "$PROFILE_SLUG" ]] && PROFILE_SLUG="abandonedrealms"
        [[ -z "$DCONF" ]] && DCONF=dconf
        [[ -z "$UUIDGEN" ]] && UUIDGEN=uuidgen

        dset() {
            local key="$1"; shift
            local val="$1"; shift

            if [[ "$type" == "string" ]]; then
                val="'$val'"
            fi

            "$DCONF" write "$PROFILE_KEY/$key" "$val"
        }

        # because dconf still doesn't have "append"
        dlist_append() {
            local key="$1"; shift
            local val="$1"; shift

            local entries="$(
                {
                    "$DCONF" read "$key" | tr -d '[]' | tr , "\n" | fgrep -v "$val"
                    echo "'$val'"
                } | head -c-1 | tr "\n" ,
            )"

            "$DCONF" write "$key" "[$entries]"
        }

        [[ -z "$BASE_KEY_NEW" ]] && BASE_KEY_NEW=/org/gnome/terminal/legacy/profiles:

        if [[ -n "`$DCONF list $BASE_KEY_NEW/`" ]]; then

            PROFILE_SLUG=`uuidgen`

            if [[ -n "`$DCONF read $BASE_KEY_NEW/default`" ]]; then
                DEFAULT_SLUG=`$DCONF read $BASE_KEY_NEW/default | tr -d \'`
            else
                DEFAULT_SLUG=`$DCONF list $BASE_KEY_NEW/ | grep '^:' | head -n1 | tr -d :/`
            fi

            DEFAULT_KEY="$BASE_KEY_NEW/:$DEFAULT_SLUG"
            PROFILE_KEY="$BASE_KEY_NEW/:$PROFILE_SLUG"

            # copy existing settings from default profile
            $DCONF dump "$DEFAULT_KEY/" | $DCONF load "$PROFILE_KEY/"

            # add new copy to list of profiles
            dlist_append $BASE_KEY_NEW/list "$PROFILE_SLUG"

            # update profile values with theme options
            dset visible-name "'$PROFILE_NAME'"
            dset palette "['#222d3f', '#a82320', '#32a548', '#e58d11', '#3167ac', '#781aa0', '#2c9370', '#b0b6ba', '#212c3c', '#d4312e', '#2d9440', '#e5be0c', '#3c7dd2', '#8230a7', '#35b387', '#e7eced']"
            dset background-color "'#000000'"
            dset foreground-color "'#BBBBBB'"
            dset bold-color "'#DDDDDD'"
            dset bold-color-same-as-fg "true"
            dset use-theme-colors "false"
            dset use-theme-background "false"
            dset scrollbar-policy "'never'"

            unset PROFILE_NAME
            unset PROFILE_SLUG
            unset DCONF
            unset UUIDGEN

            echo "abandonedrealms profile created."
            echo "Entering Abandoned Realms..."

            # Launch Abandoned Realms in gnome-terminal
            gnome-terminal --command='tt++ main.tin' --window-with-profile=abandonedrealms --full-screen --hide-menubar --working-directory=$HOME/ARTT/

        fi
    fi
fi
