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

        $url = (($temp -match 'aag.gfrinc.net/nexus/content/repositories') -match '.pom')[0]

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
