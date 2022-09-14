### Randomise disabled account passwords with DinoPass

$domCont=Get-Random -InputObject ((get-addomain).replicadirectoryservers) -Count 1

$disableduser = Get-ADUser -Filter * -Property Enabled,SamAccountName -SearchBase "OU=Staff,DC=Fabrakim,DC=com" -SearchScope Subtree| Where-Object {$_.Enabled -like “false”} 
### copy and paste the line above to do different OU's. 


foreach ($user in $disableduser) {
    Set-ADAccountPassword -Identity $user.SamAccountName -reset -NewPassword ((Invoke-WebRequest -uri https://www.dinopass.com/password/strong).content | ConvertTo-SecureString -AsPlainText -force) -Server $domCont
    set-aduser -Identity $user.SamAccountName -PasswordNeverExpires $true -Server $domCont
    Write-Host "Reset password for" $user.samaccountname
}