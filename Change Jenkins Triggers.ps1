<#  Name: Change Triggers
    Changes the config triggers TFS push and not poll SCM
    Written by Kiriakos Triantafilou 1/19/2017
#>

# Get jobs that need to change triggers
$jobsCompleted = Import-Csv -Path 'L:\MyDocs\Output Files\jobsCompleted.txt' | Get-Unique -AsString

for ($i = 0; $i -lt $jobsCompleted.Count; $i++) {
    
    $jobToRetrigger = $jobsCompleted.jobs[$i]

    $path = 'L:\MyDocs\Jenkins\jobs\' + $jobToRetrigger + '\config.xml'

    try {
        Get-Item -Path $path | % {
            (Get-Content $_.FullName).Replace('<hudson.triggers.SCMTrigger>','<hudson.plugins.tfs.TeamPushTrigger plugin="tfs@5.2.1">').Replace('H/15 * * * *','').Replace('<ignorePostCommitHooks>false</ignorePostCommitHooks>','').Replace('</hudson.triggers.SCMTrigger>','</hudson.plugins.tfs.TeamPushTrigger>') | Set-Content $_.FullName
        }
       
    } catch {
        Write-Host Unable to change trigger for: $jobToRetrigger
    }
}