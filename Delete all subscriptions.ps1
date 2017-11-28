$uri = '{tfs}/tfs/{collection}/_apis/hooks/subscriptions/?api-version=1.0'
$output = Invoke-RestMethod -Uri $uri -Method GET -UseDefaultCredential
$ids = $output.value.id

foreach ($id in $ids) {
    $deleteUri = '{tfs}/tfs/{collection}/_apis/hooks/subscriptions/' + $id + '?api-version=1.0'
    try {
        # Uncomment below to delete
        Invoke-RestMethod -Uri $deleteUri -Method DELETE -UseDefaultCredential
    } catch {
        Write-Host Unable to delete ID: $idToDelete
    }
}
