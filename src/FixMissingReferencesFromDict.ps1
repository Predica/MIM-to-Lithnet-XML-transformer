$schemaConfigPath = ".\xml\output_schema.xml"
$schemaConfigPathModified = ".\xml\FINAL output_schema_with_ref.xml"

$policyConfigPath = ".\xml\output_policy.xml"
$policyConfigPathModified = ".\xml\output_policy_with_ref.xml"

$policySourceResourceDictPath = ".\xml\dict_policy_source_resource.xml"
$schemaSourceResourceDictPath = ".\xml\dict_schema_source_resource.xml"
$policyTargetResourceDictPath = ".\xml\dict_policy_target_resource.xml"
$schemaTargetResourceDictPath = ".\xml\dict_schema_target_resource.xml"
[xml]$xmlSourcePolicyDict = Get-Content -Path $policySourceResourceDictPath
[xml]$xmlSourceSchemaDict = Get-Content -Path $schemaSourceResourceDictPath
[xml]$xmlTargetPolicyDict = Get-Content -Path $policyTargetResourceDictPath
[xml]$xmlTargetSchemaDict = Get-Content -Path $schemaTargetResourceDictPath

#build obj hash from dictionaries
$objHash = @{}
foreach($obj in $xmlSourceSchemaDict.dict.ResourceManagementObject)
{
    if(-not $objHash.Contains($obj.ObjectIdentifier))
    {
        $objHash.Add($obj.ObjectIdentifier, $obj)
    }
}
foreach($obj in $xmlSourcePolicyDict.dict.ResourceManagementObject)
{
    if(-not $objHash.Contains($obj.ObjectIdentifier))
    {
        $objHash.Add($obj.ObjectIdentifier, $obj)
    }
}
foreach($obj in $xmlTargetSchemaDict.dict.ResourceManagementObject)
{
    if(-not $objHash.Contains($obj.ObjectIdentifier))
    {
        $objHash.Add($obj.ObjectIdentifier, $obj)
    }
}
foreach($obj in $xmlTargetPolicyDict.dict.ResourceManagementObject)
{
    if(-not $objHash.Contains($obj.ObjectIdentifier))
    {
        $objHash.Add($obj.ObjectIdentifier, $obj)
    }
}


$refPattern = "NOT PRESENT IN XML: urn:uuid:[0-9A-Fa-f]{8}[-]([0-9A-Fa-f]{4}[-]){3}[0-9A-Fa-f]{12}"
$missingRefRegex = [regex]::new($refPattern)
$guidInXpathPattern = "['""](([0-9A-Fa-f]{8}[-]([0-9A-Fa-f]{4}[-]){3}[0-9A-Fa-f]{12});?)+['""]"
$guidInXpathRegex = [regex]::new($guidInXpathPattern)

Write-Host "Fixing references in schema..."
$schemaConfig = Get-Content -Path $schemaConfigPath -Encoding UTF8 | Out-String

$matches = $missingRefRegex.Matches($schemaConfig)
foreach($m in $matches)
{
    $id = ($m.Value -split "urn:uuid:")[1]
    $obj = $objHash[$id]
    $refString = ("{0}|{1}|{2}" -f $obj.ObjectType, "Name", $obj.Name)

    $schemaConfig = $schemaConfig.Replace($m.Value, $refString) 
}
$schemaConfig | Out-File -FilePath $schemaConfigPathModified -Encoding UTF8
Write-Host ("Fixed schema in: {0}" -f $schemaConfigPathModified)

Write-Host "Fixing references in policy..."
$policyConfig = Get-Content -Path $policyConfigPath -Encoding UTF8 | Out-String
[xml]$policyConfigXml = $policyConfig

$matches = $missingRefRegex.Matches($policyConfig)
foreach($m in $matches)
{
    $id = ($m.Value -split "urn:uuid:")[1]
    $obj = $objHash[$id]
    $refString = ("{0}|{1}|{2}" -f $obj.ObjectType, "DisplayName", $obj.DisplayName)

    $policyConfig = $policyConfig.Replace($m.Value, $refString)
}

$missingReferencedOperations = @()
$matches = $guidInXpathRegex.Matches($policyConfig)
foreach($m in $matches)
{
    $stringQuoteChar = [string]$m.Value[0]
    $ids = $m.Value.Replace($stringQuoteChar,"")
	#if multiple guids separated by
	$semicolonPresent = $ids.Contains(";")
	$fullRefString = ""
	foreach($id in $ids.Split(';'))
	{
		if($id -ne "" -and $objHash.Contains($id))
		{
			$obj = $objHash[$id]
			#'##xmlref:Set [ProjCode] User Management Users with Deprovision Stage 1:ObjectID##'
			$operationId = ("{0} {1}") -f $obj.ObjectType, $obj.DisplayName.Replace(":","")
			$refString = ("##xmlref:{0}:ObjectID##" -f $operationId)
			$fullRefString += $refString
			if($semicolonPresent)
			{
				$fullRefString += ";"
			}

			#check if operation mentioned by id exists in the xml
			$node = $policyConfigXml.SelectSingleNode("/Lithnet.ResourceManagement.ConfigSync/Operations/ResourceOperation[@id='$operationId']")
			if($node -eq $null)
			{
                if(!($missingReferencedOperations -contains $obj))
                {
				    $missingReferencedOperations += $obj
                }
			}
		}
	}
	if($fullRefString -ne "")
	{
		$fullRefString = ("{0}{1}{2}" -f $stringQuoteChar, $fullRefString, $stringQuoteChar)
		$policyConfig = $policyConfig.Replace($m.Value, $fullRefString)
	}
}
$policyConfig | Out-File -FilePath $policyConfigPathModified -Encoding UTF8


#Adding missing referenced operations if needed
$refOperationTemplate = @"
<ResourceOperation operation="None" resourceType="{0}" id="{1}">
	<AnchorAttributes>
		<AnchorAttribute>DisplayName</AnchorAttribute>
	</AnchorAttributes>
	<AttributeOperations>
		<AttributeOperation operation="none" name="DisplayName">{2}</AttributeOperation>
	</AttributeOperations>
</ResourceOperation>
"@
[xml]$policyConfigXml = $policyConfig
$operations = $policyConfigXml.SelectNodes("/Lithnet.ResourceManagement.ConfigSync/Operations")

foreach($obj in $missingReferencedOperations)
{
    $operationId = ("{0} {1}") -f $obj.ObjectType, $obj.DisplayName.Replace(":","")
    Write-Host "Fixing missing referenced operation: $operationId"
    
    [xml]$newOperation = ($refOperationTemplate -f $obj.ObjectType, $operationId, $obj.DisplayName)
    $newOperationNode = $policyConfigXml.ImportNode($newOperation.ResourceOperation, $true)

    #inserting operation for reference into first Operations node
    $operations[0].InsertAfter($newOperationNode, $operations[0].LastChild) 
} 

$loc = Get-Location
$joined = Join-Path -Path $loc -ChildPath $policyConfigPathModified
$policyConfigXml.Save($joined)

Write-Host ("Fixed policy in: {0}" -f $policyConfigPathModified)
