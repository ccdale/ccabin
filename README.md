# CCA Bin Files
Some useful (and probably not so useful) scripts for `$HOME/bin/` on your
linux desktop.

## unity-startup-windows.sh
script that uses `xrandr` and `wmctrl` to work out the screen size and
number of different workspaces on a Ubuntu Unity desktop.

You can set the number of workspaces in Unity with the gsettings command, so
for a set of workspaces that are 4 wide and 1 deep:
```
gsettings set org.compiz.core:/org/compiz/profiles/unity/plugins/core/ hsize 4
gsettings set org.compiz.core:/org/compiz/profiles/unity/plugins/core/ vsize 1
```


[modeline]: # ( vim: set fenc=utf-8 spell spl=en tw=76: )
