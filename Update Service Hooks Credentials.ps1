<#  Name: Update TFS Subscriptions
    Updates TFS subcription to use the service account
    Written by Kiriakos Triantafilou 1/20/2017
#>

##### Fill out this informantion before running #####
$instance = ''
$collection = ''
$jenkinsServerUrl = ''
$jenkinsUsername = ''
$jenkinsPassword = ''
#####################################################

# Get a list projects and IDs
$subscriptionsUri = 'https://' + $instance + '/' + $collection + '/_apis/hooks/subscriptions/?api-version=1.0'
$subscriptionList = Invoke-RestMethod -Uri $subscriptionsUri -Method Get -UseDefaultCredential
$projectList = $subscriptionList.value | ? {$_.consumerInputs.username -ne 'svc_jenkins'}

$subscriptionIdsUpdated = @('ids')
$bodys = @('bodys') # TEST

foreach ($project in $projectList) {
    
    # Subscription input
    $subscriptionId = $project.id
    $projectUrl = $project.url
    $publisherId = $project.publisherId
    $eventType = $project.eventType
    $consumerId = $project.consumerId
    $consumerActionId = $project.consumerActionId
    $projectPath = $project.publisherInputs.path # Fix this one
    $projectId = $project.publisherInputs.projectId
    $serverBaseUrl = $project.consumerInputs.serverBaseUrl
    $buildName = $project.consumerInputs.buildName
    $buildParameterized = $project.consumerInputs.buildParameterized

    # Check if there are any build parameters
    if ($project.consumerInputs.buildParameterized -eq 'True') {
        $buildParams = ',
            "buildParams": "' + $project.consumerInputs.buildParams + '"'
    } else {
        $buildParams = ''
    }

    # Check if there is a project path
    if (![string]::IsNullOrEmpty($projectPath)) {
        $path = '"path": "' + $projectPath + '",
            '
    } else {
        $path = ''
    }
    
    # Body created and populated with input
    $body = @"
    {
        "publisherId": "$publisherId",
        "eventType": "$eventType",
        "resourceVersion": null,
        "consumerId": "$consumerId",
        "consumerActionId": "$consumerActionId",
        "publisherInputs": {
            $path"projectId": "$projectId"
        },
        "consumerInputs": {
            "serverBaseUrl": "$serverBaseUrl",
            "username": "$jenkinsUsername",
            "password": "$jenkinsPassword",
            "buildName": "$buildName",
            "buildParameterized": "$buildParameterized"$buildParams
        }
    }
"@
    $uri = $projectUrl + '?api-version=2.0'


    $bodys += $body # TEST

    # Update subscription
    <#
    try {
        $subscription = Invoke-RestMethod -Uri $uri -Method PUT -ContentType 'application/json' -Body $body -UseDefaultCredential
        $subscriptionIdsUpdated += $subscription.id
    } catch {
        Write-Host Can not create sub for $projectId
    }
    #>
}

$subscriptionIdsUpdated | Out-File -FilePath 'L:\MyDocs\Output Files\SubscriptionIds.txt'

$bodys | Out-File -FilePath 'L:\MyDocs\Output Files\Body output test.txt' # TEST