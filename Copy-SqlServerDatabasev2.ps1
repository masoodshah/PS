<#
Start-Process powershell.exe -Credential “pfg\masood.shah”
.SYNOPSIS
   Copies a SQL Server DB from a source instance to a target instance via backup & restore, optionally renaming the DB at the target
 
.DESCRIPTION
    This script uses SQL Server Management Objects (SMO) to copy a SQL Server database from one instance to another, optionally renaming the database at the target instance.
     
    SQL Server Native backup & restore operations are used to write a backup to a file and restore it to the target instance.
     
    Once restored to the target instance, the database owner is changed to SA and the compatibility level adjusted to match the target instance's model database.
 
    NOTE: This script does NOT delete the backup file that it creates. If you no longer need the file you must delete it manually.
 
.PARAMETER SourceInstance
    The source instance containing the database you want to copy
 
.PARAMETER SourceDatabase
    The name of the database that you want to copy
 
.PARAMETER TargetInstance
    The target instance that you want to copy the database to
 
.PARAMETER TargetDatabase
    The new name for the database at the target SQL Server instance. If omitted, the database will retain the same name as on the source instance
 
.PARAMETER BackupDirectoryPath
    The intermediate location where the backup file will be written. This should be accessible by both the source and target instances
 
.PARAMETER Username
    Username to use when connecting to the source and target instances with a SQL login. If omitted, Windows Authentication is used.
 
.PARAMETER Password
    Password to use when connecting to the source and target instances with a SQL login. If omitted, Windows Authentication is used.
 
.PARAMETER Force
    Force overwriting the database at the target server if a database with the same name already exists
 
