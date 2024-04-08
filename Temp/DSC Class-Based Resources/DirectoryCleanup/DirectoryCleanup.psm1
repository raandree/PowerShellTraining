class Property1
{
    [DscProperty()]
    [long]$MaxFileSize

    [DscProperty()]
    [bool]$Recursive
    
    [DscProperty()]
    [int]$Int
}

[DscResource()]
class DirectoryCleanup {

    [DscProperty(Key = $true)]
    [string]$Path

    [DscProperty()]
    [long]$MaxFileSize

    [DscProperty()]
    [bool]$Recursive
    
    [DscProperty()]
    [string]$Stringx
    
    [DscProperty()]
    [string[]]$StringArray
    
    [DscProperty()]
    [char]$Char
    
    [DscProperty()]
    [char[]]$CharArray
    
    [DscProperty()]
    [hashtable]$Hashtable
    
    [DscProperty()]
    [hashtable[]]$HashtableArray
    
    [DscProperty()]
    [int16]$Short
    
    [DscProperty()]
    [int16[]]$ShortArray
    
    [DscProperty()]
    [int]$Int
    
    [DscProperty()]
    [int[]]$IntArray
    
    [DscProperty()]
    [long]$Long
    
    [DscProperty()]
    [long[]]$LongArray
    
    [DscProperty()]
    [System.UInt16]$UInt16x
    
    [DscProperty()]
    [System.UInt16[]]$UInt16Array
    
    [DscProperty()]
    [System.UInt32]$UInt32x
    
    [DscProperty()]
    [System.UInt32[]]$UInt32Array
    
    [DscProperty()]
    [System.UInt64]$UInt64x
    
    [DscProperty()]
    [System.UInt64[]]$UInt64Array
    
    [DscProperty()]
    [double]$Double
    
    [DscProperty()]
    [double[]]$DoubleArray
    
    [DscProperty()]
    [float]$Float
    
    [DscProperty()]
    [float[]]$FloatArray
    
    #[DscProperty()]
    #[decimal]$Decimal
    
    #[DscProperty()]
    #[decimal[]]$DecimalArray
    
    [DscProperty()]
    [bool]$Bool
    
    [DscProperty()]
    [bool[]]$BoolArray
    
    [DscProperty()]
    [byte]$Byte
    
    [DscProperty()]
    [byte[]]$ByteArray
    
    [DscProperty()]
    [DateTime]$DataTime
    
    [DscProperty()]
    [DateTime[]]$DataTimeArray
    
    #[DscProperty()]
    #[Microsoft.Management.Infrastructure.CimInstance]$CimInstance
    
    #[DscProperty()]
    #[Microsoft.Management.Infrastructure.CimInstance[]]$CimInstanceArray
    
    [DscProperty()]
    [Property1]$Classx
    
    [DscProperty()]
    [Property1[]]$ClassArray

    [DscProperty(NotConfigurable)]
    [string[]]$LargeFiles

    [DirectoryCleanup]Get() {

        $currentState = [DirectoryCleanup]::new()

        $currentState.Path = $this.Path
        $currentState.MaxFileSize = $this.MaxFileSize
        $currentState.LargeFiles = dir -Path $this.Path -Recurse:$this.Recursive | Where-Object Length -gt $this.MaxFileSize | Select-Object -ExpandProperty FullName

        return $currentState
    }

    [bool]Test() {
        $currentState = $this.Get()

        Write-Verbose "The large file count of folder '$($currentState.Path)' is $($currentState.LargeFiles.Count)."
        Wait-Debugger
        return -not [bool]$currentState.LargeFiles.Count
        #For comparing the state of complex data, look at Test-DscParameterState in module DscResource.Common
        #https://github.com/dsccommunity/DscResource.Common
    }

    [void]Set() {
        dir -Path $this.Path -Recurse:$this.Recursive | Where-Object Length -gt $this.MaxFileSize | ForEach-Object {

            Write-Verbose ("Removing file '{0}' with a size of {1:n2}MB." -f $_.Name, ($_.Length / 1MB))
            $_ | Remove-Item -Force -Confirm:$false

        }
    }
}
