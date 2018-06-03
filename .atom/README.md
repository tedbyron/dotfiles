# .atom

-	[Atom and package config](../config.cson "")
-	[Init File](../init.coffee "init.coffee")
-	[Keymap](../keymap.cson "keymap.cson")
-	[Package List](../package-list.txt "package-list.txt")
-	[snippets.cson](../snippets.cson "snippets.cson")
-	[styles.less](../styles.less "styles.less")

-	[Windows install script](../install.ps1)

-	[README.md](../README.md)

## Prerequisites

-	Install [Atom](https://atom.io)

## Installation

1.	Run applicable install script
	-	Shell
	
		```sh
		./install.sh
		```

	-	Powershell
		
		```powershell
		\.install.ps1
		```

2.	Install packages from `package-list.txt` using `apm`

	```sh
	apm install --packages-file package-list.txt
	```

3.	After installing or updateing packages, output user-installed packages to `package-list.txt`

	```sh
	apm list --installed --bare > package-list.txt
	```

[//]: # (TODO: add shell script)