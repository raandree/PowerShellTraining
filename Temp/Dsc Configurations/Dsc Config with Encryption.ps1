configuration CreateLocalUser
{
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    node localhost
    {
        $cred = New-Object pscredential('Admin2', ('Somepass1' | ConvertTo-SecureString -AsPlainText -Force))
   
        xUser LocalAdmin2
        {
            UserName = 'Admin2'
            Password = $cred
        }
    }
}

$configData = @{
    AllNodes           = @(
        @{
            NodeName                    = 'localhost'
            PSDscAllowDomainUser        = $true
            PSDscAllowPlainTextPassword = $true
            CertificateFile             = 'C:\DocCert.cer'
        }
    )
}

Remove-Item -Path C:\DSC\*
CreateLocalUser -OutputPath C:\DSC -ConfigurationData $configData

Start-DscConfiguration -Wait -Verbose -Force -Path C:\DSC