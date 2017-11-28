# This script will check for a value inside of all the config.xml files and list the jobs that have it
# Usage: Enter the search value, Jenkins base URI, Jenkins username, and Jenkins API token

$searchValue = '' # Try searching for something like the name of the Jenkins job
$jenkinsBaseURL = '{jenkins}'
$jenkinsUsername = ''
$jenkinsAPI = '' # This will change per env of Jenkins
#######################################################################################################

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $jenkinsUsername,$jenkinsAPI)))
$jenkinsConsoleUrl = $jenkinsBaseURL + '/scriptText'
$script = @'
script=
import hudson.plugins.tfs.TeamFoundationServerScm
jenkins = Hudson.instance

for (item in jenkins.items)
{
	try {
		scm = item.getScm()
		if (scm instanceof TeamFoundationServerScm) {
			println item.getFullDisplayName()
		}
	} catch(Exception ex) {
		println item.getFullDisplayName()
	}
}
'@

$jenkinsJobs = Invoke-RestMethod $jenkinsConsoleUrl -Method Post -Body $script -Headers @{ Authorization = ("Basic {0}" -f $base64AuthInfo)}

$realSearchValue = '*' + $searchValue + '*'

# Makes Jenkins jobs string output iterable
$jenkinsJobs = $jenkinsJobs -split "`n"

# Remove blank entires
$jenkinsJobs = $jenkinsJobs | ? {$_}

$numberOfJobs = $jenkinsJobs.Count

$number = 1


foreach ($jenkinsJob in $jenkinsJobs) {

    $number++
    $percent = [math]::Round(($number / $numberOfJobs) * 100)
    Write-Progress -Activity "Searching Jenkins..." -Status "$percent% Complete:" -PercentComplete $percent

    if ($jenkinsJob.Length -gt 0) {

        $jenkinsJob = $jenkinsJob.Replace("`r", "")
        $configUri = $jenkinsBaseURL + '/job/' + $jenkinsJob + '/config.xml'

        $ProgressPreference = 'silentlyContinue'
        $jenkinsConfig = Invoke-WebRequest $configUri -Method Get -Headers @{ Authorization = ("Basic {0}" -f $base64AuthInfo)} | select content
        $progressPreference = 'Continue'
        if ($jenkinsConfig -like $realSearchValue) {
            Write-Host $jenkinsJob
        }
    }
}