.EXAMPLE
   .\Copy-SqlServerDatabase.ps1 -SourceInstance PFGSQLT4N04 -SourceDatabase FCA_Mart -TargetInstance PFGSQLT4N06 -BackupDirectoryPath \\PFGSQLT4N06\bkp

   .\Copy-SqlServerDatabase.ps1 -SourceInstance PFGSQLT4N04 -SourceDatabase ApplicationProcessing -TargetInstance PFGSQLT4N06 -BackupDirectoryPath \\PFGSQLT4N06\bkp
   .\Copy-SqlServerDatabasev2.ps1 -SourceInstance PFGSQLT4N06 -SourceDatabase test -TargetInstance PFGSQLT4N06 -BackupDirectoryPath \\hoswakbackup1\Redgate\pfglbiproc01\PFGLBIPROC01\'test folder' -Force
   .\Copy-SqlServerDatabasev2.ps1 -SourceInstance PFGSQLT4N06 -SourceDatabase Glo_Staging -TargetInstance PFGSQLT4N06 -BackupDirectoryPath \\hoswakbackup1\Redgate\pfglbiproc01\PFGLBIPROC01\Glo_Staging\FULL -Force
   .\Copy-SqlServerDatabasev2.ps1 -SourceInstance PFGSQLT4N06 -SourceDatabase SatsumaHDS  -TargetInstance PFGSQLT4N06 -BackupDirectoryPath {"\\HOSWAKBACKUP1\Redgate SQL Backups\PFGLBIPROCAG01\Satsuma_HDS"} -Force

   .\Copy-SqlServerDatabasev2.ps1 -SourceInstance PFGSQLT4N06 -SourceDatabase SatsumaApplication  -TargetInstance PFGSQLT4N06 -BackupDirectoryPath {"\\HOSWAKBACKUP1\Redgate SQL Backups\PFGLONBAG01\SatsumaApplication\"} -Force

 Powershell.exe c:\ps\Copy-SqlServerDatabasev2.ps1 -SourceInstance PFGSQLT4N06 -SourceDatabase test -TargetInstance PFGSQLT4N06 -BackupDirectoryPath \\hoswakbackup1\Redgate\pfglbiproc01\PFGLBIPROC01\test folder -Force
  

Powershell.exe -noexit "& 'c:\ps\Copy-SqlServerDatabasev2.ps1'" -SourceInstance "PFGSQLT4N06" -SourceDatabase "SatsumaHDS" -TargetInstance "PFGSQLT4N06" -BackupDirectoryPath ""\\HOSWAKBACKUP1\Redgate SQL Backups\PFGLBIPROCAG01\Satsuma_HD"" -Force -NonInteractive

Powershell.exe c:\ps\Copy-SqlServerDatabasev2.ps1 -SourceInstance PFGSQLT4N06 -SourceDatabase SatsumaHDS -TargetInstance PFGSQLT4N06 -BackupDirectoryPath "'\\HOSWAKBACKUP1\Redgate SQL Backups\PFGLBIPROCAG01\Satsuma_HDS'" -Force -NonInteractive


Powershell.exe c:\ps\Copy-SqlServerDatabasev2.ps1 -SourceInstance PFGSQLT4N06 -SourceDatabase SatsumaApplication  -TargetInstance PFGSQLT4N06 -BackupDirectoryPath "'\\HOSWAKBACKUP1\Redgate SQL Backups\PFGLONBAG01\SatsumaApplication'" -Force -NonInteractive


.EXAMPLE
   .\Copy-SqlServerDatabase.ps1 -SourceInstance Server1 -SourceDatabase AdventureWorks -TargetInstance Server2 -TargetDatabase AdventureWerkz -BackupDirectoryPath \\Server3\Backups -Force
 
.EXAMPLE
   .\Copy-SqlServerDatabase.ps1 -SourceInstance Server1 -SourceDatabase AdventureWorks -TargetInstance Server2 -TargetDatabase AdventureWerkz -BackupDirectoryPath \\Server3\Backups -Username sa -Password N0tBl@nk!
 
.EXAMPLE
   .\Copy-SqlServerDatabase.ps1 -SourceInstance Server1,3143 -SourceDatabase AdventureWorks -TargetInstance Server2,4133 -TargetDatabase AdventureWerkz -BackupDirectoryPath \\Server3\Backups
#>
[cmdletBinding(DefaultParametersetName='WindowsAuthentication')]
param(
    [Parameter(Mandatory=$true, ParameterSetName = 'WindowsAuthentication')]
    [Parameter(Mandatory=$true, ParameterSetName = 'SQLAuthentication')]
    [ValidateNotNullOrEmpty()]
    [alias('Source', 'Src')]
    [System.String]
    $SourceInstance
    ,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [alias('SourceDb', 'SrcDb', 'Database')]
    [System.String]
    $SourceDatabase
    ,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [alias('Target', 'Tgt')]
    [System.String]
    $TargetInstance
    ,
    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [alias('TargetDb', 'TgtDb', 'RenameAs')]
    [System.String]
    $TargetDatabase = $SourceDatabase
    ,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [alias('Path')]
    [System.String]
    $BackupDirectoryPath
    ,
    [Parameter(Mandatory=$true, ParameterSetName = 'SQLAuthentication')]
    [ValidateNotNull()]
    [System.String]
    $Username
    ,
    [Parameter(Mandatory=$true, ParameterSetName = 'SQLAuthentication')]
    [ValidateNotNull()]
    [System.String]
    $Password
    ,
    [Parameter(Mandatory=$false)]
    [Switch]
    $Force = $false
)
 
# Load SMO assembly, and if we're running SQL 2008 DLLs or higher load the SMOExtended and SQLWMIManagement libraries
# SMO Major Versions
# 9    :    SQL 2005
# 10:    SQL 2008 & 2008 R2 
# 11:    SQL 2012
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | ForEach-Object {
    $SmoMajorVersion = $_.GetName().Version.Major
    if ($SmoMajorVersion -ge 10) {
        [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMOExtended') | Out-Null
        [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SQLWMIManagement') | Out-Null
    }
}
 
 
######################
# CONSTANTS
######################
 
# SQL Versions
# See http://social.technet.microsoft.com/wiki/contents/articles/783.sql-server-versions.aspx for version timeline
# Also see http://support.microsoft.com/kb/321185
# Also see http://sqlserverbuilds.blogspot.com/
 
New-Object -TypeName System.Version -ArgumentList '8.0.0.0' | New-Variable -Name SQLServer2000 -Scope Script -Option Constant
New-Object -TypeName System.Version -ArgumentList '9.0.0.0' | New-Variable -Name SQLServer2005 -Scope Script -Option Constant
New-Object -TypeName System.Version -ArgumentList '10.0.0.0' | New-Variable -Name SQLServer2008 -Scope Script -Option Constant
New-Object -TypeName System.Version -ArgumentList '10.50.0.0' | New-Variable -Name SQLServer2008R2 -Scope Script -Option Constant
New-Object -TypeName System.Version -ArgumentList '11.0.0.0' | New-Variable -Name SQLServer2012 -Scope Script -Option Constant
 
 
######################
# FUNCTIONS
######################
 
function Get-SqlConnection {
    [CmdletBinding()]
    [OutputType([System.Data.SqlClient.SqlConnection])]
    param(
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Instance = '(local)'
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Database = 'master'
        ,
        [Parameter(Mandatory=$true, ParameterSetName = 'SQLAuthentication')]
        [ValidateNotNull()]
        [System.String]
        $Username
        ,
        [Parameter(Mandatory=$true, ParameterSetName = 'SQLAuthentication')]
        [ValidateNotNull()]
        [System.String]
        $Password
        ,
        [Parameter(Mandatory=$true, ParameterSetName = 'WindowsAuthentication')]
        [ValidateNotNull()]
        [alias('WindowsAuth','IntegratedAuth')]
        [switch]
        $WindowsAuthentication
        ,
        [Parameter(Mandatory=$false)]
        [System.String]
        $FailoverPartner = $null
        ,
        [Parameter(Mandatory=$false)]
        [System.String]
        $ApplicationName = 'Windows PowerShell' # $MyInvocation.ScriptName    
    )
    try {
 
        # ConnectionStringBuilder docs: http://msdn.microsoft.com/en-us/library/system.data.sqlclient.sqlconnectionstringbuilder.aspx
        # http://www.connectionstrings.com/Articles/Show/all-sql-server-connection-string-keywords
 
        $SQLConnection = New-Object -TypeName System.Data.SqlClient.SqlConnection
        $SQLConnectionBuilder = New-Object -TypeName system.Data.SqlClient.SqlConnectionStringBuilder
 	
        $SQLConnectionBuilder.psBase.DataSource = $Instance
        $SQLConnectionBuilder.psBase.InitialCatalog = $Database
 
        if ($PSCmdlet.ParameterSetName -eq 'SQLAuthentication') {
            $SQLConnectionBuilder.psBase.IntegratedSecurity = $false
            $SQLConnectionBuilder.psBase.UserID = $Username
            $SQLConnectionBuilder.psBase.Password = $Password
        } else {
            $SQLConnectionBuilder.psBase.IntegratedSecurity = $true
        }
 
        $SQLConnectionBuilder.psBase.FailoverPartner = $FailoverPartner
        $SQLConnectionBuilder.psBase.ApplicationName = $ApplicationName
 
        $SQLConnection.ConnectionString = $SQLConnectionBuilder.ConnectionString
 
        Write-Output $SQLConnection
 
    }
    catch {
        Throw
    }
}
 
######################
# VARIABLES
######################
$SourceConnection = $null
$SourceServer = $null
$TargetConnection = $null
$TargetServer = $null
$TargetDbExists = $false
$SaLogin = 'sa'
 
$FileDeviceType = [Microsoft.SqlServer.Management.Smo.DeviceType]::File
 
$TargetDataPath = [String]::Empty
$TargetLogPath = [String]::Empty
$PhysicalName = [String]::Empty
 
$Backup = $null
$Restore = $null
$RelocateFile = $null
 
 
######################
# BEGIN SCRIPT
######################
 
try {
 
    # Open a connection to the target server and check if the target database already exists
    if ($PSCmdlet.ParameterSetName -eq 'SQLAuthentication') {
        $TargetConnection = Get-SqlConnection -Instance $TargetInstance -Username $Username -Password $Password
    } else {
        $TargetConnection = Get-SqlConnection -Instance $TargetInstance -WindowsAuthentication
    }
    $TargetServer = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $TargetConnection
    $TargetServer.ConnectionContext.Connect()
    $TargetServer.ConnectionContext.StatementTimeout = 0 
 
    $TargetServer.Databases | Where-Object { $_.Name -ieq $TargetDatabase } | ForEach-Object {
        $TargetDbExists = $true
    }
 
    # If the target database already exists and -Force was not specified throw an error
    if ($TargetDbExists -and -not $Force) {
        throw "Database '$TargetDatabase' exists on target instance $TargetInstance; Rerun script and specify -Force to overwrite the existing database"
    }
 
 <#
    # Open a connection to the source server and kick off a full, copy-only backup to the backup path
    if ($PSCmdlet.ParameterSetName -eq 'SQLAuthentication') {
        $SourceConnection = Get-SqlConnection -Instance $SourceInstance -Username $Username -Password $Password
    } else {
        $SourceConnection = Get-SqlConnection -Instance $SourceInstance -WindowsAuthentication
    }
    $SourceServer = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $SourceConnection
    $SourceServer.ConnectionContext.Connect()
    $SourceServer.ConnectionContext.StatementTimeout = 0 
 
    # Setup the backup
    $Backup = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Backup
    $Backup.Action = 'Database'
    $Backup.BackupSetName = "$SourceDatabase FULL Backup"
    $Backup.BackupSetDescription = 'FULL backup of $SourceDatabase for RemitPlus upgrade'
    $Backup.Database = $SourceDatabase
    $Backup.Incremental = $false
 
    # COPYONLY supported by SQL 2005+ and SMO 2008
    if ((($SourceServer.Information.Version).CompareTo($SQLServer2005) -ge 0) -and ($SmoMajorVersion -ge 10)) {
        $Backup.CopyOnly = $true
    }
 
    # Compression supported by:
    #    - SQL 2008 enterprise edition
    #     - SQL 2008 R2 standard edition and higher
    if (
        $( $SourceServer.Information.Version).CompareTo($SQLServer2008R2) -ge 0 -or
        (
            $( $SourceServer.Information.Version).CompareTo($SQLServer2008) -ge 0 -and
            $SourceServer.Information.Edition -ilike '*enterprise*'
        )
    )
    {
        $Backup.CompressionOption = 'on'
    }
 
    # Build backup filename
    # Note: I'm not accounting for invalid characters here. I'm assuming this won't be an issue for this iteration!
    #$BackupFileName = [String]::Join('_', @($SourceServer.Name.Replace('\','_'), $SourceDatabase, 'FULL', [System.DateTime]::Now.ToString('yyyy_MM_dd_HH_mm')))
    $BackupFileName = get-childitem -path $BackupDirectoryPath -Filter "*.bak" | where-object { -not $_.PSIsContainer } | sort-object -Property $_.CreationTime | select-object name -last 1

    $BackupFileName = [System.IO.Path]::ChangeExtension($BackupFileName, 'bak')
    $BackupPath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($BackupDirectoryPath, $BackupFileName))
 
    $BackupDevice = New-Object -TypeName Microsoft.SqlServer.Management.Smo.BackupDeviceItem -ArgumentList $BackupPath, $FileDeviceType
    $Backup.Devices.Add($BackupDevice)
 
    # Do the backup
    $Backup.SqlBackup($SourceServer)
 
    # Cleanup
    $Backup.Devices.Remove($BackupDevice) | Out-Null
    $Backup = $null
    $SourceServer.ConnectionContext.Disconnect()
 
 #>

 
    # Get the path to the data and log file directories on the target server
 
    # Get the default data and log file path on the target server
    $TargetDataPath = if (($TargetServer.Settings.DefaultFile).Length -gt 0) { $TargetServer.Settings.DefaultFile } else { $TargetServer.Information.MasterDBPath }
    $TargetLogPath = if (($TargetServer.Settings.DefaultLog).Length -gt 0) { $TargetServer.Settings.DefaultLog } else { $TargetServer.Information.MasterDBPath }
 

  #Get the latest backup file

    $BackupFileName = get-childitem -path $BackupDirectoryPath -Filter "*.bak" | where-object { -not $_.PSIsContainer } | sort-object -Property $_.CreationTime | select-object name -last 1
echo $BackupFileName 
echo $BackupDirectoryPath
	 
	$BackupFileName= $BackupFileName.name
	
	echo $BackupFileName 

    	#$BackupPath = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($BackupDirectoryPath, $BackupFileName))
	$BackupPath = $BackupDirectoryPath +"\"+ $BackupFileName
echo $BackupPath 
 
    $BackupDevice = New-Object -TypeName Microsoft.SqlServer.Management.Smo.BackupDeviceItem -ArgumentList $BackupPath, $FileDeviceType

 
    # Setup the restore
    $Restore = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Restore
    $Restore.Action = 'Database'
    $Restore.Database = $TargetDatabase
    $Restore.ReplaceDatabase = $true;
    $Restore.NoRecovery = $false
    $Restore.Devices.Add($BackupDevice)
 
    # Iterate through files in backup and set up a new physical path for each
    $Restore.ReadFileList($TargetServer).Rows | ForEach-Object {
        $RelocateFile = New-Object -TypeName Microsoft.SqlServer.Management.Smo.RelocateFile
        $RelocateFile.LogicalFileName = $_.LogicalName
 
        $PhysicalName = [System.IO.Path]::GetFileName($_.PhysicalName)
        #$PhysicalName = [System.IO.Path]::GetFileNameWithoutExtension($_.PhysicalName) + '_TEST' + [System.IO.Path]::GetExtension($_.PhysicalName)
 
        # Set new physical path depending on file type
        if ($_.Type -ieq 'L') {
            $RelocateFile.PhysicalFileName = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($TargetLogPath, $PhysicalName))
        } else {
            $RelocateFile.PhysicalFileName = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($TargetDataPath, $PhysicalName))
        }
 
        $Restore.RelocateFiles.Add($RelocateFile) | Out-Null
    }
 
    # Do the restore
    $Restore.SqlRestore($TargetServer)
 
    # Cleanup
    $Restore.Devices.Remove($BackupDevice) | Out-Null
    $Restore = $null
 
 
    # Get the SA login for the target instance (fallback is 'sa')
    $TargetServer.Logins | Where-Object { [System.BitConverter]::ToString($_.Sid) -eq [System.BitConverter]::ToString(0x01) } | ForEach-Object { $SaLogin = $_.Name }
 
    # Have SMO update the list of databases
    $TargetServer.Databases.Refresh()
 
    # Change DB Owner to SA and compatibility level to match target server's model DB compatibility level
    $TargetServer.Databases.Item($TargetDatabase) | ForEach-Object {
        $_.SetOwner($SaLogin)
        $_.CompatibilityLevel = $TargetServer.Databases['model'].CompatibilityLevel
        $_.Alter()
    }
 
    $TargetServer.ConnectionContext.Disconnect()
}
catch {
    # Get the lowest level error and throw it
    $ThisException = $_.Exception
    while ($ThisException.InnerException) {
        $ThisException = $ThisException.InnerException
    }
    throw $ThisException
}
finally {
    # Close any open connections
    If ($TargetServer.ConnectionContext.IsOpen) { $TargetServer.ConnectionContext.Disconnect() } 
    If ($SourceServer.ConnectionContext.IsOpen) { $SourceServer.ConnectionContext.Disconnect() } 
}
 
Remove-Variable -Name SourceConnection, SourceServer, TargetConnection, TargetServer, FileDeviceType, BackupFileName, `
BackupPath, TargetDataPath, TargetLogPath, Backup, Restore, RelocateFile, PhysicalName, SmoMajorVersion, TargetDbExists, SaLogin