<#  Name: Update Jenkins Jobs Paths
    Changes the path from E:\Jenkins to E:\Apps\Jenkins
    Written by Kiriakos Triantafilou 3/28/2017
#>

$jenkinsJobPath = 'E:\Apps\Jenkins\jobs'
$oldText = 'E:/Jenkins'
$newText = 'E:/Apps/Jenkins'

# Get all job names
$jobs = Get-ChildItem $jenkinsJobPath | where {$_.PSIsContainer}

foreach ($job in $jobs.Name) {

    $path = $jenkinsJobPath + '\' + $job + '\config.xml'

    if (Test-Path $path) {
        try {
            Get-Item -Path $path | % {
                (Get-Content $_.FullName).Replace($oldText,$newText) | Set-Content $_.FullName
            }
        } catch {
            Write-Host Unable to change URL for: $job
        }
    }
}