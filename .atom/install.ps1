# If process is not elevated, start new elevated process and exit current process
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
	Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; 
	Exit;
}

# Create symlinks
New-Item -ItemType HardLink -Path $Home\.atom\config.cson -Value $PSScriptRoot\config.cson -Force;
New-Item -ItemType HardLink -Path $Home\.atom\init.coffee -Value $PSScriptRoot\init.coffee -Force;
New-Item -ItemType HardLink -Path $Home\.atom\keymap.cson -Value $PSScriptRoot\keymap.cson -Force;
New-Item -ItemType HardLink -Path $Home\.atom\package-list.txt -Value $PSScriptRoot\package-list.txt -Force;
New-Item -ItemType HardLink -Path $Home\.atom\snippets.cson -Value $PSScriptRoot\snippets.cson -Force;
New-Item -ItemType HardLink -Path $Home\.atom\styles.less -Value $PSScriptRoot\styles.less -Force;

# Prompt to exit
Write-Host "Press any key to exit...";
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown");
Exit;