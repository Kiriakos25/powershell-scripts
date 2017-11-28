$outputPath = '.'
$jenkinsBaseURL = ''
$jenkinsUsername = ''
$jenkinsAPI = '' # This will change per env of Jenkins
#######################################################################################################

$outputFilePath = $outputPath + '\Plugin Info.csv'
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $jenkinsUsername,$jenkinsAPI)))
$jenkinsConsoleUrl = $jenkinsBaseURL + '/scriptText'
$script = @'
script=
println "Plugin Name, Plugin Id, Installed Version, Update Available"
Jenkins.instance.pluginManager.plugins.each{
  plugin ->
    println ("${plugin.getDisplayName()}, ${plugin.getShortName()}, ${plugin.getVersion()}, ${plugin.hasUpdate() ? "Yes" : "No"}")
}
'@

$jenkinsPluginResponse = Invoke-RestMethod $jenkinsConsoleUrl -Method Post -Body $script -Headers @{ Authorization = ("Basic {0}" -f $base64AuthInfo)}

$jenkinsPluginInfo = $jenkinsConsoleResponse | ConvertFrom-Csv
# Remove extra last item
$jenkinsPluginInfo[0..($jenkinsPluginInfo.Length-2)] | Export-Csv $outputFilePath -NoTypeInformation
