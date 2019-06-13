This scripts can transform default MIM XML configuration into Lithnet XML format suitable for Import-RmConfig.
- It can add necessary xml references for xmlref e.g.
	<ResourceOperation operation="None" resourceType="Set" id="Set Administrators">
      <AnchorAttributes>
        <AnchorAttribute>DisplayName</AnchorAttribute>
      </AnchorAttributes>
      <AttributeOperations>
        <AttributeOperation operation="none" name="DisplayName">Administrators</AttributeOperation>
      </AttributeOperations>
    </ResourceOperation>
- It can resolve references to Lithnet format e.g. ##xmlref:Set Administrators:ObjectID## both in AttributeOperation and in set Filter definitions
	e.g. /Person[(ObjectID != /Set[ObjectID = '##xmlref:Set Administrators:ObjectID##']/ComputedMember) ...
- It can extract Email Templates, Worklflows and RCDC into separate files
- It can replace values from provided Lithnet variables file


- Install prerequisites

	1. \deployment\SaxonHE9-8-0-1N-setup.exe (https://osdn.net/projects/sfnet_saxon/)
	2. Ensure that path to Saxon in Run.ps1 is correct.

- Prepare input files:

	This script needs a delta configuration prepared by standard FIM Configuration Migration PowerShell scripts as an input.
	You can get them from here: https://docs.microsoft.com/en-us/previous-versions/mim/ff400275%28v%3dws.10%29
	You can also find them here: src\FIM Configuration migration powershell scripts

	1. Run ExportSchema.ps1 and ExportPolicy.ps1 on source MIM Service.
	2. Run ExportSchema.ps1 and ExportPolicy.ps1 on target MIM Service.
	3. Run SyncSchema.ps1 and SyncPolicy.ps1

- Put seven files into "xml" folder (this folder should exist in the same folder where Run.ps1 is):

	1. schema.source.xml - schema from the source system
	2. policy.source.xml - policy from the source system
	3. schema.target.xml - schema from the target system
	4. policy.target.xml - policy from the target system
	5. schema.changes.xml - delta between the source and the destination system, the output of SyncSchema.ps1
	6. policy.changes.xml - delta between the source and the destination system, the output of SyncPolicy.ps
	7. (optional) variables.xml - Lithnet variables xml file (<Lithnet.ResourceManagement.ConfigSync.Variables>). Replacing value with name in the output file.

- Execute .\Run.ps1

	Transformation will produce a few additional files in xml folder:

	dict_ files - used as dictionaries to resolve references
	output_schema.xml - schema output, references not resolved
	FINAL output_schema_with_ref.xml - schema output, references resolved 		- FINAL OUTPUT
	output_policy.xml - policy output, references not resolved
	output_policy_with_ref.xml - policy output, references resolved
	output_policy_with_ref_vars.xml - policy output, references resolved, variables replaced
	FINAL output_policy_with_ref_vars_separated.xml - policy output, references resolved, variables replaced, templates, workflows and RCDCs separated		- FINAL OUTPUT


- Enjoy:)
