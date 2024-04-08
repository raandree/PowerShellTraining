configuration XmlTest
{
    Import-DscResource -ModuleName XmlContentDsc, xPSDesiredStateConfiguration, NetworkingDsc, IngNetworkSettings, SQLCompositeResources, SqlServerDsc

    XmlFileContentResource setting1
    {
        Path       = 'C:\Windows\System32\inetsrv\config\applicationHost.config'
        Ensure     = 'Present'
        XPath      = '/configuration/configSections/Test1'
        Attributes = @{ TestValue1 = '1234' }
    }

    #Script ENVSetup
    #{
    #    GetScript = @{ Result = '' }
    #    TestScript =
    #    {
    #        Return $false
    #        #(dir env: | Where-Object {$_.name -eq "IFSSYSTEM"}).name -eq "IFSSYSTEM"
    #    }
    #    SetScript =
    #    {
    #        [Environment]::SetEnvironmentVariable("IFSSYSTEM", "O:\IFSVS_IFS", "Machine")
    #    }
    #}
    
    xEnvironment ENVSetup2
    {
        Name  = 'IFSSYSTEM2'
        Value = 'O:\IFSVS_IFS'
    }

    NetworkInterfaceGlobalAutotuning GlobalAutotuning
    {
        AutotuningMode = 'Normal'
    }

    Script ODBCConfig
    {
        GetScript  = {
            @{ Result = netsh interface tcp show global }
        }
        TestScript =
        {
           ((netsh interface tcp show global) | Select-String -Pattern 'Receive Window Auto-Tuning Level') -like '*disabled*'
        }
        SetScript  =
        {
            netsh interface tcp set global autotuning=disabled
        }
    }

}

Remove-Item -Path C:\DSC\*
XmlTest -OutputPath C:\DSC

Start-DscConfiguration -Wait -Verbose -Force -Path C:\DSC