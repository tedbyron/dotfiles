# set some env vars
Invoke-Expression (&starship init powershell)

################################################################################
# Colors
################################################################################

Set-PSReadlineOption -Color @{
  "Command" = [ConsoleColor]::Green
  "Parameter" = [ConsoleColor]::Gray
  "Operator" = [ConsoleColor]::Magenta
  "Variable" = [ConsoleColor]::White
  "String" = [ConsoleColor]::Yellow
  "Number" = [ConsoleColor]::Blue
  "Type" = [ConsoleColor]::Cyan
  "Comment" = [ConsoleColor]::DarkCyan
}

################################################################################
# Choco
################################################################################

$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

################################################################################
# Aliases
################################################################################

Set-Alias vi nvim
Set-Alias vim nvim
Set-Alias gvim nvim-qt
