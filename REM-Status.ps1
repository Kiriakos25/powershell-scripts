<#  Name: Get status of REM websites
    Gets the status of REM sites and displays it in a GUI
    Written by Kiriakos Triantafilou 3/20/2017
#>
function Get-REMUrlStatus {
    $siteItems =
    @([pscustomobject]@{site='PROD TFS';url='{TFS}';},
    [pscustomobject]@{site='PROD Jenkins';url='{Jenkins}';},
    [pscustomobject]@{site='PROD Sonar';url='{Sonar}';},
    [pscustomobject]@{site='PROD Nexus';url='{Nexus 2}';},
    [pscustomobject]@{site='PROD Nexus 3';url='{Nexus 3}';},
    [pscustomobject]@{site='Pre-Prod TFS';url='{TFS}';},
    [pscustomobject]@{site='Pre-Prod Jenkins';url='{Jenkins}';},
    [pscustomobject]@{site='Pre-Prod Sonar';url='{Sonar}';},
    [pscustomobject]@{site='Pre-Prod Nexus';url='{Nexus 2}';},
    [pscustomobject]@{site='Pre-Prod Nexus 3';url='{Nexus 3}';},
	[pscustomobject]@{site='Dev TFS';url='{TFS}';},
    [pscustomobject]@{site='Dev Jenkins';url='{Jenkins}';},
    [pscustomobject]@{site='Dev Sonar';url='{Sonar}';},
    [pscustomobject]@{site='Dev Nexus';url='{Nexus 2}';},
    [pscustomobject]@{site='Dev Nexus 3';url='{Nexus 3}';})

    $time = Get-Date -Format R
    $output = @($time)
    $output += "`n"

    foreach ($site in $siteItems) {

        $Error.Clear()

        if ($site -match 'tfs') {
            $statusCode = Invoke-WebRequest $site.url -UseDefaultCredentials -ErrorAction SilentlyContinue | % {$_.StatusCode}
        } else {
            $statusCode = Invoke-WebRequest $site.url -ErrorAction SilentlyContinue | % {$_.StatusCode}
        }

        if ($statusCode -ne 200 -or $Error) {
            $output += $site.site + ' is DOWN!'
            $output += "`n"
        }
    }

    if (!($output -match 'DOWN')) {
        $output += 'All sites are operational!'
    }

    return $output
}

Add-Type -AssemblyName System.Windows.Forms

$REMUrl = New-Object system.Windows.Forms.Form
$REMUrl.Text = "REM URL Status"
$REMUrl.TopMost = $true
$REMUrl.Width = 500
$REMUrl.Height = 300

$output = New-Object system.windows.Forms.RichTextBox
$output.Text = Get-REMUrlStatus
$output.Width = 450
$output.Height = 200
$output.location = new-object system.drawing.point(15,20)
$output.Font = "Microsoft Sans Serif,10"
$REMUrl.controls.Add($output)

$refresh = New-Object system.windows.Forms.Button
$refresh.Text = "Refresh"
$refresh.Width = 80
$refresh.Height = 30
$refresh.location = new-object system.drawing.point(385,220)
$refresh.Font = "Microsoft Sans Serif,10"
$refresh.Add_Click({$output.Text = Get-REMUrlStatus})
$REMUrl.controls.Add($refresh)

[void]$REMUrl.ShowDialog()
$REMUrl.Dispose()
