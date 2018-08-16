$global:never_expires = @()
$global:last_set = @()
$global:inactive_90 = @()
$global:filepath = ""
$global:domain = ""

Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False} –Properties Name,UserPrincipalName,Created,PasswordLastSet,msDS-UserPasswordExpiryTimeComputed,Modified | Select-Object -Property Name,UserPrincipalName,Modified,@{Name=“ExpiryDate”;Expression={[datetime]::FromFileTime($_.“msDS-UserPasswordExpiryTimeComputed”)}}

function Get-PasswordNeverExpires () {
  $never_expires += Get-ADUser -Filter {Enabled -eq $True -and PasswordNeverExpires -eq $True} -Properties Name,UserPrincipalName,Created,PasswordLastSet | Select Name,UserPrincipalName,Created,PasswordLastSet,Modified
  $filename_neverexp += "\pwd_never_expire-"
  $filename_neverexp += Get-Date -UFormat "%Y%m%d"
  $filename_neverexp += ".csv"
  $never_expires | Select Name,UserPrincipalName,Created,PasswordLastSet | Export-Csv $filename_neverexp
}

function Get-PasswordLastSet () {
  $last_set += Get-ADUser -Filter {Enabled -eq $True} -Properties Name,UserPrincipalName,Created,PasswordLastSet | Select Name,UserPrincipalName,Created,PasswordLastSet
  $filename_neverexp += filepath
  $filename_neverexp += "\pwd_last_set-"
  $filename_neverexp += Get-Date -UFormat "%Y%m%d"
  $filename_lastset += ".csv"
  $last_set | Select Name,UserPrincipalName,Created,PasswordLastSet | Export-Csv $filename_lastset
}

function Get-InactiveUsers () {
  $days_inactive = 60
  $time = (Get-Date).AddDays(-($days_inactive))

  $inactive_90 = Get-ADUser -Filter {LastLogonTimeStamp -lt $time -and Enabled -eq $True} -Properties Name,UserPrincipalName,Created,PasswordLastSet,LastLogonTimeStamp
  Select-Object Name,UserPrincipalName,Created,PasswordLastSet,@{Name = "LastLogonTimeStamp"; Expression = {[DateTime]::FromFileTime($_.LastLogonTimeStamp).ToString('yyyy-MM-dd_hh:mm:ss')}} | Export-Csv
}

Write-Host "The password check tool has the following options:"
Write-Host "    1) Get all accounts where the 'password never expires' is enabled."
Write-Host "    2) Get the PasswordLastSet date for all accounts."
Write-Host "    3) Get all accounts with 90+ days of inactivity."
$mailbox_search_type = Read-Host "`nEnter your selection (1, 2, or 3): "
