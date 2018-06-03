# .atom

## Contents

-	[Atom and package config](/.atom/config.cson "config.cson")
-	[Init file](/.atom/init.coffee "init.coffee")
-	[Keymap](/.atom/keymap.cson "keymap.cson")
-	[Package list](/.atom/package-list.txt "package-list.txt")
-	[Snippets](/.atom/snippets.cson "snippets.cson")
-	[User styles](/.atom/styles.less "styles.less")  

-	[Windows install script](/.atom/install.ps1)  

-	[README.md](#.atom)

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
		.\install.ps1
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