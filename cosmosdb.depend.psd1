@{
    psake             = @{
        Name           = 'psake'
        DependencyType = 'PSGalleryModule'
        Parameters     = @{
            Repository         = 'PSGallery'
            SkipPublisherCheck = $true
        }
        Target         = 'CurrentUser'
        Version        = '4.7.4'
        Tags           = 'Bootstrap'
    }

    Pester            = @{
        Name           = 'Pester'
        DependencyType = 'PSGalleryModule'
        Parameters     = @{
            Repository         = 'PSGallery'
            SkipPublisherCheck = $true
        }
        Target         = 'CurrentUser'
        Version        = '4.4.2'
        Tags           = 'Test'
    }

    PSScriptAnalyzer  = @{
        Name           = 'PSScriptAnalyzer'
        DependencyType = 'PSGalleryModule'
        Parameters     = @{
            Repository         = 'PSGallery'
            SkipPublisherCheck = $true
        }
        Target         = 'CurrentUser'
        Version        = '1.17.1'
        Tags           = 'Test'
    }

    BuildHelpers      = @{
        Name           = 'BuildHelpers'
        DependencyType = 'PSGalleryModule'
        Parameters     = @{
            Repository         = 'PSGallery'
            SkipPublisherCheck = $true
        }
        Target         = 'CurrentUser'
        Version        = '2.0.0'
        Tags           = 'Init'
    }

    PSDeploy          = @{
        Name           = 'PSDeploy'
        DependencyType = 'PSGalleryModule'
        Parameters     = @{
            Repository         = 'PSGallery'
            SkipPublisherCheck = $true
        }
        Target         = 'CurrentUser'
        Version        = '1.0'
        Tags           = 'Deploy'
    }

    Platyps           = @{
        Name           = 'Platyps'
        DependencyType = 'PSGalleryModule'
        Parameters     = @{
            Repository         = 'PSGallery'
            SkipPublisherCheck = $true
        }
        Target         = 'CurrentUser'
        Version        = '0.12'
        Tags           = 'Build'
    }

    'AzureRM'         = @{
        Name           = 'AzureRM'
        DependencyType = 'PSGalleryModule'
        Parameters     = @{
            Repository         = 'PSGallery'
            SkipPublisherCheck = $true
        }
        Target         = 'CurrentUser'
        Version        = '6.8.1'
        Tags           = 'Test_Desktop'
    }

    'AzureRM.NetCore' = @{
        Name           = 'AzureRM.NetCore'
        DependencyType = 'PSGalleryModule'
        Parameters     = @{
            Repository         = 'PSGallery'
            SkipPublisherCheck = $true
        }
        Target         = 'CurrentUser'
        Version        = '0.13.1'
        Tags           = 'Test_Core'
    }
}
