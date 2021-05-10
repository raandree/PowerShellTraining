function Get-SmallFile {
    <#
        .SYNOPSIS
        Finds small files in a specified folder

        .DESCRIPTION
        This function finds files smaller than a specific size in a specified folder.
        You'll get a few statistics on every folder examined.
        You may enter the folder path directly or through the pipeline (see Get-Help).
        Inaccessible folders are skipped without notification.

        .PARAMETER Path
        The folder path you want to examine.

        .PARAMETER MaxSize
        The maximum file size in byte to examine. The functions ignores files larger than that size.

        .EXAMPLE
        Get-SmallFile -MaxSize 100000 -Path C:\Windows

        .EXAMPLE
        'C:\Windows' | Get-SmallFile -MaxSize 100000

        .EXAMPLE
        Get-Item -Path C:\Windows | Get-SmallFile -MaxSize 100000

        .EXAMPLE
        Get-ChildItem -Directory -Path C:\Windows | Get-SmallFile -MaxSize 100000

        .NOTES
        I hope that was fun.
    #>
    
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript( { Test-Path -Path $_ -PathType Container })]
        [string[]]$Path,
                
        [ValidateRange(1, [long]::MaxValue)]
        [long]$MaxSize = 100KB,
        
        [switch]$AddSummary
    )

    begin {
        $summary = [pscustomobject]@{
            Path      = 'Summary'
            FileCount = 0
            Size      = 0
            MaxSize   = $MaxSize
        }
    }
    
    process {
        $Path = Resolve-Path -Path $Path
        
        foreach ($p in $Path) {
            $result = Get-ChildItem -Path $p -File -Recurse | 
            Where-Object -FilterScript { $_.Length -le $MaxSize } | 
            Measure-Object -Property Length -Sum
        
            [pscustomobject]@{
                Path      = $p
                FileCount = $result.Count
                Size      = $result.Sum
                MaxSize   = $MaxSize
            }
            
            $summary.FileCount += $result.Count
            $summary.Size += $result.Sum
        }
    }
    
    end {
        if ($AddSummary) {
            $summary
        }
    }
}

