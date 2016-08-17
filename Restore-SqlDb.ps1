begin {
	function get-usage {
@"
	NAME
		Restore-SqlDb
	
	SYNOPSIS
		Allows simplifying the automation of SQL Server database restorations from the 2 primary
		backup sources (msdb, file-system) and supports a variety of options (see detailed description
		for more details).
	
	SYNTAX
		Restore-SqlDb [-dbName] <string> [[-fromInstance] <string>] [[-paths] <string[]>]
			[[-toInstance] <string>] [[-moveLogsTo] <string>] [[-moveDataTo] <string[]>]
			[[-newDbName] <string>] [[-files] <string[]>] [[-fileGroups] <string[]>]
			[[-stopAt] <datetime>] [[-batchSeparator] <string>] [[-recover] <switch>]
			[[-liteSpeed] <switch>] [[-closeExisting] <switch>] [[-noDiffs] <switch>]
			[[-noLogs] <switch>] [[-checksum] <switch>] [[-pageRestore] <switch>]
			[[-timeStampInFileNames] <switch>] [[-noScriptOutput] <switch>]
			[[-execute] <switch>]
	
	DETAILED DESCRIPTION
		Allows simplifying the automation of SQL Server database restorations from the 2 primary
		backup sources (msdb, file-system) and supports a variety of options. Handles determination
		of files within a media set/family, inclusion/exclusion of backup types, file/filegroup
		restoration, automatic page restore based on suspect pages within msdb.dbo.suspect_pages,
		moving of log/data files to new location(s), etc.
		
		See the following blog entry for details:
		
	
	PARAMETERS
		-dbName <string>
			Name of the database to restore - can be specified via parameter or pulled from
			pipeline if castable to a string or Smo.Database object.
	
			Required?		True
			Position?		1
			Default value		<required>
			Accept pipeline?	True
			Accept wildcards?	False
	
		-fromInstance <string>
			Name of the SQL Server instance to restore from (or also pull meta-data from msdb for)
	
			Required?		False
			Position?		2
			Default value		(local)
			Accept pipeline?	False
			Accept wildcards?	False

		-paths <string[]>
			Paths to find backups in for restoring - supports wildcards. If not specified, restore
			data is pulled from msdb in the -fromInstance.
	
			Required?		False
			Position?		3
			Default value		
			Accept pipeline?	False
			Accept wildcards?	True

		-toInstance <string>
			Name of the SQL Server instance to restore to. Will default to the -fromInstance if
			not specified - only used if the -execute flag is specified.
	
			Required?		False
			Position?		4
			Default value		-fromInstance
			Accept pipeline?	False
			Accept wildcards?	False

		-moveLogsTo <string>
			Location to move log file(s) to during the restore.
	
			Required?		False
			Position?		5
			Default value		
			Accept pipeline?	False
			Accept wildcards?	False

		-moveDataTo <string[]>
			Location(s) to move data file(s) to during the restore. Doesn't need to match the number
			of data files in the database being restored - if number of locations specified doesn't 
			match the number of data files in the database, the data files in the database will be
			round-robin matched to the values specified here until all data files have a location.
	
			Required?		False
			Position?		6
			Default value		
			Accept pipeline?	False
			Accept wildcards?	False

		-newDbName <string>
			Name to restore the database as. Defaults to -dbName value if not specified.
	
			Required?		False
			Position?		7
			Default value		-dbName
			Accept pipeline?	False
			Accept wildcards?	False

		-files <string[]>
			Logical name(s) of the file(s) in the database to be restored.
	
			Required?		False
			Position?		8
			Default value		
			Accept pipeline?	False
			Accept wildcards?	False

		-fileGroups <string[]>
			Logical name(s) of the file(s) in the database to be restored.
	
			Required?		False
			Position?		9
			Default value		
			Accept pipeline?	False
			Accept wildcards?	False

		-stopAt <datetime>
			Mimics the STOPAT clause of the restore statement.
	
			Required?		False
			Position?		10
			Default value		System.DateTime::MaxValue
			Accept pipeline?	False
			Accept wildcards?	False

		-batchSeparator <string>
			String used to separate restore statements in the restore script generated as output.
			Only valid if the -noScriptOutput switch isn't specified. If you'd like to have a
			script with no separators, specify an empty string here.
	
			Required?		False
			Position?		11
			Default value		GO
			Accept pipeline?	False
			Accept wildcards?	False

		-recover <switch>
			If specified, the database will be recovered at the end of the restore. By default, 
			the database will be left in a recovering state.
	
			Required?		False
			Position?		12
			Default value		
			Accept pipeline?	False
			Accept wildcards?	False

		-liteSpeed <switch>
			If specified, liteSpeed syntax is used
	
			Required?		False
			Position?		13
			Default value		
			Accept pipeline?	False
			Accept wildcards?	False

		-closeExisting <switch)
			If specified, existing connections to the database will be closed forcefully prior
			to the restore.
	
			Required?		False
			Position?		14
			Default value		
			Accept pipeline?	False
			Accept wildcards?	False

		-noDiffs <switch)
			If specified, differential backups will not be used in the restore.
	
			Required?		False
			Position?		15
			Default value		
			Accept pipeline?	False
			Accept wildcards?	False

		-noLogs <switch)
			If specified, log backups will not be used in the restore
	
			Required?		False
			Position?		16
			Default value		
			Accept pipeline?	False
			Accept wildcards?	False

		-checksum <switch)
			If specified, the CHECKSUM option will be specified in the restore
	
			Required?		False
			Position?		17
			Default value		
			Accept pipeline?	False
			Accept wildcards?	False

		-pageRestore <switch)
			If specified, the restore will automatically include a PAGE clause
			that is built from the contents of the msdb.dbo.suspect_pages table
			in the -fromInstance
	
			Required?		False
			Position?		18
			Default value		
			Accept pipeline?	False
			Accept wildcards?	False

		-timeStampInFileNames <switch)
			If specified, the sorting and grouping of the files in the -paths 
			specified (not used if -paths is not specified) is based on a 
			timestamp value that is pulled from the filenames within the 
			backup files in the -paths specified. Using this option in conjunction
			with the -paths option will ensure that we do not need to connect
			to a SQL instance to generate a script as long as the -moveLogsTo
			and -moveDataTo options aren't used - the script can be built without
			having to connect to an instance.
	
			Required?		False
			Position?		19
			Default value		
			Accept pipeline?	False
			Accept wildcards?	False

		-noScriptOutput <switch>
			If specified, the script will not output the restore statements that
			are by default output to the pipeline.
	
			Required?		False
			Position?		20
			Default value		
			Accept pipeline?	False
			Accept wildcards?	False

		-execute <switch>
			If specified, the restore will actually be executed automatically at
			the -toInstance SQL Server instance.
	
			Required?		False
			Position?		21
			Default value		
			Accept pipeline?	False
			Accept wildcards?	False
		
	RETURN TYPE
		Array of strings - each item in the array is a single statement to be executed in 
		the order output to perform the successful restore, including all specified options.
	
	NOTES
		-------------------------- EXAMPLE 1 --------------------------
		Restore 'testDb' from msdb meta-data in the ltcboydxps\sql2008a instance
		to the same instance.
		
			Restore-SqlDb -dbName 'testDb' -from 'ltcboydxps\sql2008a' 
			
		-------------------------- EXAMPLE 2 --------------------------
		Restore 'testDb' from the backups in 'f:\backups\adventure*.bak' and 'e:\backups\adventure*.bak'
		that start with 'adventure' and have the '.bak' extension, moving log files to 'd:\logs' and
		data files to 4 locations: h:\data1, i:\data2, j:\data3, k:\data4
		
			Restore-SqlDb -dbName 'testDb' -from 'ltcboydxps\sql2008a'
				-paths 'f:\backups\adventure*.bak','e:\backups\adventure*.bak'
				-moveLogsTo 'd:\logs' 
				-moveDataTo 'h:\data1','i:\data2','j:\data3','k:\data4'



