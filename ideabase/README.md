# IdeaBase Dev Environment Installation

## Prerequisites

-   Hopefully you're using a Mac...
-   Download the raw install script from GitHub or using cURL
    ```sh
    curl -O https://raw.githubusercontent.com/tedbyron/dotfiles/master/ideabase/install.sh
    ```

## Installation

-   Add execute permission to the install script
    ```sh
    chmod +x install.sh
    ```
-   Run the script
    ```sh
    ./install.sh
    ```

## Post-Installation

-   The script will add a global Composer alias to your bash profile. If you're using a shell other than bash, then the alias must be added manually to your shell profile
    ```sh
    alias composer="php /usr/local/bin/composer.phar"
    ```

## What the script does

1.  Checks if there is an internet connection
2.  Installs two package managers which have packages for the applications we use
    -   Homebrew
        -   composer
        -   git
        -   node (Node.js)
            -   npm
                -   grunt-cli
                -   sass
    -   Homebrew-Cask
        -   atom
        -   firefox
        -   github (GitHub Desktop)
        -   google-chrome
        -   mamp (MAMP Pro)
        -   tower
        -   slack
3. Writes a global Composer alias to `$HOME/.bash_profile` or `$HOME/.profile`
4. Prompts for optional package installations
    -   Homebrew
        -   gpg-tools
        -   vim
    -   Homebrew-Cask
        -   karabiner
        -   spectacle
