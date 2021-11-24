# PowerShell Training Material

## Advancing a function to a module

The are many advantage moving a single function into a module:

- Functions inside a module are automatically loaded and can be easily discovered
- Modules provide metadata like the author, version and more
- Code in modules can be structured and spread over multiple files
- Functions in modules can be made private to give the user a better experience
- Modules can come with formatters which makes output look nice by default

We are converting the function we have created previously into a module and add features step by step. We are starting with the most basic module structure, which is only a psm1 and psd1 file in a folder which has the same name as the module. In fact, to make it even simpler, we could have removed the psd1 as well.

The file structure of a simple PowerShell module looks like this:

```
├───Documents
│   ├───WindowsPowerShell
│   │   ├───Modules   
│   │   │   ├───ModuleName
│   │   │   │       ModuleName.psd1
│   │   │   │       ModuleName.psm1
```

### 1. Creating the module folder

Let's name our new module '**FileSizeReporter**'. The path for that module hence would be ```C:\Users\<YourName>\OneDrive\Documents\WindowsPowerShell\Modules\FileSizeReporter```.

You can create the folder with the Windows Explorer or with this PowerShell command:

```powershell
$path = "$([System.Environment]::GetFolderPath('MyDocuments'))\WindowsPowerShell\Modules\FileSizeReporter"

mkdir -Path $path -Force
```

### 2. Creating the psm1 file

You can create this file again with the Windows Explorer or PowerShell.

> If you use PowerShell, make sure the variable '$path' defined in the previous step still exists.

```powershell
New-Item -Path $path -Name FileSizeReporter.psm1 -ItemType File
```

Paste the complete function (and only the function, not the function call) create in the last step of the last section into the psm1 file and save it.

With these small two steps you have created your first module. This should now be visible when calling 

```powershell
Get-Module -ListAvailable File*
```

The output is like this:

```
    Directory: C:\Users\randr\OneDrive\Documents\WindowsPowerShell\Modules


ModuleType Version    Name                                ExportedCommands
---------- -------    ----                                ----------------
Script     0.0        FileSizeReporter                    Get-SmallFile
```

You can call the function 'Get-SmallFile' without importing the module previously. PowerShell will do that job for you.

### 3. Creating the psd1 file

The psd1 file contains metadata about the module like the version, author, description and also some dependencies and requirements like the minimum PowerShell version.

The easiest way to create the PowerShell data file also called module manifest is by calling 'New-ModuleManifest'. As quite a few parameters are used, we create a parameter hash table first and splat that it to 'New-ModuleManifest'. And this is how it looks like:

```powershell
$param = @{
    Path                   = "$path\FileSizeReporter.psd1"
    Author                 = 'Me'
    ClrVersion             = '4.0'
    CompanyName            = 'Contoso'
    CompatiblePSEditions   = 'Desktop', 'Core'
    Copyright              = "$((Get-Date).Year) by me"
    Description            = 'A simple test module'
    DotNetFrameworkVersion = '4.7.2'
    FileList               = 'FileSizeReporter.psm1', 'FileSizeReporter.psd1'
    FunctionsToExport      = '*'
    Guid                   = (New-Guid)
    ModuleList             = 'FileSizeReporter'
    ModuleVersion          = '0.1'
    PowerShellVersion      = '4.0'
    RootModule             = 'FileSizeReporter.psm1'
}

New-ModuleManifest @param
```

### 4. Test your new module

After you have created the psd1 file, you will see the given version number next to the module when calling 'Get-Module' again:

```powershell
Get-Module -ListAvailable File*'
```

```
    Directory: C:\Users\randr\OneDrive\Documents\WindowsPowerShell\Modules


ModuleType Version    Name                                ExportedCommands
---------- -------    ----                                ----------------
Script     0.1        FileSizeReporter                    Get-SmallFile
```

We now have created a module that exports one function. If that module is present in the PSModulePath, if is automatically loaded by PowerShell when needed. You can view the PSModulePath like this:

```powershell
$env:PSModulePath -split ';'
```

And this is the default PSModulePath:

```
C:\Users\randr\OneDrive\Documents\WindowsPowerShell\Modules
C:\Program Files\WindowsPowerShell\Modules
C:\Windows\system32\WindowsPowerShell\v1.0\Modules
```

This means, you can access the function 'Get-SmallFile' in a new PowerShell session without even knowing in which module it has been defined and if the module is loaded, as long as the module is for example in the path 'C:\Users\randr\OneDrive\Documents\WindowsPowerShell\Modules'.