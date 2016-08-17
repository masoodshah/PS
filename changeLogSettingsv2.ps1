<#
Start-Process powershell.exe -Credential “pfg\masood.shah”


Start-Process $PSHOME\powershell.exe -ArgumentList "-NoExit -Command & `"{$outvar1 = 4+4; `"out: $outvar1`"}`"" -Wait

get-eventlog -list -ComputerName PFGSQLT4N06 | where {$_.log -eq 'system'}
 

Application 30720 KB
Security 30720 KB
System 30720 KB
powershell.exe c:\ps\changeLogSettings.ps1
#>

 
$limitSys = @{
  Maximumsize = 30720KB
  logname = "System"
  RetentionDays = 21
  OverflowAction = "OverwriteOlder"
		}

$limitSec = @{
  Maximumsize = 30720KB
  logname = "Security"
  RetentionDays = 21
  OverflowAction = "OverwriteOlder"
		}

$limitApp = @{
  Maximumsize = 30720KB
  logname = "Application"
  RetentionDays = 21
  OverflowAction = "OverwriteOlder"
		}


$computers = "PFGSQLT4N06","PFGSQLT4N13","PFGSQLT4N14","PFGSQLT4N15","PFGSQLT4N16","PFGSQLT4N17","PFGSQLT4N18","PFGSQLT4N19","PFGSQLT4N20","PFGSQLT4N21","PFGSQLT4N22","PFGSQLT4N12"

foreach ($computer in $computers) {
 Write-Host "Setting limits on $($limitSys.logname) log on $($Computer.ToUpper())" -ForegroundColor Cyan

 #add the computer to the hashtable
 $limitSys.Computername = $computer

 Limit-EventLog @limitSys
 Get-Eventlog -list -computer $computer | where {$_.Log -eq $limitSys.logname}


Write-Host "Setting limits on $($limitSec.logname) log on $($Computer.ToUpper())" -ForegroundColor Cyan

 #add the computer to the hashtable
 $limitSec.Computername = $computer

 Limit-EventLog @limitSec
 Get-Eventlog -list -computer $computer | where {$_.Log -eq $limitSec.logname}

Write-Host "Setting limits on $($limitApp.logname) log on $($Computer.ToUpper())" -ForegroundColor Cyan

 #add the computer to the hashtable
 $limitApp.Computername = $computer

 Limit-EventLog @limitApp
 Get-Eventlog -list -computer $computer | where {$_.Log -eq $limitApp.logname}

$computers = Get-WmiObject Win32_ComputerSystem -EnableAllPrivileges$computers.AutomaticManagedPagefile = $False$computers.Put()

}

