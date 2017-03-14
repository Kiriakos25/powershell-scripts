<#  Name: Compare Jenkins to TFS
    Finds what TFS projects exist and compares them to the jobs that exist in Jenkins
    Disclaimer: This works pretty well but may have the wrong owner. (The owner is based on the TFS owner...)
    Written by Kiriakos Triantafilou 2/13/2017
#>

########################## MODIFY THIS VARIABLE ##########################
$outputPath = 'L:\MyDocs\Output Files'
##########################################################################

function Get-NexusName {
    
    param([string]$jobName)
    $jenkinsServerUrl = ''
    $jenkinsUsername = ''
    $jenkinsPassword = ''
    
    $jobConsoleUrl = $jenkinsServerUrl + 'job/' + $jobName + '/lastStableBuild/consoleText'
    
    # Needed for authentification matching basic authentication
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $jenkinsUsername,$jenkinsPassword)))
    
    try {
        # Get info from Jenkins
        $jenkinsOutput = Invoke-RestMethod $jobConsoleUrl -Method Get -Headers @{ Authorization = ("Basic {0}" -f $base64AuthInfo)}
    } catch {
        return 'Not in Nexus (Check for youself)'
    }
    
    if ($jenkinsOutput -match 'nupkg') {
        
        # Split the output at every space
        $temp = $jenkinsOutput.Split(' ')

        try {
            
            # Get the lines that contain 'nupkg' and \ (path)
            $nameToBeParsed = ((($temp -match 'nupkg') -match '\\') -notmatch 'packages')[0]

            # Remove everything after and including '.nupkg'
            $path = $nameToBeParsed.Substring(0, $nameToBeParsed.IndexOf('.nupkg'))

            # Parse at '\' and get the last one because it's the file
            $nameWithVersion = $path.Split('\\')[-1]

            # Remove version
            $parsedList = $nameWithVersion.Split('.')
            $name = $nameWithVersion.Substring(0, $nameWithVersion.IndexOf($parsedList[-3]))
            $name = $name.Remove($name.Length - 1)
        } catch {
            $name = (($temp -match 'nupkg') -notmatch 'packages')[0]
        }

        Remove-Variable temp
    } elseif ($jenkinsOutput -match 'nexus') {
        
        $temp = $jenkinsOutput.Split(' ')
        
        $url = (($temp -match '{nexus}/nexus/content/repositories') -match '.pom')[0]
    
        if ($url) {
            
            # Remove any carriage returns
            $filePath = $url.Split("`n")[0]

            # Get the last item in the file path
            $pom = $filePath.Split('/')[-1]

            # This is to find where the versioning of the pom file starts
            $split = $pom.Split('-')
            $remove = $false

            # Remove versioning on pom file
            foreach ($line in $split) {
                # Find the first line containing numbers (versioning)
                if ($line -match '^[0-9]') {
                    $remove = $true
                    $indexToRemove = $pom.IndexOf($line) - 1

                    # Exit loop
                    break
                }
            }

            if ($remove) {
                $name = $pom.Remove($indexToRemove)
            } else {
                $name = $pom
            }


        } else {
            $name = 'May exists in Nexus'
        }
    
        Remove-Variable temp
    } else {
        $name = 'Not in Nexus (Check for youself)'
    }
    
    return $name
}

# Variables
$instance = ''
$collection = ''
$jenkinsConsoleUrl = 'https://{jenkins}/scriptText'
$jenkinsUsername = ''
$jenkinsPassword = ''

$script = @'
script=
import hudson.plugins.tfs.TeamFoundationServerScm

jenkins = Hudson.instance

println "job, path"

for (item in jenkins.items)
{
	try {
		scm = item.getScm()
		if (scm instanceof TeamFoundationServerScm) {
			println item.getFullDisplayName() + ", " + scm.getProjectPath()
		} 
	} catch(Exception ex) {
		println item.getFullDisplayName()
	}
}
'@

# Since it's urlencoded I used %2B instead of + because the + signs were being encoded to spaces (%20)
$script = $script.Replace('+', '%2B')

Write-Host Getting info from Jenkins...

# Needed for authentification matching basic authentication
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $jenkinsUsername,$jenkinsPassword)))

# Get info from Jenkins
$jenkinsOutput = Invoke-RestMethod $jenkinsConsoleUrl -Method Post -Body $script -Headers @{ Authorization = ("Basic {0}" -f $base64AuthInfo)}

if ($jenkinsOutput) {
    Write-Host Successfully retrieved info from Jenkins!
} else {
    Write-Host FAILED to get info from Jenkins.
}

Write-Host Getting info from TFS...

