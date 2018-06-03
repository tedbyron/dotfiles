# If process is not elevated, start new elevated process and exit current process
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
	Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; 
	Exit;
}

# Robocopy files from current .atom\ to cloned repo; include empty dirs but don't replace repo files
ROBOCOPY $HOME\.atom $PSScriptRoot *.* /E /XC /XN /XO;

# Move .atom\ to .atom.backup\
Move-Item -Path $HOME\.atom -Destination $HOME\.atom.backup -Force;

# Create symlink from .atom\ to dotfiles\.atom
New-Item -ItemType SymbolicLink -Path $HOME\.atom -Value $PSScriptRoot;

# Prompt to exit
Write-Host "`n`nYour original .atom\ folder has been moved to .atom.backup\`n" -ForegroundColor Magenta;
Write-Host "Success! Press any key to exit..." -ForegroundColor Green;
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown");
Exit;