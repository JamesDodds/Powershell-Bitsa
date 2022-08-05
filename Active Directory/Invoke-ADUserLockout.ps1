<#
.SYNOPSIS
  Lockout specified account
.DESCRIPTION
  Locks out the account named. Used to generate logs and for testing. Don't use it to be a pratt.
  It will check for an environment variable (cause retreiving the Default Domain Policy can take longer than patience) and use that if present.
  If not present, will retreive Default Domain Policy setting, set it as a user variable and a session variable. 
  If setting not present in GPO, will use 10 as a default.
.PARAMETER $username
  The username of the target account
.PARAMETER $hostname
  The hostname of a target machine to attempt a remote powershell session
.INPUTS
  None
.OUTPUTS
  Log to screen
.NOTES
  Version:        1.0
  Author:         James Dodds
  Creation Date:  20220805
  Purpose/Change: Initial
  
.EXAMPLE
  Invoke-ADUserLockout -username fred.jones
#>

param(
    # Username param
    [parameter(Mandatory=$true, HelpMessage="Username")]
    [ValidateLength(4,20)]
    [String]$username,
    # Parameter help description
    [Parameter(Mandatory=$false, HelpMessage="Enter a hostname. If not, defaults to localhost")]
    [ValidateLength(4,34)]
    [string]$hostname = $ENV:COMPUTERNAME
)
if (!$env:ACCLOCKTHRESHOLD){
  write-output  "Account Lockout Threshold not available as environment variable, retreiving from Default Domain Policy"
  $ACCLOCKTHRESHOLD = ((([xml](Get-GPOReport -Name "Default Domain Policy" -ReportType Xml)).GPO.Computer.ExtensionData.Extension.Account |
              Where-Object name -eq LockoutBadCount).SettingNumber)
  if ($ACCLOCKTHRESHOLD -eq "") 
    { 
      Write-Output "Account Lockout Threshold is Not Defined in Default Domain Policy, going with 10 attempts"
      [Environment]::SetEnvironmentVariable('ACCLOCKTHRESHOLD','10',"User")
      $env:ACCLOCKTHRESHOLD = $ACCLOCKTHRESHOLD
    }
  else {
    [Environment]::SetEnvironmentVariable('ACCLOCKTHRESHOLD',[string]$ACCLOCKTHRESHOLD,"User")
    $env:ACCLOCKTHRESHOLD = $ACCLOCKTHRESHOLD
  }
}

Write-Output "Account will lock out after '$env:ACCLOCKTHRESHOLD' invalid login attempts"
$password = ConvertTo-SecureString 'IBetterNotBeAValidPassword!' -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($username, $password)   
$attempts = 0

Do {                         
    $attempts++
    Write-Output "'$username' login attempt $attempts"
    Enter-PSSession -ComputerName $hostname -Credential $credential -ErrorAction SilentlyContinue           
}
Until ($attempts -eq $env:ACCLOCKTHRESHOLD)

Write-Output "'$username' successfully locked out." 