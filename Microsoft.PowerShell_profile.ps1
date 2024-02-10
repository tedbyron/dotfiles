$ENV:STARSHIP_CONFIG = "$HOME\git\dotfiles\.config\starship.toml"
Invoke-Expression (&starship init powershell)
Set-Alias -Name iexs -Value iex.bat
