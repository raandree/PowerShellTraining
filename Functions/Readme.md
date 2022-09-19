# PowerShell Training Material

## The evolution of a function

We are creating a simple PowerShell script that grows and implements a lot of features that PowerShell provides for making functions flexible, robust, easy to read and self documenting.

The purpose of the script is to find small files and return the overall size of all these files. We start listing all files, then measuring their content, then filtering out files that are not considered to be small and then we convert this into a function. The function will grow like this:
- the basics
- implement parameters
  - that are type safe
  - mandatory or have default values
  - are validated
  - support array values
  - support the pipeline
- provide comment-based help
- make use of custom objects

***

### The Basics

Write a PowerShell script that

1. Finds all files in C:\Windows
    <details><summary></summary>

    ```powershell
    Get-ChildItem -Path C:\Windows -File
    ```
    </details>

2. Calculates the total file size of all files
    <details>
    <summary></summary>

    ```powershell
    Get-ChildItem -Path C:\Windows -File | Measure-Object -Property Length -Sum
    ```
    </details>

3. Then extend it to find the total file size of all files smaller than 100000 bytes
    <details>
    <summary></summary>

    This snippet also demos two different version of using 'Where-Object'.
    
    ```powershell
    Get-ChildItem -Path C:\Windows -File | 
    Where-Object Length -LT 100000 |
    Measure-Object -Property Length -Sum
    ```

    ```powershell
    Get-ChildItem -Path C:\Windows -File | 
    Where-Object -FilterScript { $_.Length -lt 100000 } |
    Measure-Object -Property Length -Sum
    ```
    </details>

4. Now convert this code into a function. Following the PowerShell naming convention
   
   > Hint: use the snippet "function" as a sample, drop the parameters.

    <details>
    <summary></summary>

    ```powershell
    function Get-SmallFile
    {
        Get-ChildItem -Path C:\Windows -File | 
            Where-Object -FilterScript { $_.Length -lt 100000 } | 
            Measure-Object -Property Length -Sum    
    }

    Get-SmallFile
    ```
    </details>

***

### Parameters

5. The function that always targets the same folder does not offer much flexibility. Make the target path a parameter so you can get the file size of any directory you want.

    <details>
    <summary></summary>

    ```powershell
    function Get-SmallFile
    {
        param($Path)

        Get-ChildItem -Path $Path -File | 
            Where-Object -FilterScript { $_.Length -lt 100000 } | 
            Measure-Object -Property Length -Sum    
    }

    Get-SmallFile -Path C:\Windows
    ```
    </details>

6. Now let's make also the maximum file size a parameter.

    <details>
    <summary></summary>

    ```powershell
    function Get-SmallFile
    {
        param($Path, $MaxSize)

        Get-ChildItem -Path $Path -File | 
            Where-Object Length -lt $MaxSize | 
            Measure-Object -Property Length -Sum    
    }

    Get-SmallFile -Path C:\Windows -MaxSize 100000
    ```
    </details>

7. A parameter should almost always have a defined type. The parameter 'Path' takes a string and the parameter 'MaxSize' takes an integer. We convert the parameter definition into a param block and assign types to the parameter.

    >Note: In PowerShell, file sizes are represented in bytes. An Int32 has a max size of 2147483647 which is 2GB. Hence, it is recommended to use an Int64 (long) for file sizes which can store a value up to 8192PB (```[int64]::MaxValue / 1PB```)

    <details>
    <summary></summary>

    ```powershell
    function Get-SmallFile
    {
        param(
            [string]$Path,
            
            [long]$MaxSize
        )

        Get-ChildItem -Path $Path -File | 
            Where-Object Length -lt $MaxSize | 
            Measure-Object -Property Length -Sum    
    }

    Get-SmallFile -Path C:\Windows -MaxSize 100000
    ```
    </details>

