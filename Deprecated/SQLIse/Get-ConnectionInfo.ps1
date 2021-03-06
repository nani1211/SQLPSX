function Get-ConnectionInfo
{
param($bitmap)
 
$ui = New-Grid -Columns 2 -Rows 8 -width 428 -height 324 `
    -Children {
      $script:Action = {
		$connName = $window | Get-ChildControl ConnectionName
        $server = $window | Get-ChildControl Server
        $database = $window | Get-ChildControl Database
        $userName = $window | Get-ChildControl UserName
        $password = $window | Get-ChildControl Password

        $this.Parent.Parent.Tag = new-object PSObject -Property @{
				Name = $connName.Text
                Server = $server.Text
                Database = ($database.Text + '') 
                UserName =  ($userName.Text + '')
                Password = ($Password.Text + '')
            }
            
        $window.Close() 
    }
    
    new-image -source $bitmap -ColumnSpan 2 -Width 400 -Height 40 -HorizontalAlignment Left
    
	New-ComboBox -Name ConnectionName -IsEditable -DisplayMemberPath Name `
        -Row 0 -Column 1 -Width 200 -Height 20 -HorizontalAlignment Left `
        -IsSynchronizedWithCurrentItem $true `
        -DataBinding @{ ItemsSource = New-Binding } `
        -On_SelectionChanged {
         
                if ( [string]::IsNullOrEmpty($this.SelectedItem.UserName) )
                {
                    $Authentication = $window | Get-ChildControl Authentication
                    $Authentication.SelectedIndex = 0
                }
                else
                {
                    $Authentication = $window | Get-ChildControl Authentication
                    $Authentication.SelectedIndex = 1
                }           
            
        } 
	
	
    New-Label -Row 1 "Server name (required):" -VerticalContentAlignment 'Center' -FontWeight Bold
    New-TextBox -Row 1 -Column 1 -Name Server -Width 200 -Height 20 -HorizontalAlignment Left `
        -DataBinding @{Text = New-Binding -Path Server}
    
    New-Label -Row 2 "Connect to database:" -VerticalContentAlignment 'Center'
    New-TextBox -Row 2 -Column 1 -Name Database -Width 200 -Height 20 -HorizontalAlignment Left `
        -DataBinding @{Text = New-Binding -Path Database}
    
    New-Label -Row 3 "Authentication:" -VerticalContentAlignment 'Center'
    New-ComboBox -SelectedIndex 0 -Row 3 -Column 1 -Name Authentication -Width 200 -Height 20 -HorizontalAlignment Left {'Windows Authentication','SQL Server Authentication'} `
    -On_SelectionChanged {$userName = $window | Get-ChildControl userName
                          $password = $window | Get-ChildControl Password
                          if ($this.SelectedIndex -eq 1)
                          {$userName.Visibility = 'Visible'; $password.Visibility = 'Visible'}
                          else
                          {$userName.Visibility = 'Hidden'; $password.Visibility = 'Hidden'}}
    
    New-Label -Row 4 "  User name:" -VerticalContentAlignment 'Center'
    New-TextBox -Row 4 -Column 1 -Name UserName -Width 200 -Height 20 -Visibility 'Hidden' -HorizontalAlignment Left `
        -DataBinding @{Text = New-Binding -Path UserName}
    
    New-Label -Row 5 "  Password:" -VerticalContentAlignment 'Center'
    New-TextBox -Row 5 -Column 1 -Name Password -Width 200 -Height 20 -Visibility 'Hidden' -HorizontalAlignment Left `
        -DataBinding @{Text = New-Binding -Path Password}
        
    New-Separator -Row 6 -ColumnSpan 2
    
    New-StackPanel -Orientation horizontal -Row 7 -Column 1 -HorizontalAlignment Right {
        New-Button -Name Connect "Connect" -Row 7  -On_Click $action -Width 75 -Height 25
        New-Button -Name Cancel "Cancel" -Row 7 -Column 1 -On_Click {$window.Close()} -Width 75 -Height 25
    
    }
}
    $StoredConnections = @()
    if (Test-UserStore -fileName "Connections.xml" -dirName "SQLIse")
    {
	   $StoredConnections = @(Read-UserStore -fileName "Connections.xml" -dirName "SQLIse" -typeName "PSObject")
    }

	$DataContext = @(New-Object PSObject -Property @{
                                                                Name='New'
                                                                Server = $null
                                                                Database = $null
                                                                UserName = $null
                                                                Password = $null
                                                              })
	$DataContext += $StoredConnections

    $ui.DataContext = $DataContext 
        
    $Connection = Show-Window $ui
    if (-not ([string]::isnullorempty($Connection.Server)))
	{
		if ([string]::isnullorempty($Connection.Name))
		{
			$Connection.Name = 'New'
		}
		
		$mergedConnections = Compare-Object $Connection $StoredConnections -Property Name, Server, Database, Username -passthru -includeequal |
			select name, server, database, username, password 
		Write-UserStore -fileName "Connections.xml" -dirName "SQLIse" -object $mergedConnections
		
		$Connection | Write-Output
	}
}
