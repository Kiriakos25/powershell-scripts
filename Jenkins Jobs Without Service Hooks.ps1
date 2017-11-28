$TFSCollection = '{tfs}/tfs/{collection}'
$jenkinsBaseURL = '{jenkins}'
$jenkinsUsername = ''
$jenkinsAPI = '' # This will change per env of Jenkins
#######################################################################################################

# Get info from TFS
$TFSuri = $TFSCollection + '/_apis/hooks/subscriptions/?api-version=1.0'
$output = Invoke-RestMethod -Uri $TFSuri -Method GET -UseDefaultCredential
$jobsWithTriggers = $output.value.actionDescription | foreach { $_.Split(' ')[-1] }


# Get info from Jenkins
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
$jenkinsJobs = $jenkinsJobs -split "`n" | ? {$_} | foreach { $_.Split('')[0] }


# Compare
$jobsWithoutTrigger = $jenkinsJobs | ?{$jobsWithTriggers -notcontains $_}
$jobsWithoutTrigger | ? {$_ -notlike 'template*'} # Ignore template jobs
