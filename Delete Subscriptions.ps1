$instance = '{tfs}/tfs'
$collection = '{collection}'
$subscriptionIds = Import-Csv -Path 'L:\MyDocs\Output Files\SubscriptionIds.txt' | Get-Unique -AsString

for ($i = 0; $i -lt $subscriptionIds.Count; $i++) {
    $idToDelete = $subscriptionIds.ids[$i]
    $uri = 'https://' + $instance + '/' + $collection + '/_apis/hooks/subscriptions/' + $idToDelete + '?api-version=1.0'
    try {
        Invoke-RestMethod -Uri $uri -Method DELETE -UseDefaultCredential
    } catch {
        Write-Host Unable to delete ID: $idToDelete
    }
}
