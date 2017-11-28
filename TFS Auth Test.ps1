$user = ""
$pass= ""
$secpasswd = ConvertTo-SecureString $pass -AsPlainText -Force
$uri = '{tfs}'
$credential = New-Object System.Management.Automation.PSCredential($user, $secpasswd)

Invoke-RestMethod -Uri $uri -Credential $credential
