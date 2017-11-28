<#
Curl:
curl -X GET --header 'Accept: application/json' '{nexus}/nexus/service/siesta/rest/beta/search?maven.groupId={group}&maven.artifactId={artifact}&maven.baseVersion={version}&maven.extension={extension}'

Request URL:
{nexus}/nexus/service/siesta/rest/beta/search?maven.groupId={group}&maven.artifactId={artifact}&maven.baseVersion={version}&maven.extension={extension}

#>
# Variables
$nexusBase = ''
$searchBase = '/service/siesta/rest/beta/search?' # Incase they change the base like they did from Nexus 2 to 3
$groupId = ''
$artifactId = ''
$baseVersion = ''
$extension = ''
$classifer = ''
$downloadLocation = ''
#########################################################

# Form search URL
$restURI = $nexusBase + $searchBase +
        'maven.groupId=' + $groupId +
        '&maven.artifactId=' + $artifactId +
        '&maven.baseVersion=' + $baseVersion +
        '&maven.extension=' + $extension


# The artifact may not have classifer such as "-archive"
if (-not ([string]::IsNullOrEmpty($classifer))) {
    $restURI += '&maven.classifier=' + $classifer
}


# In case the search returns nothing
try {
    $nexusResponse = Invoke-WebRequest $restURI -Method GET
} catch {
    Write-Host URL does not exists: $restURI
}


# Get content and make json text into a PS object
$nexusData = $nexusResponse.Content | ConvertFrom-Json

# Traverse to the query results
$nexusSearchResults = $nexusData.items.assets


# Check if the search returns empty
if ([string]::IsNullOrEmpty($nexusSearchResults)) {
   Write-Host 'No search results found at' $restURI
}


# Find the correct URL from the returned search results
foreach ($nexusSearchResult in $nexusSearchResults) {

    # Search for the ending as the extention instead of md5 or sha1
    $extTest = '*.' + $extension

    if ($nexusSearchResult.path -like $extTest) {
        # Download to download location
        Invoke-WebRequest $nexusSearchResult.downloadUrl -OutFile $downloadLocation
    }
}
