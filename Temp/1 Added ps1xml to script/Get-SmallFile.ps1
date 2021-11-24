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
            $result = Get-ChildItem -Path $p -File -Recurse | 
            Where-Object -FilterScript { $_.Length -le $MaxSize } | 
            Measure-Object -Property Length -Sum
        
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

Get-SmallFile -Path D:\D, D:\Datum* -MaxSize 500MB -AddSummary
