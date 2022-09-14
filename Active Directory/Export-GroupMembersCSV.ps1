<#
.SYNOPSIS
  Export Distribution Group members to csv on the deskop
.DESCRIPTION
  Exports DL members (contacts and users) into a CSV on the desktop. Imports the Exchange Online PS cmdlets to work with AD DL's
.PARAMETER $CSVFilename
  The path the the CSV file
.INPUTS
  None
.OUTPUTS
  CSV File
.NOTES
  Version:        1.0
  Author:         James Dodds
  Creation Date:  20200803
  Purpose/Change: Initial version
  
.EXAMPLE
  Export-DLGroups -DGnName "DL-Anything"
#>
param([parameter(Mandatory=$false, HelpMessage="Please enter a group name")]$DGnName)

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
$365Cred = Get-Credential
$ExOSession = New-PSSession -ConfigurationName Microsoft.Exchange `
 -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $365Cred -Authentication Basic -AllowRedirection
Import-PSSession $ExOSession –DisableNameChecking -AllowClobber

if($DGnName -eq $null){
    $DGnName = Read-Host "Enter the Distribution Group name"
}
$csvpath = $env:USERPROFILE+"\Desktop\"+$DGnName+"_Members.csv"

Get-DistributionGroupMember $DGnName | Select-Object Name, PrimarySMTPAddress | Export-CSV $csvpath

Remove-PSSession $ExOSession