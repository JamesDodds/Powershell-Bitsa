<#
.SYNOPSIS
  Export members of groups to CSV
.DESCRIPTION
  Exports all members (users and contacts) of an AD group to a CSV on the users desktop. 
  Requires the Active Directory RSAT tools be installed first. I could check for them and install, but that is more code that I really don't care to add. DIY!
.PARAMETER $CSVFilename
  The path the the CSV file
.INPUTS
  None
.OUTPUTS
  CSV File
.NOTES
  Version:        1.0
  Author:         James Dodds
  Creation Date:  20220901
  Purpose/Change: Initial version
  
.EXAMPLE
  Export-GroupMembers -Group DL-123-a-name
.EXAMPLE
  Export-GroupMembers -Group SG_ahHAHIsee -path c:\temp
#>

param(
    # Username param
    [parameter(Mandatory=$true, HelpMessage="Group container name (cn) in Active Directory")]
    [ValidateLength(3,20)]
    [String]$Group,
    # Parameter help description
    [Parameter(Mandatory=$false, HelpMessage="Enter a path. If not, it defaults to the users desktop")]
    [ValidateLength(3,34)]
    [string]$path = "$env:USERPROFILE\Desktop\"
)

Import-Module ActiveDirectory

Function Get-ADAllGroupMembers {
    Param(
        [Parameter(
            Mandatory = $True,
            Position = 0
        )]
        [String]
        $Identity,

        [Switch]
        $Recursive,

        [Ref]
        $searched = ([Ref](New-Object -TypeName System.Collections.ArrayList))
    )

    $group = Get-ADGroup -Identity $Identity -Properties Members -ErrorAction Stop
    $searched.Value.Add($group.DistinguishedName) | Out-Null

    $groups = @()
    $groups = $group.Members | 
    Where-Object {
        -not $searched.Value.Contains($_)
    } |
    ForEach-Object {
        Get-ADObject -Filter {DistinguishedName -eq $_ -and ObjectClass -eq 'group'} |
        Select-Object -ExpandProperty DistinguishedName
    }

    $members = @()
    $members = $group.Members |
    Where-Object {
        -not $searched.Value.Contains($_) -and
        -not $members -contains $_
    } |
    ForEach-Object {
        Get-ADObject -Filter {DistinguishedName -eq $_ -and ObjectClass -ne 'group'} |
        Select-Object -ExpandProperty DistinguishedName

    }
    
    If($Recursive) {
        ForEach($group in $groups) {
            $sub_members = Get-ADAllGroupMembers -Identity $group -searched $searched -Recursive
            ForEach($sub in $sub_members) {
                If($members -notcontains $sub) {
                    $members += $sub
                }
            }
        }
    } Else {
        $members += $groups
    }

    Return $members
}

$CSVcontents = Get-ADAllGroupMembers -Identity $Group -Recursive | Get-ADObject -Properties Title,Department,mail,company | Select-Object Name,Title,Department,mail,company
Export-Csv -Path (Join-Path -Path $path -ChildPath "Desktop\$group_members.csv") -InputObject $CSVcontents