<#  Name: Remove All Triggers
    Removes poll SCM triggers
    Written by Kiriakos Triantafilou 2/9/2017
#>

# Get jobs that need to change triggers
$jobsCompleted = Import-Csv -Path 'L:\MyDocs\Output Files\jobsCompleted.txt' | Get-Unique -AsString

for ($i = 0; $i -lt $jobsCompleted.Count; $i++) {
    
    $jobToRetrigger = $jobsCompleted.jobs[$i]
    $path = 'L:\MyDocs\Jenkins\jobs\' + $jobToRetrigger + '\config.xml'

    try {
        $xml = New-Object xml
        $xml.PreserveWhitespace = $true

        # Import XML
        $xml.Load($path)

        # Get triggers node
        $triggersNode = [System.Xml.XmlElement]$xml.SelectNodes("//triggers")[0]

        # Remove all triggers
        $triggersNode.RemoveAll()

        # Save
        $xml.Save($path)

        Get-Item -Path $path | % {
            (Get-Content $_.FullName).Replace('<triggers></triggers>','<triggers />') | Set-Content $_.FullName
        }

    } catch {
        Write-Host Unable to find path to: $jobToRetrigger
    }
}