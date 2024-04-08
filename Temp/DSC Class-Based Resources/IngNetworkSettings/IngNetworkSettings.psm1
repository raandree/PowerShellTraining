enum AutoTuningMode
{
    Normal
    Disabled
}

[DscResource()]
class NetworkInterfaceGlobalAutotuning
{
    [DscProperty(Key)]
    [AutoTuningMode]$AutotuningMode

    [DscProperty(NotConfigurable)]
    [string]$NetshOutput

    [string]$RegExPattern = 'Receive Window Auto-Tuning Level    : (?<Mode>\w+)'

    [NetworkInterfaceGlobalAutotuning]Get()
    {
        #Wait-Debugger
        $currentState = [NetworkInterfaceGlobalAutotuning]::new()

        Write-Verbose 'Running netsh.exe to get the current configuration. The command used is:'
        Write-Verbose 'netsh interface tcp show global'
        $currentState.NetshOutput = netsh interface tcp show global
        
        $m = [regex]::Match($currentState.NetshOutput, $this.RegExPattern)
        Write-Verbose "The current value for AutotuningMode is: $($m.Groups['Mode'].Value)"
        
        $currentState.AutotuningMode = $m.Groups['Mode'].Value
        return $currentState
    }

    [void]Set() {
        $result = netsh interface tcp set global autotuning=$($this.AutotuningMode)
        if (-not ($result -eq 'Ok.'))
        {
            Write-Error 'Could not set global autotuning using Netsh.exe'
        }
    }

    [bool]Test() {
        $currentState = $this.Get()
        return $currentState.AutotuningMode -eq $this.AutotuningMode
    }
}