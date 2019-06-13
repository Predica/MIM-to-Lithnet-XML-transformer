param (
    [string]$variablesFilePath =  ".\xml\variables.xml",
    [string]$policyConfigPath = ".\xml\output_policy_with_ref.xml",
    [string]$policyConfigPathModified = ".\xml\output_policy_with_ref_vars.xml"
)

if(!(test-path $variablesFilePath))
{
    Write-Host ("Variables file not found - skipping step ({0})" -f $variablesFilePath) -ForegroundColor Red
    return
}

Write-Host "Finding variables..."

$policyConfig = Get-Content -Path $policyConfigPath -Encoding UTF8 | Out-String
[xml]$xmlVariables = Get-Content -Path $variablesFilePath

foreach($v in $xmlVariables.GetElementsByTagName("Variable"))
{
    Write-Host ("Replacing {0} with {1}" -f $v.value, $v.name)
    $policyConfig = $policyConfig.Replace($v.value, $v.name)
}

$policyConfig | Out-File -FilePath $policyConfigPathModified -Encoding UTF8

#Adding variables reference
$varTemplate = @"
<Variables import-file="{0}" />
"@
$filename = Split-Path $variablesFilePath  -leaf
[xml]$policyConfigXml = $policyConfig
$root = $policyConfigXml.SelectSingleNode("/Lithnet.ResourceManagement.ConfigSync")

[xml]$newElem = ($varTemplate -f $filename)
$newElemNode = $policyConfigXml.ImportNode($newElem.Variables, $true)

$root.InsertBefore($newElemNode, $root.FirstChild)

$loc = Get-Location
$joined = Join-Path -Path $loc -ChildPath $policyConfigPathModified
$policyConfigXml.Save($joined)

Write-Host ("Fixed variables in: {0}" -f $policyConfigPathModified)
