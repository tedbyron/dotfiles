# .atom

## Prerequisites

-	Install [Atom](https://atom.io)

## Installation

1.	Run applicable install script

		-		Shell

				```sh
				./install.sh
				```

		-		Powershell

				```powershell
				.\install.ps1
				```

		-		What it does

				-		Copy `~/.atom/` into repository without overwriting
				-		Move `~/.atom/` to `~/.atom.backup`
				-		Create symlink from `~/.atom/` to the repository

2.	Install packages from `packages.txt` using `apm`

		```sh
		apm install --packages-file package.txt
		```

3.	After installing or updating packages, output user-installed packages to `packages.txt`

		```sh
		apm list --installed --bare > packages.txt
		```

[//]: # (TODO: add shell script)
