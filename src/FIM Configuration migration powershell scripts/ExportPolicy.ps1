# ExportPolicy.ps1
# Copyright © 2009 Microsoft Corporation

# The purpose of this script is to export the current policy and synchronization configuration in the pilot environment.

# The script stores the configuration into file "policy.xml" in the current directory.
# Please note you will need to rename the file to Pilot_policy.xml or production_policy.xml.
# See the documentation for more information.

if(@(get-pssnapin | where-object {$_.Name -eq "FIMAutomation"} ).count -eq 0) {add-pssnapin FIMAutomation}

$policy_filename = "policy.xml"
Write-Host "Exporting configuration objects from pilot."
# In many production environments, some Set resources are larger than the default message size of 10 MB.
$policy = Export-FIMConfig -policyConfig -portalConfig -MessageSize 9999999
if ($policy -eq $null)
{
    Write-Host "Export did not successfully retrieve configuration from FIM.  Please review any error messages and ensure that the arguments to Export-FIMConfig are correct."
}
else
{
    Write-Host "Exported " $policy.Count " objects from pilot."
    $policy | ConvertFrom-FIMResource -file $policy_filename
    Write-Host "Pilot file is saved as " $policy_filename "."
    if($policy.Count -gt 0)
    {
        Write-Host "Export complete.  The next step is run SyncPolicy.ps1."
    }
    else
    {
        Write-Host "While export completed, there were no resources.  Please ensure that the arguments to Export-FIMConfig are correct."
    }
}