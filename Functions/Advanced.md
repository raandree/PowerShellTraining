# PowerShell Training Material

## Functions: Advanced Function Design with Parameter Sets 

1. Extending and renaming the function

Ok, in the last section we have created a function that can do only one thing: Return small files, what "small" is can be defined. The function supports the PowerShell pipeline and returns an object, pretty nice so far.

You are tasked to get large files as well. The easiest way to solve the requirement is duplicating the function `Get-SmallFile`, so some small modifications and rename it to `Get-LargeFile`. Then, for finding old files you create `Get-OldFile` and so on. What seems like a simple approach that does not cost much time. But, it comes with technical debt as duplicating code is almost never a good idea. If you find a bug or you want to add a feature to one of these functions, you have to do the change in every function.

Instead of duplicating functions, lets rename the function `Get-SmallFile` to `Get-File` and add an additional parameter named `$MinSize`.

As we cannot search for small and large files at once, the assigned default values need to be removed.

The parameter block should look like this now:

```powershell
param(
    [Parameter(Mandatory, ValueFromPipeline)]
    [ValidateScript( { Test-Path -Path $_ -PathType Container })]
    [string[]]$Path,
            
    [ValidateRange(1, [long]::MaxValue)]
    [long]$MinSize,

    [ValidateRange(1, [long]::MaxValue)]
    [long]$MaxSize,
    
    [switch]$AddSummary
)
```

There is one more change to make in the `FilterScript` for `Where-Object`. Currently, `Where-Object` filters for all files whose length is less than or equal to `$MaxSize`. As the function is no longer generic and accepts `$MinSize` and `$MaxSize`, the operator used and also the parameter used must be dependent on the parameter that was filled in the call.

The code block that generates the result could look like this:

```powershell
$result = Get-ChildItem -Path $p -File | 
    Where-Object -FilterScript { 
        if ($MaxSize) {
            $_.Length -le $MaxSize
        } else {
            $_.Length -ge $MinSize
        }
    } | 
    Measure-Object -Property Length -Average -Sum
```
 
<details><summary>The whole function looks like this:</summary>

```powershell
function Get-File {
    
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateScript( { Test-Path -Path $_ -PathType Container })]
        [string[]]$Path,

        [ValidateRange(1, [long]::MaxValue)]
        [long]$MaxSize,

        [ValidateRange(1, [long]::MaxValue)]
        [long]$MinSize,
        
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
            $result = Get-ChildItem -Path $p -File | 
            Where-Object -FilterScript { 
                if ($MaxSize) {
                    $_.Length -le $MaxSize
                } else {
                    $_.Length -ge $MinSize
                }
            } | 
            Measure-Object -Property Length -Average -Sum
        
            [pscustomobject]@{
                Path         = $p
                FileCount    = $result.Count
                Size         = $result.Sum
                MaxSize      = $MaxSize
                AverageSize  = [System.Math]::Round($result.Average, 2)
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

Get-Item -Path C:\Windows, D:\LabSources\SoftwarePackages | Get-File -MinSize 1MB

```
</details>

2. Working with Parameter Sets

But what happens if someone does not understand our great design and call the function like this?:

```powershell
Get-Item -Path C:\Windows | Get-File -MinSize 1MB -MaxSize 100KB
```

In this case, only the filter condition `$_.Length -le $MaxSize` will be used. Obviously, the parameters `$MinSize` and `$MaxSize` should be mutually exclusive and this introduces [Parameter Sets](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_parameter_sets).

Parameters can belong to one or multiple parameter sets. As in our case we want the parameters `$MinSize` and `$MaxSize` to be mutually exclusive, we assign them both to different parameter sets.

```powershell
[Parameter(ParameterSetName = 'MaxSize')]
[ValidateRange(1, [long]::MaxValue)]
[long]$MaxSize = 100KB,

[Parameter(ParameterSetName = 'MinSize')]
[ValidateRange(1, [long]::MaxValue)]
[long]$MinSize = 100KB,
```

If you want to call the function again with specifying both parameters, you get this error:

```
Parameter set cannot be resolved using the specified named parameters. One or more parameters issued cannot be used together or an    
     | insufficient number of parameters were provided.
```

To make the usage of parameter sets complete, we should not test for which parameter is filled but rather ask the function which parameter set it uses. The property `$PSCmdlet.ParameterSetName` contains the name of the parameter set currently in use.

```powershell
$result = Get-ChildItem -Path $p -File | 
    Where-Object -FilterScript { 
        if ($PSCmdlet.ParameterSetName -eq 'MaxSize') {
            $_.Length -le $MaxSize
        } else {
            $_.Length -ge $MinSize
        }
    } | 
```
