$username = ""
$password = ""

$url = "http://{jenkins}/job/{job}/buildWithParameters?token=test"
$body = @"
    {
        "parameter": [
            {
                "name":"CREATE_RELEASE",
                "value":"false"
            },
            {
                "name":"RELEASE_VERSION",
                "value":"1.3.0"
            },
            {
                "name":"NEW_DEV_VERSION",
                "value":"1.4.0-d"
            }
        ]
    }
"@


# Needed for authentification matching basic authentication
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))

$test = Invoke-RestMethod $url -Method Post  -Body $body -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}

