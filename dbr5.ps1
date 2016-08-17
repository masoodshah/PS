set-location C:\PS\health\SQL_Server

$isodate=Get-Date -format s 
$isodate=$isodate -replace(":","")
$basepath=(Get-Location -PSProvider FileSystem).ProviderPath


$instancepath=$basepath + "\config\instances.txt"

$resultsarray =@()

$filePath = ""

$a = "<style>"
$a = $a + "BODY{background-color:peachpuff;}"
$a = $a + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
$a = $a + "TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:thistle}"
$a = $a + "TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:PaleGoldenrod}"
$a = $a + "</style>"

$sql = [Io.File]::ReadAllText('c:\ps\tsql\PerformPostInstallAudit.sql');
   


$dt = new-object "System.Data.DataTable"
foreach ($instance in get-content $instancepath)
{
$instance
$outputfile="\logs\sql_server_db_sizes_" +$instance+"_"+ $isodate + ".html"
$outputfilefull = $basepath + $outputfile
$cn = new-object System.Data.SqlClient.SqlConnection "server=$instance;database=msdb;Integrated Security=sspi"
Import-Module 'SQLPS' -DisableNameChecking;
trap
{
Write-Error "Cannot connect to $instance.";
continue
}



 if(Test-Connection -ComputerName $instance -Count 1 -ea 0) {            
   try {            
    $Networks = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $instance -EA Stop | ? {$_.IPEnabled}            
   } catch {            
        Write-Warning "Error occurred while querying $instance."            
        Continue            
   }



   foreach ($Network in $Networks) {            
    $IPAddress  = $Network.IpAddress[0]            
    $SubnetMask  = $Network.IPSubnet[0]            
    $DefaultGateway = $Network.DefaultIPGateway            
    $DNSServers  = $Network.DNSServerSearchOrder            
    $IsDHCPEnabled = $false            
    If($network.DHCPEnabled) {            
     $IsDHCPEnabled = $true            
    }            
    $MACAddress  = $Network.MACAddress            
    $OutputObj  = New-Object -Type PSObject            
    $OutputObj | Add-Member -MemberType NoteProperty -Name ComputerName -Value $instance.ToUpper()            
    $OutputObj | Add-Member -MemberType NoteProperty -Name IPAddress -Value $IPAddress            
    $OutputObj | Add-Member -MemberType NoteProperty -Name SubnetMask -Value $SubnetMask            
    $OutputObj | Add-Member -MemberType NoteProperty -Name Gateway -Value $DefaultGateway            
    $OutputObj | Add-Member -MemberType NoteProperty -Name IsDHCPEnabled -Value $IsDHCPEnabled            
    $OutputObj | Add-Member -MemberType NoteProperty -Name DNSServers -Value $DNSServers            
    $OutputObj | Add-Member -MemberType NoteProperty -Name MACAddress -Value $MACAddress            
	$resultsarray += $OutputObj           
   } 
}
$resultsarray | Where-Object {($_.ComputerName -eq $instance )}| ConvertTo-Html -head $a  -body "<H2>Network Details</H2>" | Set-Content $outputfilefull 
#Invoke-Sqlcmd -Query $sql -ServerInstance $instance ;
$cn.Open()
if ($cn.State -eq 'Open')
{
$sql = $cn.CreateCommand()
$sql.CommandText = "
exec msdb..test
"


    $rdr = $sql.ExecuteReader()
    $dt.Load($rdr)
    $cn.Close()
}
   
$dt | select * -ExcludeProperty RowError, RowState, HasErrors, Name, Table, ItemArray | ConvertTo-Html -head $a -body "<H2>SQL Server Configuartion Check List</H2>" | Add-Content $outputfilefull  
$dt.clear()

$filepath = $outputfilefull 


}

 