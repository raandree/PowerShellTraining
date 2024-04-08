Configuration IISWebsite
{
    Import-DscResource -ModuleName NetworkingDsc

    Node $AllNodes.NodeName
    {
        $windowsFeatures = @($Node.WindowsFeatures) + $ConfigurationData.ServerBaseline.WindowsFeatures | Where-Object { $null -ne $_ }
        foreach ($f in $windowsFeatures)
        {
            WindowsFeature $f
            {
                Ensure = 'Present'
                Name   = $f
            }
        }

        File TestFile1
        {
            DestinationPath = 'Z:\TestFile1.txt'
            Contents = '123'
            Type = 'File'
            Ensure = 'Present'
        }

        IPAddress ip {
            IPAddress = $ConfigurationData.NetConfig.IpSubnet + $Node.IpAddress
            InterfaceAlias = $ConfigurationData.NetConfig.InterfaceAlias
            AddressFamily = 'IPv4'
        }
    }
}

$cd = @{
    AllNodes = @(
        @{
            NodeName = 'localhost'
            Role = 'WebServer'
            IpAddress = 5
        }
        @{
            NodeName = 'WebServer01'
            Role = 'WebServer'
            WindowsFeatures = 'Web-Server', 'Web-Asp-Net45'
            IpAddress = 6
        }
        @{
            NodeName = 'FileServer01'
            Role = 'FileServer'
            WindowsFeatures = 'FileAndStorage-Services'
            IpAddress = 7
        }
    )
    
    ServerBaseline = @{
        WindowsFeatures = 'RSAT'
    }

    NetConfig = @{
        IpSubnet = '192.168.11.'
        InterfaceAlias = 'vwADSync1 0'
    }
}

 
Remove-Item C:\DSC\*
IISWebsite -OutputPath C:\DSC -ConfigurationData $cd

#Start-DscConfiguration -Path C:\DSC -Wait -Verbose -Force