# .atom

## Prerequisites

-   Install [Atom](https://atom.io)

## Installation

1.  Execute applicable install script

    -   Shell

    	```sh
    	./install.sh
    	```

    -   Powershell

        ```powershell
        .\install.ps1
        ```

    -   What it does

        -   Copy `~/.atom/` to cloned repo without overwriting
        -   Move `~/.atom/` to `~/.atom.backup`
        -   Symlink `~/.atom/` to cloned repo

2.  Install packages from `packages.txt` using `apm`

    ```sh
    apm install --packages-file packages.txt
    ```

3.  After installing or updating packages, output user-installed packages to `packages.txt`

    ```sh
    apm list --installed --bare > packages.txt
    ```
