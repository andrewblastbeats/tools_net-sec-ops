$service1 = "XblAuthManager"
$service2 = "XblGameSave"
$service3 = "WalletService"
$service4 = "Audiosrv"
$service5 = "AudioEndpointBuilder"
$service6 = "Quality Windows Audio Video Experience"
$service7 = "PhoneSvc"
$service8 = "bthserv" # bluetooth
$service9 = "lfsvc" # Geolocation

$schedTask1 = "XblGameSaveTaskLogon"
$schedTask2 = "XblGameSaveTask"
Stop-Service $service1
Set-Service $service1 -StartupType Disabled
Stop-Service $service2
Set-Service $service2 -StartupType Disabled
Get-ScheduledTask -TaskName $schedTask1 | Disable-ScheduledTask
Get-ScheduledTask -TaskName $schedTask2 | Disable-ScheduledTask
