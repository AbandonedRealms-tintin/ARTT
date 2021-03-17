ARTT (Abandoned Realms / TinTin++)

GAME SERVER: https://abandonedrealms.com/

GAME CLIENT: https://tintin.mudhalla.net/

GAME SCRIPT: https://sourceforge.net/projects/artt/files/latest/download

Abandoned Realms is a roleplaying enforced, playerkilling encouraged
MUD.  This is not a world you will spend your time in alone.  There
will be many other adventurers you run into, in the lands.  Some of
these adventurers will become your greatest allies.  Others will be
enemies, who you may well be living in fear of.  These are real people,
and they will have ambitions and goals just like you.  The people are
what give Abandoned Realms its charm and make this a real experience.

Linux:
******

    1) install tintin++ vim tmux

    2) Place ARTT directory home

    3) find and type './linux.sh'

Windows 10 via WSL (Windows Subsystem for Linux):
*************************************************

    1) Use search assistant to open the 'For Developers' setting and enable 'Developer Mode'.  Accept it.

    2) Ctrl+Esc & type 'Turn Windows features on or off' select and turn on 'Windows Subsystem for Linux'

    3) Open web browser and type 'https://aka.ms/wslstore' now select/install Ubuntu, set up and sign in.

    4) Type 'sudo apt-get update' and 'sudo apt-get upgrade' and 'sudo apt-get install tmux vim tintin++'

    5) Download/run Mintty WSL Bridge and wsltty installer: https://github.com/mintty/wsltty/releases

    6) Open web browser and type 'https://sourceforge.net/projects/artt/files/latest/download' save/extract

    7) Using WSL Terminal navigate to /mnt/c/Users/<user_name>/Downloads/ARTT_<version>, type 'cp -R ARTT ~/'

    8) Next I type 'echo "alias artt='cd $HOME/ARTT;tmux new tt++ main.tin'" >> ~/.bashrc;source ~/.bashrc'

    9) WSL Terminal, maximize it and type 'artt', OG source: https://tintin.mudhalla.net/install.php#Windows

More helpful links:
*******************

    https://abandonedrealms.com/help/pk_control.php

    https://abandonedrealms.com/help/pk_newbie.php

    https://abandonedrealms.com/essays/stages.php

    https://abandonedrealms.com/essays/rp.php

    https://abandonedrealms.com/roleplay/
