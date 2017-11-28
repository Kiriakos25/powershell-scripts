<#  Name: Get status of REM websites
    Gets the status of REM sites and displays it in a GUI
    Written by Kiriakos Triantafilou 3/20/2017
#>

$url = '{jenkins}/api/json?tree=jobs[name,color]'
$username = ""
$password = ""
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))
$response = Invoke-RestMethod $url -Method Get -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}
$brokenJobs = $response.jobs | ? {$_.color -ne 'blue' -and $_.color -ne 'disabled' -and $_.color -ne 'notbuilt' -and $_.color -ne 'blue_anime'}

Add-Type -AssemblyName System.Windows.Forms

# Form
$JenkinsBuilds = New-Object system.Windows.Forms.Form
$JenkinsBuilds.Text = "Broken Jenkins Builds"
$JenkinsBuilds.TopMost = $true
$JenkinsBuilds.Width = 700
$JenkinsBuilds.Height = 400

# List View
$listView = New-Object system.windows.Forms.ListView
$listView.View = 'Details'
$listView.Width = 684
$listView.Height = 355
$listView.GridLines = 1
$listView.Scrollable = 1

[void]$listView.Columns.Add(‘Job Name’, 430)
[void]$listView.Columns.Add(‘Status’, 229)

ForEach ($brokenJob in $brokenJobs) {
    $item = New-Object System.Windows.Forms.ListViewItem($brokenJob.name)
    [void]$item.SubItems.Add($brokenJob.color)
    [void]$listView.Items.Add($item)
}

$JenkinsBuilds.controls.Add($listView)
[void]$JenkinsBuilds.ShowDialog()
$JenkinsBuilds.Dispose()
