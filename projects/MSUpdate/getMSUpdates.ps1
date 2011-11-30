function WriteEvent ($eventMessage,$eventType,$eventID)
    {
    $sourceName = 'UCTeam Scripts'
    if (-not([System.Diagnostics.EventLog]::SourceExists($sourceName)))
        {
        [System.Diagnostics.EventLog]::CreateEventSource($sourceName,'Application')
        }
    $EventLog = New-Object System.Diagnostics.EventLog('Application')
    $eventLogType = [System.Diagnostics.EventLogEntryType]::$eventType
    $EventLog.Source = $sourceName
    $EventLog.WriteEntry($eventMessage,$eventLogType,$EventID)
    }
    
#Software updates only, selected by default, not already installed
#$criteria="IsInstalled=0 and Type='Software' and AutoSelectOnWebSites=1"
$criteria="IsInstalled=0 and AutoSelectOnWebSites=1"
$resultcode= @{0="Not Started"; 1="In Progress"; 2="Succeeded"; 3="Succeeded With Errors"; 4="Failed" ; 5="Aborted" }
$updateSession = New-Object -ComObject 'Microsoft.Update.Session'
Write-Host "Windows Update process is starting."
Write-Host "Beginning check for available updates based on the following criteria: $criteria."
$updates = $updateSession.CreateupdateSearcher().Search($criteria).Updates

if ($updates.Count -eq 0)
    {
    Write-Host "Check for available updates is complete.  There are no updates to apply."
    }
else
    {
    Write-Host "Check for available updates is complete.  There are $($updates.Count) updates to apply."
    }
Write-Host "Windows Update process is complete."

#Currently this script doesnt get the "optional" part of the updates. need to investigate further.

#MsrcSeverity
#Set updatesToDownload = CreateObject("Microsoft.Update.UpdateColl") 
#For I = 0 to searchResult.Updates.Count-1 Set update = searchResult.Updates.Item(I) 
#'DO YOUR WORK HERE BASED ON MsrcSeverity check - FOR EXAMPLE: 
#If update.MsrcSeverity = "Important" OR update.MsrcSeverity = "Critical" Then 
#wscript.echo ("This item is " & update.MsrcSeverity & " and will be processed!") 
#wscript.echo(I + 1 & "> adding: (" & update.MsrcSeverity & ") " & update.Title) 
#updatesToDownload.Add(update) 
#End If Next 

#note:
#Set-ExecutionPolicy RemoteSigned
#
#Running Windows PowerShell Scripts
#http://technet.microsoft.com/en-us/library/ee176949.aspx
#
#Programmatically run Windows Update (as part of a broader patch and reboot process)
#http://www.flobee.net/programmatically-run-windows-update-as-part-of-a-broader-patch-and-reboot-process/
#
#Using the Out-File Cmdlet 
#http://technet.microsoft.com/en-us/library/ee176924.aspx
#Get-Process | Out-File c:\scripts\test.txt
#
#Searching, Downloading, and Installing Updates 
#http://msdn.microsoft.com/en-us/library/windows/desktop/aa387102%28v=vs.85%29.aspx
#
#IUpdate Interface
#http://msdn.microsoft.com/en-us/library/aa386099(v=VS.85).aspx
