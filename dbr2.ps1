set-location C:\PS\health\SQL_Server

$isodate=Get-Date -format s 
$isodate=$isodate -replace(":","")
$basepath=(Get-Location -PSProvider FileSystem).ProviderPath


$instancepath=$basepath + "\config\instances.txt"
$outputfile="\logs\sql_server_db_sizes_" + $isodate + ".csv"
$outputfilefull = $basepath + $outputfile


$filePath = ""

$dt = new-object "System.Data.DataTable"
foreach ($instance in get-content $instancepath)
{
$instance
$cn = new-object System.Data.SqlClient.SqlConnection "server=$instance;database=msdb;Integrated Security=sspi"
$cn.Open()
$sql = $cn.CreateCommand()
$sql.CommandText = "
with fs
as
(
    select  database_id, type, size * 8.0 / 1024 size
    from sys.master_files
)
select @@servername as servername,
    name as dbname,
    (select sum(size )  from fs where type = 0 and fs.database_id = db.database_id) DataFileSizeMB,
    (select sum(size) from fs where type = 1 and fs.database_id = db.database_id) LogFileSizeMB
from sys.databases db
order by name;
"
    $rdr = $sql.ExecuteReader()
    $dt.Load($rdr)
    $cn.Close()
 
}

$dt | select * -ExcludeProperty RowError, RowState, HasErrors, Name, Table, ItemArray | Export-CSV   $outputfilefull  

$filepath = $outputfilefull  