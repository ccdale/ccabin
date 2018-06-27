# CCA Bin Files
Some useful (and probably not so useful) scripts for `$HOME/bin/` on your
linux desktop.

I link these from the repository to my bin directory, that way I always get
the up-to-date version running:
```
ln -s ${HOME}/src/ccabin/start-and-place.sh ${HOME}/bin/
```

## vagrant directory
see [vagrant readme](vagrant/README.md) for vagrant specific scripts.

## vpnonoff.sh
script to toggle, turn on or turn off your Network Manager based VPN
connection.
To use it you'll need to configure the name of your VPN connection exactly
as the output of `nmcli` gives it (see the top of the script).
Hard link it to the following names and it'll do the right thing:
```
togglevpn
vpnstart
vpnstop
```

## pvr, update-pvr, cleanpvr.sh, radiotidy
Scripts to utilise the wonderful [get_iplayer](https://github.com/get-iplayer/get_iplayer) as a PVR.
As the BBC regularly blocks the [AirVPN](https://airvpn.org/) I use, I had to also write the off/on
scripts above to ensure that the VPN wasn't running while downloading TV
programs - strangely, the BBC don't block you downloading radio programs
while the VPN is running.

Now I can run the `pvr` script from cron in the middle of the night, knowing
that it'll stop the VPN, download the programs and start the VPN when it
completes, hurrah!

## unity-startup-windows.sh
script that uses `xrandr` and `wmctrl` to work out the screen size and
number of different workspaces on a Ubuntu Unity desktop.  Unity doesn't
really have different workspaces, all windows are placed within one massive
field, so a spot of integer arithmetic is required to work out where to
place the windows.

I use this to auto-start Gvim, Firefox and Slack and place them
onto workspaces 2, 3 and 4.

You can set the number of workspaces in Unity with the gsettings command, so
for a set of workspaces that are 4 wide and 1 deep, which on my 1920x1080
screen gives a desktop size of 7680x1080:
```
gsettings set org.compiz.core:/org/compiz/profiles/unity/plugins/core/ hsize 4
gsettings set org.compiz.core:/org/compiz/profiles/unity/plugins/core/ vsize 1
```
To run this script at start up you can create a 'Desktop Entry' file for the
window manager:
```
echo "[Desktop Entry]
Type=Application
Exec=${HOME}/bin/unity-startup-windows.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=unity-startup-windows
Name=unity-startup-windows
Comment[en_US]=
Comment=
" > ~/.config/autostart/unity-startup-windows.desktop
 ```

## start-and-place.sh
This is similiar to `unity-startup-windows.sh` except that it starts an
individual program and places it on the required desktop
```
$ start-and-place.sh -h
start-and-place.sh <program> <title> <desktop no.>

  Places the <program> with the (partial) window
  title <title> on desktop <desktop no.>

  i.e. start-and-place.sh gvim GVIM 2
    will place the gvim window on desk 2
```
and make a Desktop Entry file for each program you want started, calling it
the name of the progam you wish to start (to avoid confusion):

```
echo "[Desktop Entry]
Type=Application
Exec=${HOME}/bin/start-and-place.sh firefox Firefox 3
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Firefox
Name=Firefox
Comment[en_US]=
Comment=
" > ~/.config/autostart/firefox.desktop
 ```

[modeline]: # ( vim: set fenc=utf-8 spell spl=en tw=76: )
