<#  Name: Replaces jenkins job config file
    Replaces current jenkins job config file with the backup file
    Written by Kiriakos Triantafilou 1/20/2017
#>

##### Fill out this informantion before running #####
$jobSource = 'L:\MyDocs\Jenkins\jobs'
$backupPath = 'L:\MyDocs\Backup'
#####################################################

# Get a list of all of the job locations
$jobs = Get-ChildItem -Path $jobSource | ?{ $_.PSIsContainer } | Select-Object FullName

foreach($jobPath in $jobs) {
    
    $jobName = $jobPath.FullName.Split('\')[-1]

    try {
        # Copy the config file
        $filePath = $backupPath + '\' + $jobName + '\config.xml'
        $destPath = $jobPath.FullName
        Copy-Item -Path $filePath -Destination $destPath -Force
    } catch {
        Write-Error Could not copy config for: $jobName
    }
}