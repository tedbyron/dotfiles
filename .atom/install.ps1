# If process is not elevated, start new elevated process and exit current process
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
	Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; 
	Exit;
}

# Create symlink
New-Item -ItemType SymbolicLink -Path $HOME\.atom -Value $PSScriptRoot -Force;

# Prompt to exit
Write-Host "Press any key to exit...";
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown");
Exit;