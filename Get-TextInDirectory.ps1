function Get-TextInDirectory {
    param([string]$directorToSearch, [string]$textToSearch, [string]$outputLocation)

    if (!$directorToSearch) { Throw 'No director entered' }
    if (!$textToSearch) { Throw 'No text to search entered' }

    $files = Get-ChildItem $directorToSearch -recurse -EA SilentlyContinue | where {! $_.PSIsContainer}
    $output = @()
    if ($outputLocation) {
        foreach ($file in $files) {
            $location = $file.FullName
            $output += Select-String $location -Pattern $textToSearch
        }
    } else {
        foreach ($file in $files) {
            $location = $file.FullName
            Select-String $location -Pattern $textToSearch
        }
    }
    if ($outputLocation) {
        $output | Out-File -FilePath $outputLocation
        Remove-Variable outputLocation
    }
    Remove-Variable directorToSearch, textToSearch
}
