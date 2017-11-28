$jenkinsUsername = ''
$jenkinsPassword = ''
$jenkinsConsoleUri = '{jenkins}/scriptText'

# Since it's urlencoded I used %2B instead of + because the + signs were being encoded to spaces (%20)
$script = @'
script=
import hudson.plugins.tfs.TeamFoundationServerScm

jenkins = Hudson.instance

println "job, path, parameter1, parameter2, parameter3"
for (item in jenkins.items)
{
	try {
		scm = item.getScm()
		if (scm instanceof TeamFoundationServerScm) {
          	try {
              	build = item.getLastBuild()
				def params = build.getActions(hudson.model.ParametersAction)
          		println item.getFullDisplayName() %2B ", " %2B scm.getProjectPath() %2B ", " %2B params.parameters
            } catch (Exception ex) {
              println item.getFullDisplayName() %2B ", " %2B scm.getProjectPath()
            }
		}
	} catch(Exception ex) {
		println item.getFullDisplayName()
	}
}
'@

# Needed for authentification matching basic authentication
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $jenkinsUsername,$jenkinsPassword)))

$test = Invoke-RestMethod $jenkinsConsoleUri -Method Post  -Body $script -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
