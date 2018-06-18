# OS X Dev Environment Installation

## Prerequisites

-   Hopefully you're using a Mac...
-   Download the raw install script from GitHub or with cURL
    ```sh
    curl -LOk https://raw.githubusercontent.com/tedbyron/dotfiles/master/ideabase/install.sh
    ```
-   Add execute permission to the install script
    ```sh
    chmod +x install.sh
    ```

## Installation

-   Run the script
    ```sh
    ./install.sh
    ```

## What the script does

1.  Checks if there is an internet connection
2.  Installs three package managers: Homebrew, Homebrew-Cask, and npm, and installs the following packages
    -   Homebrew
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
3. Prompts for optional package installations
    -   Homebrew
        -   emacs
        -   nano
        -   neovim
        -   vim
    -   Homebrew-Cask
        -   gpg-suite (GPG Tools)
        -   karabiner-elements
        -   spectacle
