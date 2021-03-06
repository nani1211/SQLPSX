CLS
. PSUnit.ps1
. (Join-Path -Path $env:PSUNIT_HOME -ChildPath "SQLPSX\SSIS.ps1")

#Function Test.Get-ISSqlConfigurationItem([switch] $Skip)
Function Test.Get-ISSqlConfigurationItem([switch] $Category_Config)
{
    #Act
    $Actual = Get-ISSqlConfigurationItem "$env:computername\SQL2K8" 'ssisconfig' '[SSIS Configurations]' 'sqlpsx_ssis' '\Package.Connections[Destination].Properties[ConnectionString]'
    Write-Debug $($Actual.GetType().FullName)
    #Assert
    Assert-That -ActualValue $Actual -Constraint {$ActualValue -is "System.String"}
}

#function Test.New-ISItem([switch] $Skip)
function Test.New-ISItem([switch] $Category_NewISItem)
{
    #Arrange
    new-isitem '\msdb' 'sqlpsx' $env:computername
    #Act
    $Actual = Test-ISPath 'msdb\sqlpsx' $env:computername 'Folder'
    Write-Debug $Actual
    #Assert
    Assert-That -ActualValue $Actual -Constraint {$Actual}
}

#function Test.copy-isitemfiletosql([switch] $Skip)
function Test.copy-isitemfiletosql([switch] $Category_CopyISItem)
{
    #Arrange
    copy-isitemfiletosql -path "C:\Program Files\Microsoft SQL Server\100\DTS\Packages\*" -destination "msdb\sqlpsx" -destinationServer "$env:computername" -connectionInfo @{SSISCONFIG=".\SQLEXPRESS"}
    #Act
    $Actual = (get-isitem -path '\sqlpsx' -topLevelFolder 'msdb' -serverName "$env:computername\SQL2K8" | Measure-Object).Count
    Write-Debug $Actual
    #Assert
    Assert-That -ActualValue $Actual -Constraint {$ActualValue -eq 24}
}

#function Test.copy-isitemsqltosql([switch] $Skip)
function Test.copy-isitemsqltosql([switch] $Category_CopyISItem)
{
    #Arrange
    new-isitem '\msdb' 'sqlpsx2' $env:computername
    copy-isitemsqltosql -path '\sqlpsx' -topLevelFolder 'msdb' -serverName "$env:computername\SQL2K8" -destination 'msdb\sqlpsx2' -destinationServer "$env:computername" -recurse -connectionInfo @{SSISCONFIG='.\SQL2K8'}
    #Act
    $Actual = (get-isitem -path '\sqlpsx2' -topLevelFolder 'msdb' -serverName "$env:computername\SQL2K8" | Measure-Object).Count
    Write-Debug $Actual
    #Assert
    Assert-That -ActualValue $Actual -Constraint {$ActualValue -eq 24}
}

#function Test.copy-isitemsqltofile([switch] $Skip)
function Test.copy-isitemsqltofile([switch] $Category_CopyISItem)
{
    #Arrange
    copy-isitemsqltofile -path '\sqlpsx' -topLevelFolder 'msdb' -serverName "$env:computername\SQL2K8" -destination 'c:\Users\u00\bin\SSIS' -recurse -connectionInfo @{SSISCONFIG='.\SQLEXPRESS'}
    #Act
    $Actual = (get-item -path C:\Users\u00\bin\SSIS\*.dtsx | Measure-Object).Count
    Write-Debug $Actual
    #Assert
    Assert-That -ActualValue $Actual -Constraint {$ActualValue -eq 24}
}





