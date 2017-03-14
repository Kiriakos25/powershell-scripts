<#  Name: Create VSS into NuGet Packages
    Creates nuget packages for the VSS Repo
    Written by Kiriakos Triantafilou 2/17/2017
#>

$path = ''

$templatePath = 'L:\MyDocs\Reference Files\Template.nuspec'
$folderNames = ls $path | ? { $_.PSIsContainer } | select name
$folderNames = $folderNames.name
$output = @()

foreach ($folderName in $folderNames) {
    
    $destinationPath = $path + '\' + $folderName + '.nuspec'

    Copy-Item -Path $templatePath -Destination $destinationPath
    (Get-Content $destinationPath).Replace('Name', $folderName) | Set-Content $destinationPath

    # Check to see if folder name has a space so we can create a proper ID
    if ($folderName -like '* *') {
        $wrongID = '<id>' + $folderName + '</id>'
        $newID = '<id>' + $folderName.Replace(' ', '-') + '</id>'
        (Get-Content $destinationPath).Replace($wrongID, $newID) | Set-Content $destinationPath
    }

    # Create NuGet Package
    #$output += nuget pack $destinationPath -OutputDirectory $path

}

$logPath = $path + '\' + 'log.txt'
$output | Out-File $logPath