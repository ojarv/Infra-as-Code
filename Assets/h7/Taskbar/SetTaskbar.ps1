### Original .BAT script: https://www.elevenforum.com/t/backup-and-restore-pinned-items-on-taskbar-in-windows-11.3630/

# Remove existing shortcuts
Remove-Item -Path "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\*" -Force -Recurse

# Copy new shortcuts
Copy-Item -Path "C:\tmp\Taskbar\Shorcuts\*" -Destination "$env:APPDATA\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\" -Force

# Import registry settings
reg import "C:\tmp\Taskbar\Taskbar.reg"

# Restart explorer
Stop-Process -Name explorer -Force
Start-Process explorer

# Remove checkfile
Remove-Item -Path C:\tmp\Taskbar\notconfigured