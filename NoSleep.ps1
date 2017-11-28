# Keep screen alive. Good for monitoring without moving the mouse or changing sleep settings. Especially if you don't have permission to change your sleep settings...
notepad.exe
$myshell = New-Object -com “Wscript.Shell”
while ($true) {
$myshell.sendkeys(“.”)
start-sleep -Seconds 30
}