8. Making parameters mandatory and assigning default values makes the function easier to use and prevents errors.
   
   - Make the parameter 'Path' mandatory and 
   - Assign the parameter 'MaxSize' a default value of 100KB

    <details>
    <summary></summary>

    ```powershell
    function Get-SmallFile
    {
        param(
            [Parameter(Mandatory)]
            [string]$Path,
            
            [long]$MaxSize = 100KB
        )

        Get-ChildItem -Path $Path -File | 
            Where-Object Length -lt $MaxSize | 
            Measure-Object -Property Length -Sum    
    }

    Get-SmallFile -Path C:\Windows
    Get-SmallFile -Path C:\Windows -MaxSize 100KB
    ```
    </details>

    >Note, that both calls to 'Get-SmallFile' return the same result. The first call uses the default value for 'MaxSize' as defined in the function, the second call explicitly overwrites the default with the same value as the default.

***

### Parameter Validation

9. To enhance the parameter handling even more, we can add validation attributes to the parameters. See [Validating Parameter Input](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/validating-parameter-input?view=powershell-7) and [About Functions Advanced Parameters](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters?view=powershell-7#:~:text=ValidateNotNullOrEmpty%20validation%20attribute.%20The%20ValidateNotNullOrEmpty%20attribute%20specifies%20that,%22%22%20%29%2C%20or%20an%20empty%20array%20%40%20%28%29.). This prevents the script or function to use data that does not comply with the validation definition.

    >Note: One may want to use the validator 'ValidateNotNullOrEmpty'. In case of an integer it does not work as an integer cannot be empty nor $null.

    - Make sure that the 'MaxSize' parameter does not accept a value smaller than 1.
    - Make sure the path exists before trying to read the files.

    <details>
    <summary></summary>

    ```powershell
    function Get-SmallFile
    {
        param(
            [Parameter(Mandatory)]
            [ValidateScript({Test-Path -Path $_ -PathType Container})]
            [string]$Path,
            
            [ValidateRange(1, [long]::MaxValue)]
            [long]$MaxSize = 100KB
        )

        Get-ChildItem -Path $Path -File | 
            Where-Object Length -lt $MaxSize | 
            Measure-Object -Property Length -Sum    
    }

    Get-SmallFile -Path C:\Windows\notepad.exe #This will throw a validation error
    ```
    </details>

***

### Supporting array values

10. To make the function more generic, it should be able to work with multiple folders and not just one and support wildcards.

    - To be able to provide two or more folders we need to change the parameter type for 'Path' from string to a string array (\[string\] -> \[string\[\]\]).
    - To support wildcards, we don't have to change the parameter handling. But when the function has received a value containing a wildcard, it needs to resolve that first into all possible folder names. For this, the Cmdlet 'Resolve-Path' comes handy.

    ```powershell
    Resolve-Path -Path C:\Win*
    Resolve-Path -Path C:\P*
    ```

    >Note: In this example we do it the simple way by using one of the *-Path Cmdlets. For more complex scenarios refer to the classes 'System.Management.Automation.WildcardPattern' and 'System.Management.Automation.WildcardOptions'.

    <details>
    <summary></summary>

    ```powershell
    function Get-SmallFile
    {
        param(
            [Parameter(Mandatory)]
            [ValidateScript({Test-Path -Path $_ -PathType Container})]
            [string[]]$Path,
            
            [ValidateRange(1, [long]::MaxValue)]
            [long]$MaxSize = 100KB
        )

        $Path = Resolve-Path -Path $Path

        Get-ChildItem -Path $Path -File |
            Where-Object Length -lt $MaxSize |
            Measure-Object -Property Length -Sum
    }

    Get-SmallFile -Path C:\Win*
    ```
    </details>

11. Now we have a little problem. We are providing more than one folder but the result of the script looks like this:
    
    ```
    Count    : 2123
    Average  : 
    Sum      : 88117159
    Maximum  : 
    Minimum  : 
    Property : Length
    ```
    
    If you call the function with more than one folder like ```Get-SmallFile -Path C:\Windows, C:\Windows\System32```, you have no idea how many files are in each folder. You get only one summary object for two or more folders so the function does distinguish not between folders.

    Let's change the way how the function is returning the data. Instead of piping all the small files into 'Measure-Object' and get just one summary object, we are creating one summary object per path. We use the 'foreach' keyword to walk over all the paths provided.

    <details>
    <summary></summary>

    ```powershell
    function Get-SmallFile
    {
        param(
            [Parameter(Mandatory)]
            [ValidateScript({Test-Path -Path $_ -PathType Container})]
            [string[]]$Path,
                    
            [ValidateRange(1, [long]::MaxValue)]
            [long]$MaxSize = 100KB
        )

        $Path = Resolve-Path -Path $Path

        foreach ($p in $Path) {
            Get-ChildItem -Path $p -File | 
            Where-Object Length -lt $MaxSize |
            Measure-Object -Property Length -Sum
        }
    }

    Get-SmallFile -Path C:\Windows, C:\Windows\System32
    ```
    </details>

    Now the output looks like this, when providing two folders that contain files:

    ```
    Count    : 21
    Average  : 
    Sum      : 493290
    Maximum  : 
    Minimum  : 
    Property : Length

    Count    : 2102
    Average  : 
    Sum      : 87623869
    Maximum  : 
    Minimum  : 
    Property : Length
    ```

### Creating custom return values

12. Still we have an issue with the output. Yes, we get one summary object per folder now but we don't know which summary object belongs to which folder. And we don't want to trust the ordering. So instead returning the object that Measure-Object returns, we are creating our own object that contains all the data that is needed.

    You can create a custom object like this:

    ```powershell
    $car = [pscustomobject]@{
        Manufacturer = 'VW'
        Model        = 'Golf'
        Color        = 'Red'
    }

    $car
    ```

    The object in the variable $car then looks like this:
    ```
    Manufacturer Model Color
    ------------ ----- -----
    VW           Golf  Red
    ```

    Now we use that concept to enrich the function's output. We also return the context of the operation to give a full picture.

    <details>
    <summary></summary>

    ```powershell
    function Get-SmallFile
    {
        param(
            [Parameter(Mandatory)]
            [ValidateScript({Test-Path -Path $_ -PathType Container})]
            [string[]]$Path,
                    
            [ValidateRange(1, [long]::MaxValue)]
            [long]$MaxSize = 100KB
        )

        $Path = Resolve-Path -Path $Path

        foreach ($p in $Path) {
            $result = Get-ChildItem -Path $p -File | 
            Where-Object Length -lt $MaxSize |
            Measure-Object -Property Length -Sum

            [pscustomobject]@{
                Path        = $p
                MaxSize     = $MaxSize
                FileSizeSum = $result.Sum
                FileCount   = $result.Count
            }
        }
    }

    Get-SmallFile -Path C:\Windows, C:\Windows\System32
    ```
    </details>

    And now the output looks much nicer:

    ```
    Path                MaxSize FileSizeSum
    ----                ------- -----------
    C:\Windows           102400      493290
    C:\Windows\System32  102400    87623869
    ```

    As we control the output now, we can also add other properties that might be interesting and can change the formatting. 

    <details>
    <summary></summary>

    ```powershell
    function Get-SmallFile
    {
        param(
            [Parameter(Mandatory)]
            [ValidateScript({Test-Path -Path $_ -PathType Container})]
            [string[]]$Path,
                    
            [ValidateRange(1, [long]::MaxValue)]
            [long]$MaxSize = 100KB
        )

        $Path = Resolve-Path -Path $Path

        foreach ($p in $Path) {
            $result = Get-ChildItem -Path $p -File | 
            Where-Object Length -lt $MaxSize |
            Measure-Object -Property Length -Sum -Average

            [pscustomobject]@{
                Path         = $p
                MaxSize      = $MaxSize
                FileSizeSum  = $result.Sum
                FileCount   = $result.Count
                AverageSize  = [System.Math]::Round($result.Average, 2)
            }
        }
    }

    Get-SmallFile -Path C:\Windows, C:\Windows\System32
    ```
    </details>

    So the output changes to this:

    ```
    Path                MaxSize FileSizeSum AverageSize
    ----                ------- ----------- -----------
    C:\Windows           102400      493290       23490
    C:\Windows\System32  102400    87623869    41685.95
    ```

***

## Supporting the pipeline

13. Now we want our function to work like many other comfortable Cmdlets by adding pipeline support. This means we want to use the function like ```Get-Item C:\Windows | Get-SmallFile``` or even better like ```dir d:\ -Directory | Get-SmallFile```, which at the moment does not work, as you can easily test.

    In order for this to work, you have to enable one parameter to accept input from the pipeline. This can be done quite easily by adding the attribute value 'ValueFromPipeline' to the parameter 'Path':

    ```powershell
    [Parameter(Mandatory, ValueFromPipeline)]
    [ValidateScript({Test-Path -Path $_ -PathType Container})]
    [string[]]$Path,
    ```
    
    After the change, the function takes input from the pipeline but the result does not match the input. Only the last item is returned.

    ```powershell
    Get-Item -Path C:\Windows, 'C:\Program Files' | Get-SmallFile
    ```
    ```
    Path             MaxSize FileSizeSum
    ----             ------- -----------
    C:\Program Files  102400        
    ```

    This is because the pipeline is actually kind of a foreach each loop and you have to tell PowerShell, which section in your function should be called for each object that is piped into the function. A pipeline aware function has three code blocks:
    - Begin
    - Process
    - End
    
    More information on this topic: [About Functions Advanced Methods](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_methods?view=powershell-7).

    > If these blocks are not defined, PowerShell defaults to 'End', which explains why we only see the last element. So we put the whole function code inside a process block to make sure it gets called for each element that is piped in:

    <details>
    <summary></summary>

    ```powershell
    function Get-SmallFile
    {
        param(
            [Parameter(Mandatory, ValueFromPipeline)]
            [ValidateScript({Test-Path -Path $_ -PathType Container})]
            [string[]]$Path,
                    
            [ValidateRange(1, [long]::MaxValue)]
            [long]$MaxSize = 100KB
        )

        process {
            $Path = Resolve-Path -Path $Path

            foreach ($p in $Path) {
                $result = Get-ChildItem -Path $p -File | 
                Where-Object Length -lt $MaxSize |
                Measure-Object -Property Length -Average -Sum

                [pscustomobject]@{
                    Path        = $p
                    MaxSize     = $MaxSize
                    FileSizeSum = $result.Sum
                    AverageSize  = [System.Math]::Round($result.Average, 2)
                }
            }
        }
    }
    
    Get-Item -Path C:\Windows, 'C:\Program Files' | Get-SmallFile
    ```
    </details>

    Now we can call the functions using parameter or the pipeline:
    ```powershell
    Get-SmallFile -Path 'C:\Windows', 'C:\Program Files'
    'C:\Windows', 'C:\Program Files' | Get-SmallFile
    Get-Item -Path C:\Windows, 'C:\Program Files' | Get-SmallFile
    ```

14. Now that we have the data returned for each folder, having the option to add also a summary object could be quite helpful in some cases. For making this optional, we add a new parameter to the param block:

    ```powershell
        [switch]$AddSummary
    ```

    Then we make use of the begin block to initialize an object to store the summary information. Please add the following block above the process block:

    ```powershell
    begin {
            $summary = [pscustomobject]@{
                Path         = 'Summary'
                FileCount    = 0
                Size         = 0
                MaxSize      = $MaxSize
            }
        }
    ```

    For each record that is processed we are adding the file count and the size to the summary object like this:

    ```powershell
    $summary.FileCount += $result.Count
    $summary.Size += $result.Sum
    ```

    At the end of the process in the end block, the function returns the summary object along with the other objects that contain the info for each folder.

    ```powershell
    end {
        if ($AddSummary) {
            $summary
        }
    }
    ```

15. Finally, it is time to add some help to the function. For this, we add a comment block at the very beginning of the function. It is important to use the help keywords described in [About Comment-based Help](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help?view=powershell-7) to organize your data into sections that 'Get-Help' understands.

    <details>
    <summary></summary>

    ```powershell
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
                $result = Get-ChildItem -Path $p -File | 
                Where-Object -FilterScript { $_.Length -le $MaxSize } | 
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

    Get-Item -Path C:\Windows, 'C:\Program Files' | Get-SmallFile
    ```
    </details>