"@
	} # get-usage
	if 	(($MyInvocation.InvocationName -ne '.' -and $MyInvocation.InvocationName -ne '&') -and 
		($Args[0] -eq "-?" -or $Args[0] -eq "/?" -or $Args[0] -eq "-help" -or $Args[0] -eq "/help")) {
			$showUsage = $true;
			&get-usage;
			return;
	}
	if ($MyInvocation.InvocationName -ne '.') { Write-Debug "Restore-SqlDb::BEGIN"; }
	$InPipeline = $false;

	# import error handling fuqnctions...
	. Invoke-Nz.ps1
	. Invoke-TryCatch.ps1
	& {
		$local:ErrorActionPreference = "SilentlyContinue"
		Get-PSSnapin -registered -name "SqlServer*" | %{ Add-PSSnapin -name "$($_.Name)"; }
	}

	function get-restoreFileListSql {
		@"
declare	@i int, @n int, @dbName nvarchar(255), @stopAt datetime, 
		@noDiffs nvarchar(5), @noLogs nvarchar(5);
select	@dbName = '$dbName',
		@stopAt = '$stopAt',
		@noDiffs = '$noDiffs',
		@noLogs = '$noLogs';
		
-- Get the most recent full backup for this database
select	top 1 @i = backup_set_id
from	msdb.dbo.backupset
where	database_name = @dbName
and		type = 'D'
and		is_snapshot = 0
and		is_copy_only = 0
and		backup_finish_date is not null
and		backup_start_date <= @stopAt
order by backup_finish_date desc, backup_set_id desc;

-- Most recent differential
select	top 1 @n = backup_set_id
from	msdb.dbo.backupset
where	database_name = @dbName
and		type = 'I'
and		is_snapshot = 0
and		is_copy_only = 0
and		backup_finish_date is not null
and		backup_set_id > @i
order by backup_finish_date desc, backup_set_id desc;

if ((lower(@noDiffs) = 'true') or (coalesce(@n,-1) < @i))
	select @n = @i;

-- Get the list of files to restore from
with backupPathList (backupId, position, singleDevice, backupType, fileNumber, backupEndDate) as (
	select	b.backup_set_id, f.family_sequence_number as position,
			coalesce(f.physical_device_name,f.logical_device_name) as singleDevice,
			b.type as backupType, b.position as fileNumber, backup_finish_date as backupEndDate
	from	msdb.dbo.backupset b with(nolock)
	join	msdb.dbo.backupmediafamily f with(nolock)
	on		b.media_set_id = f.media_set_id
	where	b.database_name = @dbName
	and		b.is_snapshot = 0
	and		b.is_copy_only = 0
	and		b.backup_finish_date is not null
	and		coalesce(f.mirror, 0) <= 0
)
select	@dbName as dbName,
		singleDevice as pathAndFileName, 
		right(singleDevice, charindex('\',reverse(singleDevice),1) - 1) as fileName, 
		fileNumber as fileNumber,
		right('000000000000' + cast(backupId as varchar(10)), 10) as sortVal, 
		cast(backupId as varchar(10)) as groupVal, 
		backupEndDate as backupEndDate, 
		case backupType
			when 'D' then 1
			when 'L' then 2
			when 'I' then 5
			else null
		end as backupType
from	backupPathList
where	((backupId = @i)
		or (backupId >= @n))
and		(
		( (lower(@noDiffs) = 'true') and (backupType <> 'I'))
		or
		(lower(@noDiffs) <> 'true')
		)
and		(
		( (lower(@noLogs) = 'true') and (backupType <> 'L'))
		or
		(lower(@noLogs) <> 'true')
		)		
order by backupId;
"@
	} # get-restoreFileListSql
	function get-suspectPages {
		@"
declare	@dbName nvarchar(255);
select	@dbName = '$dbName';

with distinct_pages as (
	select	distinct file_id as fileId, page_id as pageId
	from	msdb.dbo.suspect_pages p
	where	p.database_id = db_id(@dbName)
	and		p.event_type not in(4,5,7)
)	
select	cast(fileId as varchar(10)) + ':' + cast(pageId as varchar(25)) as suspectPage
from	distinct_pages;
"@
	} # get-suspectPages
	
	function Restore-SqlDb {
		param (
			[string] $dbName = $null,
			[string] $fromInstance = $null,
			[string[]] $paths = $null,
			[string] $toInstance = $null,
			[string] $moveLogsTo = $null,
			[string[]] $moveDataTo = $null,
			[string] $newDbName = $null,
			[string[]] $files = $null,
			[string[]] $fileGroups = $null,			
			[datetime] $stopAt = [System.DateTime]::MaxValue,
			[string] $batchSeparator = "GO",
			[switch] $recover,
			[switch] $liteSpeed,
			[switch] $closeExisting,
			[switch] $noDiffs,
			[switch] $noLogs,
			[switch] $checksum,
			[switch] $pageRestore,
			[switch] $timeStampInFileNames,
			[switch] $noScriptOutput,
			[switch] $execute
		)
		begin {
			# Output some data if we are verbose...
			if ($VerbosePreference -ne "SilentlyContinue") {
				&{
					$writeVerboseList = @{
						'$dbName' = $dbName;
						'$fromInstance' = $fromInstance;
						'$paths' = $paths;
						'$toInstance' = $toInstance;
						'$moveLogsTo' = $moveLogsTo;
						'$moveDataTo' = $moveDataTo;
						'$newDbName' = $newDbName;
						'$files' = $files;
						'$fileGroups' = $fileGroups;
						'$stopAt' = $stopAt;
						'$recover' = $recover;
						'$liteSpeed' = $liteSpeed;
						'$closeExisting' = $closeExisting;
						'$noDiffs' = $noDiffs;
						'$checksum' = $checksum;
						'$pageRestore' = $pageRestore;
						'$timeStampInFileNames' = $timeStampInFileNames;
						'$whatIf' = $whatIf;
						'$quiet' = $quiet;
					} | format-list | Out-String;
					$writeVerboseString = @"
 
Parameter List:
-------------------------------------------------$writeVerboseList-------------------------------------------------
"@;
					Write-Verbose $writeVerboseString;
				} # Verbose write of input data...
			} # if ($VerbosePreference -ne "SilentlyContinue")

			$backupFileCharSeparators, $sqlConnectTimeout = '-_$.~!', 5;
		} # Restore-SqlDb begin
		process {
			if (($_) -or ($_ -eq 0)) {
				$InPipeline = $true;
			}
			# No processing if we are dot-sourced or if we were just asked for a little help...
			if ($showUsage -or $MyInvocation.InvocationName -eq '.') {
				return;
			}

			# If we don't have a $dbName value, figure it out now
			if (-not $dbName) {

				if ($_) {
					# Try setting/casting the input object to SMO DB object - if it works, we'll use the pipeline
					# object as the db to restore
					trap {
						Write-Debug "Restore-SqlDb::Could not convert pipeline object to dbName value [$_]."
						continue;
					}
					# Try to get the db name

					if ($_ -is [Microsoft.SqlServer.Management.Smo.Database]) {
						$dbName = "$($_.Name)"
					} 
					if (-not $dbName) {
						$dbName = "$_"
					}
				}
				if (-not $dbName) { 
					write-error $("Missing parameter {0} - please specify a valid database name to be restored for the {0} parameter." -f '$dbName');
					return;
				}
			} # if (-not $dbName) {

			# Format parameters...
			$fromInstance = nz $fromInstance "(local)";
			$toInstance = nz $toInstance $fromInstance;
			$newDbName = nz $newDbName $dbName;
			$sqlExec, $fileList, $restoreSql = $null, $null, @();
			
			# Get the files to be restored - if weren't given restorePaths, we go to the msdb on the restoreFrom system
			# If we have restorePaths, we go to the file system instead
			if (-not $paths) {
				trap {
					Write-Error $_;
					Write-Error -message "::Invoke-Sqlcmd params:: ServerInstance:[$fromInstance] Database:[msdb] ConnectionTimeout:[$sqlConnectTimeout]";
				}
				# Get file list for restoring from the msdb of the $fromInstance msdb...
				$fileList = Invoke-Sqlcmd -ServerInstance $fromInstance -Database "msdb" -ConnectionTimeout $sqlConnectTimeout -Query (get-restoreFileListSql)

			} else {
				# Using the filesystem, reset the $paths to only valid locations and append appropriate
				# wildcards to containers for listing contents
				$paths = $paths | where{(Test-Path $_)} | % { if (Test-Path $_ -pathType "container") { Join-Path $_ * } else { $_ } }

				# Get the file list
				$fileList = $paths | Resolve-Path | where{ (Test-Path $_ -pathType "leaf") }

				# Resolve appropriate ordering, grouping, etc.
				if ($timeStampInFileNames) {
					# Get the files that have a timestamp matching a pattern we support, for all those found break out data into a hash
						# The timestamp formats we support can follow patterns like the following (not a complete list):
						#	yyyy_mm_dd_hhmm_ss
						#	yy_mm_dd_hh_mm_ss
						#	yyyymmddhhmmss
						#	yymmddhhmmss
						#	yyyy_mm_dd_hhmmss
						#	yy_mm_dd_hhmmss
					$fileList = $fileList | where {
							$_ -match "^.*?(?<timeStamp>[$backupFileCharSeparators]{0,2}[0-9]{2,4}[$backupFileCharSeparators]{0,1}[0-9]{2}[$backupFileCharSeparators]{0,1}[0-9]{2}[$backupFileCharSeparators]{0,1}[0-9]{2}[$backupFileCharSeparators]{0,1}[0-9]{2}[$backupFileCharSeparators]{0,1}[0-9]{2}[$backupFileCharSeparators]{0,1}).*$"
						} | select @(
							@{name="dbName"; expression={$dbName}},
							@{name="pathAndFileName"; expression={$_}},
							@{name="fileName"; expression={(Split-Path $_ -leaf)}},
							@{name="sortVal"; expression={(($($matches.timeStamp -replace "[$backupFileCharSeparators]","").PadLeft(20,"0")) + (Split-Path $_ -leaf))}},
							@{name="groupVal"; expression={($($matches.timeStamp -replace "[$backupFileCharSeparators]","").PadLeft(20,"0"))}},
							@{name="fileNumber"; expression={"1"}},
							@{name="backupEndDate"; expression={$($matches.timeStamp)}},
							@{name="backupType"; expression={
								switch -r (Split-Path $_ -leaf) {
									"^diff[$backupFileCharSeparators].*$" { "5"; break }
									"^.*\.dif$" { "5"; break }
									"^.*[$backupFileCharSeparators]diff{0,1}[$backupFileCharSeparators].*$" { "5"; break }
									"^diff{0,1}\..*$" { "5"; break }
									"^full[$backupFileCharSeparators].*$" { "1"; break }
									"^.*\.ful$" { "1"; break }
									"^.*[$backupFileCharSeparators]full{0,1}[$backupFileCharSeparators].*$" { "1"; break }
									"^full{0,1}\..*$" { "1"; break }
									"^log[$backupFileCharSeparators].*$" { "2"; break }
									"^.*\.log$" { "2"; break }
									"^.*[$backupFileCharSeparators]log[$backupFileCharSeparators].*$" { "2"; break }
									"^log\..*$" { "2"; break }
									"^tra{0,1}n[$backupFileCharSeparators].*$" { "2"; break }
									"^.*\.tra{0,1}n$" { "2"; break }
									"^.*[$backupFileCharSeparators]tra{0,1}n[$backupFileCharSeparators].*$" { "2"; break }
									"^tra{0,1}n\..*$" { "2"; break }
									default { "1"; break }
								}
							}
						} # @{name="backupType"; expression={
					)	# $fileList = $fileList | where {

				} else {
					# Not pulling from a timestamp stored in the filename, so we have to drop into each file
					# and perform a headeronly restore to determine the backup types, sort order, etc.

					# Pull the file list from each backup file
					trap {
						Write-Error $_;
						Write-Error -message "::Invoke-Sqlcmd params:: ServerInstance:[$toInstance] Database:[master] ConnectionTimeout:[$sqlConnectTimeout]";
					}
					$fileList = $fileList | % {
						$filePathAndName = "$_";
						if ($liteSpeed) {
							$sqlExec = "exec master.dbo.xp_restore_headeronly @filename = `'$_`';" 
						} else { 
							$sqlExec = "restore headeronly from disk = `'$_`';" 
						}
						Invoke-Sqlcmd -ServerInstance $toInstance -Database "master" -ConnectionTimeout $sqlConnectTimeout -Query "$sqlExec" | select @(
								@{name="dbName"; expression={"$($_.DatabaseName)"}},
								@{name="pathAndFileName"; expression={"$filePathAndName"}},
								@{name="fileName"; expression={(Split-Path $filePathAndName -leaf)}},
								@{name="fileNumber"; expression={"$($_.Position)"}},
								@{name="sortVal"; expression={"$(($_.DatabaseBackupLSN.ToString()).PadLeft(25,'0'))_$((([datetime]$_.BackupFinishDate).ToFileTime().ToString()).PadLeft(25,'0'))_$($_.Position)"}},
								@{name="groupVal"; expression={"$($_.BackupSetGUID)"}},
								@{name="backupType"; expression={"$($_.BackupType)"}},
								@{name="backupEndDate"; expression={"$($_.BackupFinishDate)"}}
						) | where { $_.dbName -eq $dbName }
					} # $fileList = $fileList | % {

					if (-not $?) { $fileList = $null; }

				} # if ($timeStampInFileNames)

			} # if (-not $paths)

			# If we were given a stopAt value, pull everything but the required files (we'll pull 2 past the
			# first backup that marks the stopAt, just to be safe)
			if (($stopAt) -and ($stopAt -lt [System.DateTime]::MaxValue)) {
				$fileList = $fileList | Sort-Object -property 'sortVal' | % {
					if ($_.backupEndDate -le $stopAt) {
						$_;
					} else { 
						if ($stopAtCounter -le 2) { $stopAtCounter++; $_; } 
					}
				}	# $fileList = $fileList | Sort-Object -property 'sortVal' | %
			}	# if (($stopAt) -and ($stopAt -lt [System.DateTime]::MaxValue)) {

			if ($paths) {
				# Get rid of everything before the most recent full backup (that's our 'base' restore file(s))
				# and remove all differential backups if flagged to do so
				$fileList = $fileList | Sort-Object -property 'sortVal' -descending | % {
					# Determine the backup type and continue passing down the pipe or discard appropriately
					switch ($_) {
						{$_.backupType -eq '1'} {
						# If this is the first full backup we've hit, or a media member for the same backup, pass it down the pipe
							if ($_.sortVal -eq (nz $iteratorFullSortVal $_.sortVal)) { 
								$iteratorFullSortVal = $_.sortVal;
								$_;
							}
							break;
						}
						{$iteratorFullSortVal} {
							# We've reached back to our starting base backup, ignore the rest...
							break;
						}
						{($_.backupType -eq '5')} {
							# If we aren't processing diffs, break now...
							if ($noDiffs) { break; }

							# If this is the first diff backup we've hit, or a media member for the same backup, pass it down the pipe
							if ($_.sortVal -eq (nz $iteratorDiffSortVal $_.sortVal)) { 
								$iteratorDiffSortVal = $_.sortVal;
								$_;
							}
							break;
						}
						{$iteratorDiffSortVal} {
							# We are processing diffs and we've reached back to our most recent diff backup, so ignore everything else...
							break;
						}
						{$_.backupType -eq '2'} {
							if ($noLogs) { break; } else { $_; }
						}
						default {
							$_;
						}
					} # switch ($_.backupType)
				} # 	$fileList = $fileList | Sort-Object -property 'sortVal' -descending | % {
			
			}	# if ($paths)
			
			# Be sure at this point that we have something to restore...
			if (-not $fileList) { Write-Error $("No restore data was found for database [{0}] on server [{1}] in path(s) specified [{2}]. Please correct and try again." -f $dbName, $fromInstance, (nz $paths "msdb")); return; }

			# If flagged to perform a page restore based on suspect_page data, get it now
			if ( ($pageRestore) -and (-not $liteSpeed) ) {
				trap {
					Write-Error $_;
					Write-Error -message "::Invoke-Sqlcmd params:: ServerInstance:[$fromInstance] Database:[msdb] ConnectionTimeout:[$sqlConnectTimeout]";
				}
				$pageRestoreSql = Invoke-Sqlcmd -ServerInstance $fromInstance -Database "msdb" -ConnectionTimeout $sqlConnectTimeout -Query (get-suspectPages) | %{ "$($_.suspectPage)" }
				if (-not $pageRestoreSql) { Write-Error $("No page restore data was found for database [{0}] on server [{1}] within the msdb.dbo.suspect_pages table." -f $dbName, $fromInstance); return; }
				$OFS = ",";
				$pageRestoreSql = "page = `'$pageRestoreSql`'"
				$OFS = " ";
			} # if ($pageRestore)

			# NOTE:	The following few operations could most certainly be embedded together or even within each pass through the
			#		fileList data within each fork above, leading to better performance and only a single-pass through the hash.
			#		However, doing so would mean duplicating the logic in each fork above, and also lead to much more complex
			#		pipeline processing (think Perl...) - given that these fileList collections will likely be small relatively
			#		speaking, and squeezing every inch of performace out of this script isn't by any means a priority (if this
			#		runs in 15 seconds vs. 10 seconds, it really isn't going to make a heck of a lot of difference in the total
			#		recovery time of your database, since the actual restore process will take significantly longer). Therefore,
			#		I'm opting for simplicity and readability in this particular operation, not the utmost performance....
			
			# We've got our file list - if we are flagged to move log/data files around, figure out the mapping for that now
			if (($moveLogsTo) -or ($moveDataTo)) {
				# Get the list of files included with the db - simply need to run a filelistonly restore from any of the files to get the data
				$localCnt = 0;
				$dbFileList = $fileList | select -first 1 | % {
						if ($liteSpeed) {
							$sqlExec = "exec master.dbo.xp_restore_filelistonly @filename = `'$($_.pathAndFileName)`';" 
						} else { 
							$sqlExec = "restore filelistonly from disk = `'$($_.pathAndFileName)`';" 
							#$sqlExec = "select 'Ad1' as LogicalName union all select 'Ad2' union all select 'Ad3' union all select 'Ad4'" 
						}
						Invoke-Sqlcmd -ServerInstance $toInstance -Database "master" -ConnectionTimeout $sqlConnectTimeout -Query "$sqlExec" 
					} | % {
						$localCnt ++ ;
						$_ | select @(
							@{name="LogicalName"; expression={ $_.LogicalName }},
							@{name="FileId"; expression={ nz $_.FileId $localCnt; }},
							@{name="Type"; expression={ $_.Type }}
						)
					} # $dbFileList = $fileList | select -first 1 | % {

				# Format the log move portion of the SQL statement
				if ($moveLogsTo) {
					$localCnt = 0;
					$moveLogsSql = $dbFileList | where { $_.Type -eq 'L' } | % {
						$localCnt ++ ;
						if ($liteSpeed) {
							"@with = 'move `"$($_.LogicalName)`" to `"$(Join-Path $moveLogsTo $newDbName)$localCnt.ldf`"'"
						} else {
							"move '$($_.LogicalName)' to '$(Join-Path $moveLogsTo $newDbName)$localCnt.ldf'"
						}
					} #	$moveLogsSql = $dbFileList | where { $_.Type -eq 'L' } | % {
				}	# if ($moveLogsTo)

				# Format the data move portion of the SQL statement
				if ($moveDataTo) {
					$localCnt, $moveDataCnt = 0, $moveDataTo.Count;
					$moveDataSql = $dbFileList | Sort-Object -property FileId | where { $_.Type -eq 'D' } | % {
						$localCnt ++ ;
						if ($liteSpeed) {
							"@with = 'move `"$($_.LogicalName)`" to `"$(Join-Path $moveDataTo[(($localCnt - 1) % $moveDataCnt)] $newDbName)$localCnt.$(if ($localCnt -eq 1) {`"mdf`"} else {`"ndf`"})`"'"
						} else {
							"move '$($_.LogicalName)' to '$(Join-Path $moveDataTo[(($localCnt - 1) % $moveDataCnt)] $newDbName)$localCnt.$(if ($localCnt -eq 1) {`"mdf`"} else {`"ndf`"})'"
						}
					} # $moveDataSql = $dbFileList | Sort-Object -property FileId | where { $_.Type -eq 'D' } | % {
				}	# if ($moveDataTo)
				
			} # if (($moveLogsTo) -or ($moveDataTo))

			# Prepend the file/filegroup specifier to each passed value
			if ($files) { $files = $files | %{ "$(if ($liteSpeed) {'@'})file = `'$(if ($_ -eq 'primary') {'PRIMARY'} else {$_})`'"; }; }
			if ($fileGroups) { $fileGroups = $fileGroups | %{ "$(if ($liteSpeed) {'@'})filegroup = `'$(if ($_ -eq 'primary') {'PRIMARY'} else {$_})`'"; }; }

			# Time to build the sql statement
			$restoreSql += "use master;";
			if ($closeExisting) { $restoreSql += "if db_id('$newDbName') > 0 `n`talter database $newDbName set single_user with rollback immediate;" }

			# Build the actual restore statements, different syntax for liteSpeed vs. native
			$OFS = ",`n`t";
			if ($liteSpeed) {
				$restoreSql += $fileList | Sort-Object -property 'sortVal' | Group-Object -property 'groupVal' | % { 
@"
exec master.dbo.$(if ($($_.Group[0].backupType) -eq '2') {'xp_restore_log'} else {'xp_restore_database'} )
	@database = '$newDbName',
	$( foreach ($file in $_.Group) { "`@filename = '$($file.pathAndFileName)'" } ),
	@logging = 0, @filenumber = $($_.Group[0].fileNumber),
	@with = 'norecovery'$(if ($stopAt -ne [System.DateTime]::MaxValue) {", @with = 'stopat = `'`'$stopAt`'`''"}), @with = 'replace'$(if ($moveLogsSql) {",
	$moveLogsSql"})$(if ($moveDataSql) {",
	$moveDataSql"})$(if ( ($files) -and ($_.Group[0].backupType -ne '2') ) {",
	$files"})$(if ( ($fileGroups) -and ($_.Group[0].backupType -ne '2') ) {",
	$fileGroups"});
"@
				} # $restoreSql += $fileList | Sort-Object -property 'sortVal' | Group-Object -property 'groupVal' | % {

			} else {
				$restoreSql += $fileList | Sort-Object -property 'sortVal' | Group-Object -property 'groupVal' | % { 
@"
restore $(if ($($_.Group[0].backupType) -eq '2') {'log'} else {'database'} ) $newDbName$(
	if ( ($pageRestoreSql) -and ($_.Group[0].backupType -ne '2') ) { "`n`t$pageRestoreSql" }
)$(
	if ( ($pageRestoreSql) -and ($files) -and ($_.Group[0].backupType -ne '2') ) { "," } 
)$(
	if ( ($files) -and ($_.Group[0].backupType -ne '2') ) { "`n`t$files" }
)$(
	if ( ($files) -and ($fileGroups) -and ($_.Group[0].backupType -ne '2') ) { "," } 
)$(
	if ( ($fileGroups) -and ($_.Group[0].backupType -ne '2') ) { "`n`t$fileGroups" }
)
from 
	$( foreach ($file in $_.Group) { "disk = '$($file.pathAndFileName)'" } )
with
	file = $($_.Group[0].fileNumber)$(if ($checksum) {", checksum"})$(if ($stopAt -ne [System.DateTime]::MaxValue) {", stopat = `'$stopAt`'"}), norecovery, replace$(if ($moveLogsSql) {",
	$moveLogsSql"})$(if ($moveDataSql) {",
	$moveDataSql"});
"@
				} # $restoreSql += $fileList | Sort-Object -property 'sortVal' | Group-Object -property 'groupVal' | % {

			} # if ($liteSpeed)
			$OFS = " ";

			# Add recovery
			if ($recover) { $restoreSql += "restore database $newDbName with recovery;" }

			# Output the results if appropriate
			if (-not $noScriptOutput) {
				# Don't simply roll out the array because we may need to include a batch separator with
				# the output. Also, don't use the method of setting $OFS to a particular value and letting
				# the string unravelling handle because and I also don't want the output to be one big
				# string so folks can expect list output if they pipe this down the line somewhere
				$restoreSql | %{ "$_`n$batchSeparator" };
			}
			# Execute, if appropriate
			if ($execute) {
				# Execute in a loop vs. as a single batch for a few reasons - 1, I want to be able to trap
				# and handle errors for individual statements potentially, and 2, the actual string size
				# of a single batch could get quite large...
				$global:exceptionInRestoreSqlDbTryCatchBatch = $false;
				$restoreSql | try -soft {
						# Execute the current statement unless we hit a bump in the pipeline earlier...
						if (-not $global:exceptionInRestoreSqlDbTryCatchBatch) {
							Invoke-Sqlcmd -ServerInstance $toInstance -Database "master" -ConnectionTimeout $sqlConnectTimeout -AbortOnError -QueryTimeout 65535 -Query "$_"
						}
					} -catch {
						# Set our flag and throw the error
						$global:exceptionInRestoreSqlDbTryCatchBatch = $true;
						Throw $_;
				}	# $restoreSql | try -soft {

				# If we hit something, show a warning that we didn't finish the script completely
				if ($global:exceptionInRestoreSqlDbTryCatchBatch) {
					Write-Warning "Error occured during script processing and restore was aborted prematurely. Check the error pipeline for details and/or retry the restore."
				}
				# Get rid of our global...
				&{
					$local:ErrorActionPreference = "SilentlyContinue"
					Remove-Variable -name "exceptionInRestoreSqlDbTryCatchBatch" -scope "Global"
				}

			}	# if ($execute) {

			# All done...
			$newDbName = $null; 
			
		} # Restore-SqlDb process
		end { 
			$restoreSql, $fileList = $null, $null;
			$OFS = " ";
			&{
				$local:ErrorActionPreference = "SilentlyContinue"
				Remove-Variable -name "exceptionInRestoreSqlDbTryCatchBatch" -scope "Global"
			}
		} # Restore-SqlDb end

	} # function Restore-SqlDb
} # begin
process { 
	# No processing if we are dot-sourced or if we were just asked for a little help...
	if ($showUsage -or $MyInvocation.InvocationName -eq '.') {
		return;
	}

	# Process pipeline vs. invocation...
	if (($_) -or ($_ -eq 0)) {
		$InPipeline = $true;
		Write-Verbose "PROCESS - Pipeline process";
	} else {
		Write-Verbose "PROCESS - Invoked process";
	}

	$pipeLineDb = $null;
	if (($Args -notcontains '-dbName') -and ($Args -notcontains '-db')) {

		if ($_) {
			# Try setting/casting the input object to SMO DB object - if it works, we'll use the pipeline
			# object as the db to restore
			trap {
				Write-Debug "Restore-SqlDb.ps1::Could not convert pipeline object to dbName value [$_]."
				continue;
			}
			# Try to get the db name
			if ($_ -is [Microsoft.SqlServer.Management.Smo.Database]) {
				$pipeLineDb = "-dbName $($_.Name) ";
			}
			# NOTE: Not using an else here because for some reason the else does not get hit
			# when the SQL SMO libraries aren't loaded...
			if (-not $pipeLineDb) {
				$pipeLineDb = "-dbName $_ ";
			}
		}
	} # if (($Args -notcontains '-dbName') -and ($Args -notcontains '-db')) {

	Invoke-Expression "Restore-SqlDb $pipeLineDb$($pt = $Args; for($i=0; $i -lt $pt.Count; $i++) { `
		if ($pt[$i] -match '^-') { $pt[$i] } else { `"`$pt[$i]`" } })"; 
	
} # process
end {
	if ((-not $showUsage) -and ($MyInvocation.InvocationName -ne '.')) { Write-Debug "Restore-SqlDb::END" }
	$restoreSql, $fileList = $null, $null;
	$OFS = " ";
	&{
		$local:ErrorActionPreference = "SilentlyContinue"
		Remove-Variable -name "exceptionInRestoreSqlDbTryCatchBatch" -scope "Global"
	}
} # end
