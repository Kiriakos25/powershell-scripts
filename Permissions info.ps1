<#  Name: Get project groups and permissions
    Gets the permissions of each group in each project
    Written by Kiriakos Triantafilou 2/13/2017
#>

$Error.Clear()
$instance = ''
$collection = ''
$collectionUri = 'https://' + $instance + '/' + $collection
$projectUri = 'https://' + $instance + '/' + $collection + '/_apis/projects?api-version=1.0&$top=1000'
$projectsOutput = Invoke-RestMethod -Uri $projectUri -Method Get -UseDefaultCredential
$projectList = $projectsOutput.value | select Name, id
$output = @('Project, Group/Team, Permission')

foreach ($project in $projectList) {
    $projectToken = 'vstfs:///Classification/TeamProject/' + $project.id
    $tempOutput = tfssecurity /acl Project $projectToken /collection:$collectionUri

    for ($i = 0; $i -lt $tempOutput.Length; $i++) {
        if ($tempOutput[$i] -match '\[?\]') {
            $output += $project.name + ', ' + $tempOutput[$i].Split('\')[1] + ', ' + $tempOutput[$i].Split(' ')[3]
        }
    }
}

$output | ConvertFrom-Csv | Export-Csv 'L:\MyDocs\Output Files\TFS Permissions.csv' -NoTypeInformation

# Cleanup
if (!$Error){
    Remove-Variable instance, collection, collectionUri, projectUri, projectsOutput, output, project, projectList, projectToken, tempOutput, i
}