##### Fill out this informantion before running #####
$instance = ''
$collection = ''
$jenkinsServerUrl = ''
#####################################################

# Get existing service hooks
$subscriptionsUri = 'https://' + $instance + '/' + $collection + '/_apis/hooks/subscriptions/?api-version=1.0'
$subscriptionList = Invoke-RestMethod -Uri $subscriptionsUri -Method Get -UseDefaultCredential
$buildsAlreadyDone = $subscriptionList.value.consumerinputs.buildname

# Output them
$buildsAlreadyDone | Out-File -FilePath 'L:\MyDocs\Output Files\jobsCompleted.txt' -Append -NoClobber