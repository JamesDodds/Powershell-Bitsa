<#
.SYNOPSIS
  Import CSV into AD Distribution Lists
.DESCRIPTION
  Imports O365 contact export into Active Directory. The more detailed the contacts exported the better. 
  CSV MANDATORY fields are: First name, Last name and Display name. Email missing won't break anything, but seems pointless to not include.
  Don't change the header names.
.PARAMETER $CSVFilename
  The path of the CSV file
.INPUTS
  None
.OUTPUTS
  CSV File
.NOTES
  Version:        1.1
  Author:         James Dodds
  Creation Date:  20200714
  Purpose/Change: Fixed handling of empty values in import CSV
  
.EXAMPLE
  Import-ContactsCSV -CSVFilename .\contacts.CSV -OUPath "OU=Contacts,DC=contoso,DC=com"
#>
param(
[parameter(Mandatory=$True, HelpMessage='Please enter a filename for the CSV file to export')]$CSVFilename,
[parameter(Mandatory=$true, HelpMessage='Distinguished Name of OU to create contacts')]$OUPath
)

Import-Module ActiveDirectory

$Contacts = Import-Csv -Path $CSVFilename
$DomCont=Get-Random -InputObject ((Get-ADDomainController).hostname) -Count 1

ForEach($Person in $Contacts){
  $Params = @{
    Name = if(($person.'First name' -or $person.'Last name') -eq ''){$person.Name}else{$person.'First Name'+" "+$person.'Last name'}
    Description = if($Person.Description -eq ''){"External Contact"}else{$Person.Description}
    DisplayName = $person.'Display name'
    Path = $OUPath
  }
  $otherattributes =@{
    mail=$Person.Email
    GivenName = if($Person.'First name'){$Person.'First name'}else{"Empty"}
    sn = if($Person.'Last name'){$Person.'Last name'}else{"Empty"}
    Company = if($Person.Company){"Company"}else{$Person.Company}
    telephoneNumber = if($Person.Phone){$Person.Phone}else{"Empty"}
    title = if($Person.'Job title'){$Person.'Job title'}else{"Empty"}
  }
    try{
        New-ADObject  @Params -Type Contact -otherattribute $otherattributes -Server $DomCont
        Write-Host "Created contact for" $params.Name
        }
    catch{
    
    }
}