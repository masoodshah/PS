<#
Start-Process powershell.exe -Credential “pfg\masood.shah”


Start-Process $PSHOME\powershell.exe -ArgumentList "-NoExit -Command & `"{$outvar1 = 4+4; `"out: $outvar1`"}`"" -Wait

get-eventlog -list -ComputerName PFGSQLT4N06 | where {$_.log -eq 'system'}
 

Application 30720 KB
Security 30720 KB
System 30720 KB
powershell.exe c:\ps\changeLogSettings.ps1
#>

 
$limitParam = @{
  Maximumsize = 30720KB
  logname = "System"
  RetentionDays = 21
  OverflowAction = "OverwriteOlder"
		}


$computers = "PFGSQLT4N06","PFGSQLT4N13","PFGSQLT4N14"

foreach ($computer in $computers) {
 Write-Host "Setting limits on $($limitParam.logname) log on $($Computer.ToUpper())" -ForegroundColor Cyan

 #add the computer to the hashtable
 $limitParam.Computername = $computer

 Limit-EventLog @limitParam
 Get-Eventlog -list -computer $computer | where {$_.Log -eq $limitparam.logname}
}