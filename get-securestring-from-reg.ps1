<# 
.SYNOPSIS 
Retrieve the text version of a securestring stored in the local users' registry
 
.DESCRIPTION 
 This must be used in conjunction with set-regcredentials.ps1 to store
 sensitive data in the registry using secure string.  The strings can be retrieved by running this script
 by the same user account.  This allows automation and scripting without storing api keys, users, and
 password information in clear-text.

  ***Please be aware, securestring storage is only as secure as the machine and users operating
 (or with access to) it. If you have access to the scripts, and some level of local administrative privilleges,
 it is a trivial task to alter the scripts in order to recover/retrieve the original text of the stored
 securestring values.  As best security practices demand, these stored credentials should only provide the least
 privillege required to accomplish the task.  Any processes that store/retrieve these values should ONLY be
 stored and run on a secured and limited-access endpoint, with a well-secured service account.
 
 
.NOTES 
┌─────────────────────────────────────────────────────────────────────────────────────────────┐ 
│ get-securestring-from-reg.ps1                                                               │ 
├─────────────────────────────────────────────────────────────────────────────────────────────┤ 
│   DATE        : 01.19.2019              	                                								  │ 
│   AUTHOR      : Paul Drangeid                               			              					  │ 
│   SITE        : https://blog.graphcommit.com/                                               │ 
└─────────────────────────────────────────────────────────────────────────────────────────────┘ 
 
.EXAMPLE 
get-securestring-from-reg.ps1 -credname 'MyCredName' -credpath 'myappname\credentials'

#> 

param (

[Parameter(mandatory=$true)][string]$credname,
[string]$credpath,
[int]$verbosity
)

$global:srccmdline = $($MyInvocation.MyCommand.Name)

if ($null -eq $verbosity){[int]$verbosity=1} #verbosity level is 1 by default
if (!([string]::IsNullOrEmpty($credpath))){
$credpath="HKCU:\Software\$credpath\$credname"
$credpath=$credpath.replace('\\','\')
}
if ([string]::IsNullOrEmpty($credpath)){[string]$credpath="HKCU:\Software\Mycredentials\$credname"}

Try{. "$PSScriptRoot\bg-sharedfunctions.ps1" | Out-Null}
Catch{
    Write-Warning "I wasn't able to load the sharedfunctions includes (which should live in the same directory as get-cypher-results.ps1). `nWe are going to bail now, sorry 'bout that!"
    Write-Host "Try running them manually, and see what error message is causing this to puke: $PSScriptRoot\bg-sharedfunctions.ps1"
    BREAK
    }

  Try{
    $SecureString = Get-SecurePassword $credpath $($credname+"PW")
    #Write-Host $SecureString
    RETURN $SecureString | Out-String
  }
  Catch{
    Write-Host "Sorry"
        BREAK
        }

  #Clean-up

  Exit 0