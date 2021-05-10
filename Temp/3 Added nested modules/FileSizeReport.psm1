function Get-SmallFile
{
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [string[]]$Path,
                
        [ValidateRange(1, [long]::MaxValue)]
        [long]$MaxSize = 100KB,
        
        [switch]$AddSummary
    )

    begin {
        $summary = [pscustomobject]@{
            Path         = 'Summary'
            FileCount    = 0
            Size         = 0
            MaxSize      = $MaxSize
        }
        $summary.PSObject.TypeNames.Insert(0, 'FileSizeReport')
    }
    
    process {
        $Path = Resolve-Path -Path $Path
        
        foreach ($p in $Path) {
            $result = Get-Files -Path $p -MaxSize $MaxSize
        
            $result = [pscustomobject]@{
                Path         = $p
                FileCount    = $result.Count
                Size         = $result.Sum
                MaxSize      = $MaxSize
            }
            $result.PSObject.TypeNames.Insert(0, 'FileSizeReport')
            $result
            
            $summary.FileCount += $result.FileCount
            $summary.Size += $result.Size
        }
    }
    
    end {
        if ($AddSummary) {
            $summary
        }
    }
}
