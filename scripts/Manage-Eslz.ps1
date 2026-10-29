<#
.SYNOPSIS
#>

# ESLZ Management script
# Designed to be run both locally and through CICD pipelines

function Build-Bicep()
{
    param(
        [string]$ZoneCategory,
        [string]$ZoneName,
        [string]$FunctionName,
        [string]$OutputPath = "./stacks/$ZoneCategory/$ZoneName/$FunctionName"
    )
    Write-Host @"
/================================
|       >> BUILD-BICEP <<
|
| Zone Category: $ZoneCategory
| Zone Name: $ZoneName
| Function Name: $FunctionName
| Output Path: $OutputPath
\================================
"@
    "Building with $(az bicep version)"
    $buildRoot = "./stacks/$ZoneCategory/$ZoneName/$FunctionName"

    New-Item -ItemType Directory -Path "$OutputPath/parameters" -Force | Out-Null

    # Build the ARM template from the bicep source
    Write-Host "> Build-Bicep: Building json ARM template from .bicep source..."
    az bicep build --file "$($buildRoot)/main.bicep" --outfile "$($outputPath)/main.json"
    if ($LASTEXITCODE -ne 0) { throw "Bicep build failed: $buildRoot/main.bicep" }

    # Build json parameter files from the bicepparam source in the parameters folder
    Write-Host "> Build-Bicep: Building json parameters from .bicepparam source(s):"
    Get-ChildItem "$($buildRoot)/parameters" -Filter *.bicepparam |
    Foreach-Object {
        Write-Host ">> Build-Bicep: Building $($_.BaseName)$($_.Extension) --> $($_.BaseName).json"
        az bicep build-params --file "$_" --outfile "$($outputPath)/parameters/$($_.BaseName).json"
        if ($LASTEXITCODE -ne 0) { throw "Bicep parameter build failed: $_" }
    }
}

function Deploy-Zone()
{
    param(
        [Parameter(Mandatory=$true)][string]$ZoneCategory,
        [Parameter(Mandatory=$true)][string]$ZoneName,
        [Parameter(Mandatory=$true)][string]$FunctionName,
        [Parameter(Mandatory=$true)][string]$Location,
        [Parameter(Mandatory=$true)][string]$Environment,
        [Parameter(Mandatory=$true)][string]$DeploymentScope,
        [Parameter(Mandatory=$false)][string]$ResourceGroup,
        [Parameter(Mandatory=$false)][string]$RootManagementGroupId,
        [Parameter(Mandatory=$false)][string]$DeployPath = "./stacks/$ZoneCategory/$ZoneName/$FunctionName",
        [Parameter(Mandatory=$false)][bool]$WhatIf = $true,
        [Parameter(Mandatory=$false)][Switch]$Bicep = $false,
        [Parameter(Mandatory=$false)][string]$ExtraArgs
    )

    # Hashtables for deployment naming conventions
    $envShortName = @{
        "production" = "prod"
        "nonprod" = "nprd"
        "tenant" = "tent"
    }
    $locationCodes = @{
        "global" = 'glbl'
        "australiasoutheast" = 'ause'
        "australiaeast" = 'auea'
        "australiacentral" = 'auce'
        "australiacentral2" = 'auc2'
    }

    Write-Host @"
/================================
|        >> DEPLOY-ZONE <<
|
| Zone Category: $ZoneCategory
| Zone Name: $ZoneName
| Function Name: $FunctionName
| DeployPath: $DeployPath
| Location: $Location
| Environment: $Environment
| Deployment Scope: $DeploymentScope
| What-If: $WhatIf
| Bicep Source: $Bicep
| Extra Arguments: $ExtraArgs
\================================
"@
    Write-Host
    Write-Host "> Deploy-Zone: Deploying $FunctionName into Zone: $ZoneCategory/$ZoneName/$Location/$Environment..."

    # Set the operation based on WhatIf switch
    $operation = ($WhatIf -eq $true) ? "what-if" : "create"

    # Set extension for templates & parameters based on Bicep switch, allowing deployment directly from bicep if required
    $templateExtension = $Bicep ? "bicep" : "json"
    $paramsExtension = $Bicep ? "bicepparam" : "json"

    $templatePath = "$($DeployPath)/main.$($templateExtension)"
    $paramPath = "$DeployPath/parameters/$($FunctionName).$($Environment).$($Location).$($paramsExtension)"

    # Test for existence of template and parameters
    if (!(Test-Path $templatePath)) {
        throw ">> Deploy-Zone: ERROR: Template file not found at $templatePath"
    }
    if (!(Test-Path $paramPath)) {
        throw ">> Deploy-Zone: ERROR: Parameters file not found at $paramPath"
    }

    # Commmon arguments for all deployments
    $templateArgs = "--name $($FunctionName)-$($locationCodes["$Location"])-$($envShortName["$Environment"]) --template-file $templatePath --parameters $paramPath $ExtraArgs --verbose"

    # Set scope-specific arguments
    if ($DeploymentScope -eq "mg") {
        $scopeArgs = "--management-group-id $RootManagementGroupId --location australiaeast"
    }if ($DeploymentScope -eq "group"){
        $scopeArgs = "--resource-group $ResourceGroup"
    }if (($DeploymentScope -eq "tenant") -or ($DeploymentScope -eq "sub")){
        $scopeArgs = "--location $Location"
    }

    # Concatenate above arguments into expression and execute
    $deployCommand = "az deployment $DeploymentScope $operation $scopeArgs $templateArgs"
    Write-Host "> Deploy command: '$deployCommand'"
    Write-Host "---- Deploy Start ----"
    $deploymentResult = (Invoke-Expression -Command "$deployCommand")
    Write-Host "---- Deploy End ----"
    return $deploymentResult
}
