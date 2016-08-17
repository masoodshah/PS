   $instance='pfgsqlt4n17'
   $outfile="C:\PS\health\SQL_Server\logs\SqlLog"+ $instance +".txt"
   $sql = [Io.File]::ReadAllText('c:\ps\tsql\PerformPostInstallAudit.sql');
   Import-Module 'SQLPS' -DisableNameChecking;
   Invoke-Sqlcmd -Query $sql -ServerInstance $instance -verbose  > $outfile;