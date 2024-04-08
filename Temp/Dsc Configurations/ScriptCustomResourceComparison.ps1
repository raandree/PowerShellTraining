configuration ScriptCustomResourceComparison
{
    Import-DscResource -ModuleName XmlContentDsc, xPSDesiredStateConfiguration, NetworkingDsc, IngNetworkSettings, SQLCompositeResources, SqlServerDsc

    Script ENVSetup
    {
        GetScript = @{ Result = '' }
        TestScript =
        {
            Return $false
            #(dir env: | Where-Object {$_.name -eq "IFSSYSTEM"}).name -eq "IFSSYSTEM"
        }
        SetScript =
        {
            [Environment]::SetEnvironmentVariable("IFSSYSTEM", "O:\IFSVS_IFS", "Machine")
        }
    }
    
    xEnvironment ENVSetup2
    {
        Name  = 'IFSSYSTEM2'
        Value = 'O:\IFSVS_IFS'
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

    NetworkInterfaceGlobalAutotuning ODBCConfig2
    {
        AutotuningMode = 'Normal'
    }
}

Remove-Item -Path C:\DSC\*
ScriptCustomResourceComparison -OutputPath C:\DSC

Start-DscConfiguration -Wait -Verbose -Force -Path C:\DSC