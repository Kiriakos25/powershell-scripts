# Backup Jenkins config
$jobSource = 'E:\Apps\Jenkins\jobs'
$copyDest = 'E:\Apps\Jenkins Job Backup'

# Create the backup folder
New-Item -ItemType Directory -Force -Path $copyDest

# Get a list of all of the job locations
$jobs = Get-ChildItem -Path $jobSource | ?{ $_.PSIsContainer } | Select-Object FullName

foreach($jobPath in $jobs) {
    
    $jobName = $jobPath.FullName.Split('\')[-1]

    $jobFolder = $copyDest + '\' + $jobName

    # Create job folder
    New-Item -ItemType Directory -Force -Path $jobFolder

    try {
        # Copy the config file
        $filePath = $jobPath.FullName + '\config.xml'
        $destPath = $copyDest + '\' + $jobName
        Copy-Item -Path $filePath -Destination $destPath
    } catch {
        Write-Error Could not copy config for: $jobName
    }
}