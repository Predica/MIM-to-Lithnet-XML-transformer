# What is it?
- It is a mix of XSLT 3.0 (eXtensible Stylesheet Language Transformation) and PowerShell scripts.
- It can resolve references e.g. ##xmlref:Set Administrators:ObjectID##
- It can extract Email Templates, Worklflows and RCDC into separate files (Thank you, Ahmed Saaid!)
- It can replace values in the variable.xml file

# Why  created?
Lithnet Import-RmConfig - great tool for MIM configuration (https://github.com/lithnet/resourcemanagement-powershell/wiki/Configuration-management)
- XML
- Desired State Configuration features
- Designed to make transitioning configuration between environments as seamless as possible
- XML has to be written manually

FIM Configuration Migration PowerShell (https://docs.microsoft.com/en-us/previous-versions/mim/ff400275%28v%3dws.10%29)
- XML
- Standard tool
- Not very user friendly

# What's it for?
You can use it to transform standard MIM XML configuration dump (ExportPolicy.ps1, SyncPolicy.ps1 etc.) into XML files suitable for Lithnet Import-RmConfig.

Use cases:
- To extract current configuration from production to put it back into DEV, UAT etc.
- To extract Lithnet configuration for projects deployed with older techniques (PS scripts)
- To extract config from dev machine, where development was done manually


# How to install it?
- Download it
- Read readme.txt
- Install SaxonHE9-8-0-1N-setup.exe (https://osdn.net/projects/sfnet_saxon/)
- Ensure that path to Saxon in Run.ps1 is correct.

# How to use it?
1. Run ExportSchema.ps1 and ExportPolicy.ps1 on source MIM Service.
1. Run ExportSchema.ps1 and ExportPolicy.ps1 on target MIM Service.
1. Run SyncSchema.ps1 and SyncPolicy.ps1
1. You may use FIMDelta (https://github.com/pieceofsummer/FIMDelta) tool to verify and sanitize policy changes (remove temps, remove unwanted ExplicitMembers etc.)
1. Put 6 output files into xml folder
a. schema.source.xml
b. policy.source.xml
c. schema.target.xml
d. policy.target.xml
e. schema.changes.xml
f. policy.changes.xml
1. Optional - put variables.xml
1. Run!
	
# What to remember?
- The output is separated into Schema and Policy. You can merge it manually, if needed.
- "Resolve" operations are put into final file for reference purposes - if you merge Schema and Policy, some of those references will be rendered useless - you can remove them manually.
- Groups and Custom objects are not present (due to SyncPolicy) - add them manually, if needed.
