<#
.SYNOPSIS
  Import CSV into AD Distribution Lists
.DESCRIPTION
  Imports O365 DL into Active Directory.
.PARAMETER $CSVFilename
  The path the the CSV file
.INPUTS
  None
.OUTPUTS
  CSV File
.NOTES
  Version:        1.0
  Author:         James Dodds
  Creation Date:  20200714
  Purpose/Change: Initial version
  
.EXAMPLE
  Import-DLCSV -CSVFilename .\contacts.CSV -OUPath "OU=Contacts,DC=contoso,DC=com"
#>
param(
[parameter(Mandatory=$True, HelpMessage='Please enter a filename for the CSV file to import')]$CSVFilename,
[parameter(Mandatory=$true, HelpMessage='Distinguished Name of OU to create contacts')]$OUPath
)

$DLCSV = Import-Csv -Path $CSVFilename
$DomCont=Get-Random -InputObject ((Get-ADDomainController).hostname) -Count 1

foreach($DL in $DLCSV){
    $Params=@{
        Name="DL-"+$dl.Alias
        Description=if($DL.GroupDisplayName -eq ''){"Description"}else{$DL.GroupDisplayName}
        DisplayName=$DL.DisplayName #also sets
        
    }
    $memberDN=@()
    foreach($member in ($dl.MembersSMTP -split "`n")){
        $temp=(get-adobject -Filter ('mail -eq $member')).distinguishedName
        $memberDN+=$temp
    }
    $OtherAttributes=@{
        member=$memberDN
        proxyAddresses=($dl.EmailAddresses -replace "`nX500.*","") -split "`n"
        mail=$dl.GroupSMTPAddress
    }
    try{
        new-adgroup @params -GroupScope Global -GroupCategory Distribution -OtherAttributes $OtherAttributes -Path $OUPath
        Write-Host "Created contact for" $params.Name
        }
    catch{
    
    }

}