# Get a list project names
$teamProjectsUri = 'https://' + $instance + '/' + $collection + '/_apis/projects?&stateFilter=WellFormed&$top=10000&skip=0'
$projectsOutput = Invoke-RestMethod -Uri $teamProjectsUri -Method Get -UseDefaultCredential
$projectList = $projectsOutput.value | select name
[System.Collections.ArrayList]$projects = $projectList.name

# Get a list of root branches
$branchGetUri = 'https://' + $instance + '/' + $collection + '/_apis/tfvc/branches?api-version=2.0'
$branchesOutput = Invoke-RestMethod -Uri $branchGetUri -Method Get -UseDefaultCredential
$branchesPathList = $branchesOutput.value | select path
[System.Collections.ArrayList]$branchesPaths = $branchesPathList.path

if ($projects -and $branchesPaths) {
    Write-Host Successfully retrieved info from TFS!
} else {
    Write-Host FAILED to get info from TFS.
}

Write-Host Comparing TFS and Jenkins as well as retrieving Nexus Info...

$outputCSV = @('Project, TFS Branches and Paths, Owner, Jenkins Job, Nexus Info')

$jenkins = $jenkinsOutput | ConvertFrom-Csv

# Log TFS path output
$tfsPaths = [System.Collections.ArrayList]@()

for ($i = 0; $i -lt $jenkins.Count; $i++) {
    if ($jenkins[$i].path) {
        
        # Get project name from path
        $projectName = $jenkins[$i].path.Split('/')[1]

        # Get owner from name
        try {
            $nameToSearch = '*' + $projectName + '*'
            $relatedBranches = $branchesOutput.value | ? {$_.path -like $nameToSearch}
            $owner = $relatedBranches[0].owner.displayName
            $owner = "{1} {0}" -f ($owner -split ', ')

        } catch {
            $owner = 'Unable to get owner'
        }

        [void]$tfsPaths.Add($jenkins[$i].path)
        $outputCSV += $projectName + ', ' + $jenkins[$i].path + ', ' + $owner + ', ' + $jenkins[$i].job + ', ' + (Get-NexusName -jobName $jenkins[$i].job)
        $projects.Remove($projectName)
    } else {
        $outputCSV += ',,,' + $jenkins[$i].job + ', ' + (Get-NexusName -jobName $jenkins[$i].job)
    }
}

# Clean extra branches from overlap
foreach ($jobPath in $tfsPaths) {
    for ($k = 0; $k -lt $branchesPaths.Count; $k++) {
        $pathWild = '*' + $branchesPaths[$k] + '*'
        $jobPathWild = '*' + $jobPath + '*'
        if ($jobPath -like $pathWild -or $branchesPaths[$k] -like $jobPathWild) {
            
            $projectName = $jobPath.Split('/')[1]

            # Get old owner name that may not be correct
            try {
                $nameToSearch = '*' + $projectName + '*'
                $relatedBranches = $branchesOutput.value | ? {$_.path -like $nameToSearch}
                $oldOwner = $relatedBranches[0].owner.displayName
                $oldOwner = "{1} {0}" -f ($oldOwner -split ', ')

            } catch {
                $oldOwner = 'Unable to get owner'
            }

            # Get new owner that is more correct
            try {
                $relatedBranches = $branchesOutput.value | ? {$_.path -eq $branchesPaths[$k]}
                $newOwner = $relatedBranches[0].owner.displayName
                $newOwner = "{1} {0}" -f ($newOwner -split ', ')
            
            } catch {
                $newOwner = 'Unable to get owner'
            }

            $oldString = $jobPath + ', ' + $oldOwner
            $newString = $jobPath + ', ' + $newOwner
            if ($oldString -ne $newString -and $newOwner -ne 'Unable to get owner') {
                $Script:outputCSV = $outputCSV.Replace($oldString, $newString)
            }
            $branchesPaths.Remove($branchesPaths[$k])
        }
    }
}

# Add branches paths not in Jenkins
foreach ($path in $branchesPaths) {
    # Get owner from name
    try {
        $relatedBranches = $branchesOutput.value | ? {$_.path -eq $path}
        $owner = $relatedBranches[0].owner.displayName
        $owner = "{1} {0}" -f ($owner -split ', ')
    
    } catch {
        $owner = 'Unable to get owner'
    }
    $outputCSV += $path.Split('/')[1] + ', ' + $path + ', ' + $owner
}

Write-Host Successfully compared TFS and Jenkins!

$outputPath += '\BDP Inventory.csv'

Write-Host Creating file at $outputPath
$Error.Clear()

$outputCSV | ConvertFrom-Csv | Export-Csv $outputPath -NoTypeInformation

if (!$Error) {
    Write-Host File created!
} else {
    Write-Host Failed to create file
}