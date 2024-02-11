function Invoke-Starship-PreCommand {
  $loc = $executionContext.SessionState.Path.CurrentLocation
  $prompt = "$([char]27)]9;12$([char]7)"
  if ($loc.Provider.Name -eq "FileSystem") {
    $prompt += "$([char]27)]9;9;`"$($loc.ProviderPath)`"$([char]27)\"
  }
  $host.ui.Write($prompt)
}

$ENV:STARSHIP_CONFIG = "$HOME\git\dotfiles\.config\starship.toml"
Invoke-Expression (&starship init powershell)

Set-Alias -Name iexs -Value iex.bat
