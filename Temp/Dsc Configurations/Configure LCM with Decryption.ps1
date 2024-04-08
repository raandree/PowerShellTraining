[DscLocalConfigurationManager()]
configuration LcmSettings
{
    Settings # Single resource, no name!
    {
        RebootNodeIfNeeded = $true
        ConfigurationMode = 'ApplyAndAutoCorrect'
        ActionAfterReboot = 'ContinueConfiguration'
        CertificateID = 'cd079f4bc04595ba07a53d0253fdcb007116a1da'
    }
} 

LcmSettings -OutputPath C:\DSC

Set-DscLocalConfigurationManager -Path C:\DSC