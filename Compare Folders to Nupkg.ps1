$path = ''
$packageNames = ls $path | ? { $_.Extension -eq '.nupkg' } | select name
$packageNames = $packageNames.name -replace ".1.0.0.nupkg"

$folderNames = ls $path | ? { $_.PSIsContainer } | select name
[System.Collections.ArrayList]$folderNames = $folderNames.name

$namesToCompare = [System.Collections.ArrayList]@()

foreach ($package in $packageNames) {
    $namesToCompare.Add($package.Replace('-', ' ')) > null
}

foreach ($name in $namesToCompare) {
    $folderNames.Remove($name)
}