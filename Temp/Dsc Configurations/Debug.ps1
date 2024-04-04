#usually the process consuming the most memory is the DSC one
$p = Get-Process -Name WmiPrvSE -IncludeUserName |
Where-Object UserName -eq 'NT AUTHORITY\SYSTEM' |
Sort-Object -Property WS -Descending |
Select-Object -First 1

Enter-PSHostProcess -Process $p -AppDomainName DscPsPluginWkr_AppDomain
$rs = Get-Runspace | Where-Object { $_.Debugger.InBreakpoint }
Debug-Runspace -Runspace $rs