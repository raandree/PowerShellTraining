Configuration IISWebsite
{
    param (
        [Parameter(Mandatory)]
        [string[]]$ComputerName,

        [Parameter()]
        [string[]]$Feature
    )

    Import-DscResource -ModuleName NetworkingDsc

    Node $ComputerName
    {
        foreach ($f in $Feature)
        {
            WindowsFeature $f
            {
                Ensure = 'Present'
                Name   = $f
            }
        }

        $path = 'C:\TestScript.txt'

        Script TestScript
        {
            GetScript = {
                @{ Result = @{
                        FileObject = Get-Item -Path $using:path
                        Content = Get-Content -Path $using:path
                        #Hash = ...
                    } | ConvertTo-Json
                }
            }
            SetScript = {
                New-Item -Path $using:path -ItemType File -Force -Value Get-Date
            }
            TestScript = {
                Test-Path -Path $using:path
            }
        }

        File TestFile1
        {
            DestinationPath = 'Z:\TestFile1.txt'
            Contents = '123'
            Type = 'File'
            Ensure = 'Present'
        }

        WaitForAll SqlServerInstallationOnSql1
        {
            NodeName = 'sql1'
            ResourceName = 'SqlServer'
            RetryIntervalSec = 5
            RetryCount = 100
        }

        IPAddress ip {
            IPAddress = '192.168.11.5'
            InterfaceAlias = 'vwADSync1 0'
            AddressFamily = 'IPv4'
            DependsOn = '[File]TestFile1', '[WaitForAll]SqlServerInstallationOnSql1'
        }
    }
} 
 
 Remove-Item C:\DSC\*
 IISWebsite -OutputPath C:\DSC -ComputerName localhost -Feature Web-Server, Web-Asp-Net45

 Start-DscConfiguration -Path C:\DSC -Wait -Verbose -Force