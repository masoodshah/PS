set-location C:\PS\health\SQL_Server

$isodate=Get-Date -format s 
$isodate=$isodate -replace(":","")
$basepath=(Get-Location -PSProvider FileSystem).ProviderPath

$instancepath=$basepath + "\config\instances.txt"



$filePath = "" 

foreach ($instance in get-content $instancepath)
{

 $instance
	
  $outputfile="\logs\SP_Run_Result_For_" +$instance+"_"+ $isodate + ".txt"
  $outputfilefull = $basepath + $outputfile

	
  
   $sql = [Io.File]::ReadAllText('c:\ps\tsql\PerformPostInstallAudit.sql');
   Import-Module 'SQLPS' -DisableNameChecking;
   Invoke-Sqlcmd -Query $sql -ServerInstance $instance -verbose  > $outputfilefull;

}