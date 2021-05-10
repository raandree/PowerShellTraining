# PowerShell Training Material

## Adding a helper module

Our code here is very simple, but as soon as things get more complex, you want to move internal code into the background. The concept is as ld as programming: You present an interface to the user which can be a UI or a set of PowerShell cmdlets. These cmdlets are calling the internal functions which are doing usually the most of the work.

Due to the simplicity of our module, helper functions are not really required. But we are adding one for introducing the concept and presenting the most simple solution for realizing this in a PowerShell module.

A good candidate for refactoring is the call in line 58

$result = Get-ChildItem -Path $p -File -Recurse | 
                Where-Object -FilterScript { $_.Length -le $MaxSize } | 
                Measure-Object -Property Length -Sum

We are extending the file structure a bit by adding the files marked with an asterisk.

```
├───Documents
│   ├───WindowsPowerShell
│   │   ├───ModuleName
│   │   │   │   ModuleName.psd1
│   │   │   │   ModuleName.psm1
│   │   │   │   
│   │   │   └───Helpers *
│   │   │           Helpers.psm1 *
```

1. Creating the module helpers folder

Pretty similar to the previous task, we start with creating the folder. The path of the new folder is ```C:\Users\<YourName>\OneDrive\Documents\WindowsPowerShell\Modules\FileSizeReporter\Helpers```.

```powershell
$path = "$([System.Environment]::GetFolderPath('MyDocuments'))\WindowsPowerShell\Modules\FileSizeReporter"

mkdir -Path $path -Force
```

2. Creating the helpers psm1 file

The like in the previous task, we create a psm1 file in the Helpers directory named 'Helpers.psm1'. The content of the psm1 file should be:

```powershell
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
```

You can create this file and set the content with the Windows Explorer and Notepad or PowerShell. If you use PowerShell, make sure the variable '$path' defined in the previous step still exists.

```powershell
@'
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
'@ | Set-Content -Path "$path\Helpers.psm1"
```

