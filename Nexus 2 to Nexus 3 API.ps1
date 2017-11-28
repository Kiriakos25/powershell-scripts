### This is a prototyping of replacing a single Nexus 2 API call with all this.... Thanks Sonatype ###
# It is assumed that the query URL is known and the download will happen in the current directory
$URL = '{nexus}/nexus/service/local/artifact/maven/redirect?r={repo}&g={group}&a={artifact}&v={version}&e={extension}&c={classifier}'
################################################################
# Begin the conversion...

# Nexus 3 REST API Path
$searchBase = '/service/siesta/rest/beta/search?'

# Nexus 2 REST API Path
$nexus2APIPath = '/service/local/artifact/maven/redirect'

$nexus2APIPathCompare = '*' + $nexus2APIPath + '*'

if($URL -like $nexus2APIPathCompare) {

    $splitURL = $URL.Split('?')

    $nexusBase = $splitURL[0].Remove($splitURL[0].IndexOf($nexus2APIPath))

    # Convert URL String to NameValueCollection
    $queryParams = $splitURL[1]
    Add-Type -AssemblyName System.Web
    $queryNVC = [System.Web.HttpUtility]::ParseQueryString($queryParams)

    # Extract Required Params
    $repository = $queryNVC['r']
    $groupId = $queryNVC['g']
    $artifactId = $queryNVC['a']
    $version = $queryNVC['v']

    # Extract Optional Params
    $classifier = $queryNVC['c']
    $extension = $queryNVC['e']

    # Form search URL
    $restURI = $nexusBase + $searchBase +
            'repository=' + $repository +
            '&maven.groupId=' + $groupId +
            '&maven.artifactId=' + $artifactId +
            '&maven.baseVersion=' + $version

    # The artifact may not have an extension
    if (-not ([string]::IsNullOrEmpty($extension))) {
        $restURI += '&maven.extension=' + $extension
    }

    # The artifact may not have a classifer
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

    if ([string]::IsNullOrEmpty($extension)) { # If an ext is provided, download that one

        # Find the correct URL from the returned search results
        foreach ($nexusSearchResult in $nexusSearchResults) {

            # Search for the ending as the extention instead of md5 or sha1
            $extTest = '*.' + $extension

            if ($nexusSearchResult.path -like $extTest) {
                # Download to download location
                Invoke-WebRequest $nexusSearchResult.downloadUrl -OutFile $nexusSearchResult.downloadUrl.Split('/')[-1]
            }
        }
    } else { # If no ext, download the first one that is not a hash
        foreach ($nexusSearchResult in $nexusSearchResults) {
            if ($nexusSearchResult.path -notlike '*.md5' -or
                $nexusSearchResult.path -notlike '*.sha1' -or
                $nexusSearchResult.path -notlike '*.sha256' -or
                $nexusSearchResult.path -notlike '*.sha512') {
                    Invoke-WebRequest $nexusSearchResult.downloadUrl -OutFile $nexusSearchResult.downloadUrl.Split('/')[-1]
                    break
            }
        }
    }

} else {

    Write-Host 'Not a REST API query.'
}

<# Works Cited:
{nexus 2}/nexus/nexus-restlet1x-plugin/default/docs/path__artifact_maven_redirect.html
Local Nexus 3 Swagger UI
http://www.sonatype.org/nexus/2017/09/25/nexus-repository-new-beta-rest-api-for-content/
#>
