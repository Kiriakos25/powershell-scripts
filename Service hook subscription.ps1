<#  Service Hook Subscription Test
    This is an attempt to create a service hook to jenkins build for a trigger on checkin
    Written by Kiriakos Triantafilou
#>
$uri = 'https://{tfs}/{Collection}/_apis/hooks/subscriptions?api-version=2.0'

# For body input
$projectPath = ""
$projectId = ""
$jenkinsServerBaseUrl = ""
$username = ""
$password = ""
$buildName = ""
$params = ""
$parameters = ""

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
        "serverBaseUrl": "$jenkinsServerBaseUrl",
        "username": "$username",
        "password": "$password",
        "buildName": "$buildName",
        "buildParameterized": "$params",
        "buildParams": "$parameters"
    }
}
"@

$test = Invoke-RestMethod -Uri $uri -Method POST -ContentType 'application/json' -Body $body -UseDefaultCredential