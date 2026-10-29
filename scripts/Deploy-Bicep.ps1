<#
.SYNOPSIS
Previews or deploys a Bicep stack from the repository root.
.EXAMPLE
./scripts/Deploy-Bicep.ps1 -ZoneCategory platform -ZoneName hub -FunctionName bootstrap -Location australiaeast -Environment nonprod -DeploymentScope sub
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ZoneCategory,
    [Parameter(Mandatory)][string]$ZoneName,
    [Parameter(Mandatory)][string]$FunctionName,
    [Parameter(Mandatory)][string]$Location,
    [Parameter(Mandatory)][string]$Environment,
    [Parameter(Mandatory)][ValidateSet('tenant', 'mg', 'sub', 'group')][string]$DeploymentScope,
    [string]$ResourceGroup,
    [string]$RootManagementGroupId,
    [bool]$WhatIf = $true
)

. "$PSScriptRoot/Manage-Eslz.ps1"
Deploy-Zone @PSBoundParameters -Bicep
