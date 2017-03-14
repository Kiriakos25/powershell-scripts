<#  Name: Create tfs push
    Sets a subscription for a service hook in tfs to the jenkins build
    Written by Kiriakos Triantafilou 1/17/2017
#>

##### Fill out this informantion before running #####
$instance = '{tfs}'
$collection = ''
$jenkinsServerUrl = ''
$jenkinsUsername = ''
$jenkinsPassword = ''
$jenkinsOutputPath = 'L:\MyDocs\Output Files\Jenkins Job Info(PreProd).csv'
#####################################################

## JENKINS API ##
# Get info from Jenkins
$jenkinsConsoleUrl = $jenkinsServerUrl + 'scriptText'

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
          		println item.getFullDisplayName() + ", " + scm.getProjectPath() + ", " + params.parameters
            } catch (Exception ex) {
              println item.getFullDisplayName() + ", " + scm.getProjectPath()
            }
		} 
	} catch(Exception ex) {
		println item.getFullDisplayName()
	}
}
'@

# Since it's urlencoded I used %2B instead of + because the + signs were being encoded to spaces (%20)
$script = $script.Replace('+', '%2B')

# Needed for authentification matching basic authentication
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $jenkinsUsername,$jenkinsPassword)))

# Get info from Jenkins
$jenkinsOutput = Invoke-RestMethod $jenkinsConsoleUrl -Method Post -Body $script -Headers @{ Authorization = ("Basic {0}" -f $base64AuthInfo)}

## TFS API ##
# Get existing service hooks
$subscriptionsUri = 'https://' + $instance + '/' + $collection + '/_apis/hooks/subscriptions/?api-version=1.0'
$subscriptionList = Invoke-RestMethod -Uri $subscriptionsUri -Method Get -UseDefaultCredential
$buildsAlreadyDone = $subscriptionList.value.consumerinputs.buildname

# Get a list projects and IDs
$teamprojectsuri = 'https://' + $instance + '/' + $collection + '/_apis/projects?&stateFilter=WellFormed&$top=10000&skip=0'
$output = Invoke-RestMethod -Uri $teamprojectsuri -Method Get -UseDefaultCredential
$projectList = $output.value | select Name, id

$subscriptionIds = @('ids')
$jobsCompleted = @('jobs')

# Get jobs, paths, and parameters
$jenkins = $jenkinsOutput | ConvertFrom-Csv

for ($i=0; $i -lt $jenkins.Count; $i++) {
    if ($jenkins[$i].path -and ($buildsAlreadyDone -notcontains $jenkins[$i].job)) {
        
        # Get project name from path
        $projectName = $jenkins[$i].path.Split('/')[1]

        # Subscription body input
        $projectPath = $jenkins[$i].path
        $projectId = $projectList | where {$_.name -eq $projectName} | % id
        $buildName = $jenkins[$i].job
        $parameter1 = ''
        $parameter2 = ''
        $parameter3 = ''

        # Parameters to insert
        if ($jenkins[$i].parameter1 -eq '[]' -or [string]::IsNullOrEmpty($jenkins[$i].parameter1)) {
            $params = 'false'
        } else {
            $params = 'true'
            $parameter1 = $jenkins[$i].parameter1.Split(" ")[1].Split("=")[0] + ':'

            if ($jenkins[$i].parameter2 -ne '[]' -and ![string]::IsNullOrEmpty($jenkins[$i].parameter2)) {
                $parameter2 = $jenkins[$i].parameter2.Split(" ")[1].Split("=")[0] + ':'

                if ($jenkins[$i].parameter3 -ne '[]' -and ![string]::IsNullOrEmpty($jenkins[$i].parameter3)) {
                    $parameter3 = $jenkins[$i].parameter3.Split(" ")[1].Split("=")[0] + ':'
                }
            }
        }

        $parameter2 = If ([string]::IsNullOrEmpty($parameter2)) {$parameter2} Else {'
' + $parameter2}
        
        $parameter3 = If ([string]::IsNullOrEmpty($parameter3)) {$parameter3} Else {'
' + $parameter3}

        $parameters = $parameter1 + $parameter2 + $parameter3
        
        # Check if there are any build parameters
        if ($parameter1 -or $parameter2 -or $parameter3) {
            $buildParams = ',
                "buildParams": "' + $parameters + '"'
        } else {
            $buildParams = ''
        }

        # Body created and populated with input
        $body = @"
        {
            "publisherId": "tfs",
            "eventType": "tfvc.checkin",
            "resourceVersion": null,
            "consumerId": "jenkins",
            "consumerActionId": "triggerGenericBuild",
            "publisherInputs": {
                "path": "$projectPath",
                "projectId": "$projectId"
            },
            "consumerInputs": {
                "serverBaseUrl": "$jenkinsServerUrl",
                "username": "$jenkinsUsername",
                "password": "$jenkinsPassword",
                "buildName": "$buildName",
                "buildParameterized": "$params"$buildParams
            }
        }
"@
        $uri = 'https://' + $instance + '/' + $collection + '/_apis/hooks/subscriptions?api-version=2.0'
        # Create subscription
        try {
            $subscription = Invoke-RestMethod -Uri $uri -Method POST -ContentType 'application/json' -Body $body -UseDefaultCredential
            $subscriptionIds += $subscription.id
            $jobsCompleted += $buildName
        } catch {
            Write-Host Can not create sub for $projectName, $projectId
        }
    }
}

$subscriptionIds | Out-File -FilePath 'L:\MyDocs\Output Files\SubscriptionIds.txt'
$jobsCompleted | Out-File -FilePath 'L:\MyDocs\Output Files\jobsCompleted.txt'