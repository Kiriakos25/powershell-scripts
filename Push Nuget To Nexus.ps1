$path = ''
$packageNames = ls $path | ? { $_.Extension -eq '.nupkg' } | select name
$packageNames = $packageNames.name

$src = ''
$apiKey = ''

foreach ($package in $packageNames) {
    $packagePath = $path + '\' + $package

    #nuget push $packagePath $apiKey -Source $src
}