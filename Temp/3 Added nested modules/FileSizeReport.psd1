@{

    RootModule = 'FileSizeReport.psm1'

    ModuleVersion = '0.1'
    GUID = 'e6c169b0-1047-4df6-b9fd-b635daf3834b'

    Author = 'Ich'

    CompanyName = 'Unknown'

    Copyright = '(c) 2020 Ich. All rights reserved.'

    Description = 'File Server Reporting'

    PowerShellVersion = '5.0'

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    FormatsToProcess = 'FileSizeReport.format.ps1xml'

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    NestedModules = @('Helpers.psm1')

    FunctionsToExport = 'Get-SmallFile'

    CmdletsToExport = '*'

    VariablesToExport = '*'

    AliasesToExport = '*'

    # ModuleList = @()

    # FileList = @()

    PrivateData = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            # Tags = @()

            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            # ProjectUri = ''

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            # ReleaseNotes = ''

        }

    }
}
