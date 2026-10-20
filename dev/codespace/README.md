# Codespace setup

> This also would work for linux

> if you do `haxe --version` after this and it's the latest version, then you a lucky bitch cause I keep geting 4.3.3
> Maybe its the codespace, idk

Run these in da terminal:
```bash
sudo add-apt-repository ppa:haxe/releases
sudo apt update
sudo apt install haxe -y
```

It will (proobably) prompt you for stuff, accept it

do these next:
```bash
haxelib setup dev/codespace/.haxelib
haxelib install hmm
haxelib run hmm install
haxelib run lime setup
haxelib run lime setup alias -y
```

## Formatting with formatter

```bash
haxelib run formatter -s source
```
