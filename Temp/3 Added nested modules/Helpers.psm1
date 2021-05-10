function Get-Files {
    param(
        [Parameter(Mandatory)]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [string[]]$Path,
                
        [ValidateRange(1, [long]::MaxValue)]
        [long]$MaxSize = 100KB
    )
    
    Get-ChildItem -Path $Path -File -Recurse | 
        Where-Object -FilterScript { $_.Length -le $MaxSize } | 
        Measure-Object -Property Length -Sum
}
