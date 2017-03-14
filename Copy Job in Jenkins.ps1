$newJob = Read-Host 'New job name'
$jobToCopy = Read-Host 'Job to copy'
$jenkinsCopyUrl = 'http://{jenkins}/createItem?name=' + $newJob + '&mode=copy&from=' + $jobToCopy
$jenkinsUsername = ''
$jenkinsPassword = ''

# Needed for authentification matching basic authentication
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $jenkinsUsername,$jenkinsPassword)))

try {
    Invoke-RestMethod $jenkinsCopyUrl -Method Post -Headers @{ Authorization = ("Basic {0}" -f $base64AuthInfo)}
} catch {
    if ($Error[0].ErrorDetails.Message -like '*Authentication required*') {
        Write-Host Probably worked, check the web UI
    } else {
        Write-Host Probably didn''t work, check the web UI
    }
}