param (
    #policy from the source system
    [string]$policySrc = ".\xml\policy.source.xml",

    #schema from the source system
    [string]$schemaSrc = ".\xml\schema.source.xml",

	#policy from the target system
    [string]$policyTrg = ".\xml\policy.target.xml",

    #schema from the target system
    [string]$schemaTrg = ".\xml\schema.target.xml",

    #delta between the source and the destination system, the output of SyncPolicy.ps
    [string]$policyChanges = ".\xml\policy.changes.xml",

    #delta between the source and the destination system, the output of SyncSchema.ps1
    [string]$schemaChanges = ".\xml\schema.changes.xml"
)

$saxonInstallationPath = "C:\Program Files\Saxonica\SaxonHE9.8N\bin\Transform.exe"
$xmlFolder = ".\xml"


Write-Host "Running TransformGetIDDict.xsl on $policySrc"
. $saxonInstallationPath -s:$policySrc -xsl:TransformGetIDDict.xsl -o:"$xmlFolder\dict_policy_source_resource.xml"
Write-Host "Running TransformGetIDDict.xsl on $schemaSrc"
. $saxonInstallationPath -s:$schemaSrc -xsl:TransformGetIDDict.xsl -o:"$xmlFolder\dict_schema_source_resource.xml"
Write-Host "Running TransformGetIDDict.xsl on $policyTrg"
. $saxonInstallationPath -s:$policyTrg -xsl:TransformGetIDDict.xsl -o:"$xmlFolder\dict_policy_target_resource.xml"
Write-Host "Running TransformGetIDDict.xsl on $schemaTrg"
. $saxonInstallationPath -s:$schemaTrg -xsl:TransformGetIDDict.xsl -o:"$xmlFolder\dict_schema_target_resource.xml"

Write-Host "Running TransformSchemaChanges.xsl on $schemaChanges"
. $saxonInstallationPath -s:$schemaChanges -xsl:TransformSchemaChanges.xsl -o:"$xmlFolder\output_schema.xml"
Write-Host "Running TransformPolicyChanges.xsl on $policyChanges"
. $saxonInstallationPath -s:$policyChanges -xsl:TransformPolicyChanges.xsl -o:"$xmlFolder\output_policy.xml"

Write-Host "Running FixMissingReferencesFromDict.ps1"
.\FixMissingReferencesFromDict.ps1
Write-Host "Running ReplaceVariables.ps1"
.\ReplaceVariables.ps1
Write-Host "Running SeparateIntoFolders.ps1"
.\SeparateIntoFolders.ps1

Write-Host "Done"