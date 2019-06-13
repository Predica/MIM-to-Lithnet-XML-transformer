Function Remove-InvalidFileNameChars {
  param(
    [Parameter(Mandatory=$true,
      Position=0,
      ValueFromPipeline=$true,
      ValueFromPipelineByPropertyName=$true)]
    [String]$Name
  )

  $invalidChars = [IO.Path]::GetInvalidFileNameChars() -join ''
  $re = "[{0}\[\]]" -f [RegEx]::Escape($invalidChars)
  return ($Name -replace $re)
}

#File Path
$policyConfigPath = ".\xml\output_policy_with_ref_vars.xml"
$finalPolicyConfigPath = ".\xml\FINAL output_policy_with_ref_vars_separated.xml"
$outPath = ".\xml"


#### Create Folders for Email Templates #######
$Template = $Null;
$Template = Select-String -Path $policyConfigPath -Pattern "EmailTemplate";

if ($Template -ne $Null) {
    $TemplatePath = $outPath + "\Template";
    If (!(test-path $TemplatePath)) {
        $catch = New-Item -ItemType Directory -Force -Path $TemplatePath
        Write-Host "The new folder for Email Templates created successfully" -ForegroundColor Green
    }
    Else { 
        Write-Host "The Email Template folder already exists"  -ForegroundColor White
    }
}
Else { 
    Write-Host "The Email Template section was not found in the Lithnet file" -ForegroundColor Yellow 
}

#### Create Folders for RCDC #######
$RCDC = $Null;
$RCDC = Select-String -Path $policyConfigPath -Pattern "RCDC";

if ($RCDC -ne $Null) {
    $RCDCPath = $outPath + "\RCDC";
    If (!(test-path $RCDCPath)) {
        $catch = New-Item -ItemType Directory -Force -Path $RCDCPath
        Write-Host "The new folder for RCDC created successfully" -ForegroundColor Green
    }
    Else { 
        Write-Host "The RCDC folder already exists"  -ForegroundColor White
    }
}
Else { 
    Write-Host "The RCDC section was not found in the Lithnet file" -ForegroundColor Yellow 
}

#### Create Folders for Workflows #######
$Workflow = $Null;
$Workflow = Select-String -Path $policyConfigPath -Pattern "WorkflowDefinition";

if ($Workflow -ne $Null) {
    $WorkflowPath = $outPath + "\Workflows";
    If (!(test-path $WorkflowPath)) {
        $catch = New-Item -ItemType Directory -Force -Path $WorkflowPath
        Write-Host "The new folder for Workflows created successfully" -ForegroundColor Green
    }
    Else { 
        Write-Host "The Workflows folder already exists"  -ForegroundColor White
    }
}
Else { 
    Write-Host "The Workflows section was not found in the Lithnet file" -ForegroundColor Yellow 
}

Write-Host " "

#### Extract Email templates, RCDC, WF to separate files  #######
[xml]$xmlSchema = (Get-Content -Path $policyConfigPath -Encoding UTF8 | Out-String);

foreach ($operation in $xmlSchema.'Lithnet.ResourceManagement.ConfigSync'.Operations) {
    if ($operation.ResourceOperation -ne $null -and $operation.ResourceOperation.Count -gt 0) {
        foreach ($resOperation in $operation.ResourceOperation) {
            $xfileName = $resOperation.id;
            if ($resOperation.AttributeOperations -ne $null -and $resOperation.AttributeOperations.AttributeOperation -ne $null) {
                    
                $EmailBody = $resOperation.AttributeOperations.AttributeOperation | Where-Object { $_.name -eq 'EmailBody'};

                if ($EmailBody -ne $null) {

                    Try {
                        $varfilename = Remove-InvalidFileNameChars $xfileName
                        $fpath = $outPath + "\Template\{0}.html" -f $varfilename;
                        $EmailBody."#text"| Set-Content  "$fpath" -Encoding UTF8;  
                        $EmailBody."#text" = ".\Template\$varfilename.html";
                        $typeatt = $EmailBody.OwnerDocument.CreateAttribute("type");
                        $typeatt.Value = "file";
                        $L = $EmailBody.Attributes.Append($typeatt);
                        Write-Host "Exporting Email Template: " $varfilename -ForegroundColor Yellow
                    }
                    Catch {
                        Write-Host "Exporting Email Template - " $varfilename "- failed" -ForegroundColor Red
						Write-Host $_.Exception.Message -ForegroundColor Red
                        Break
                    }
                }

                $RCDC = $resOperation.AttributeOperations.AttributeOperation|Where-Object { $_.name -eq 'ConfigurationData'};

                if ($RCDC -ne $null) {
                    Try {
                        $varfilename = Remove-InvalidFileNameChars $xfileName
                        $fpath = $outPath + "\RCDC\{0}.xml" -f $varfilename
                        $RCDC."#text"| Set-Content "$fpath" -Encoding UTF8; 
                        $RCDC."#text" = ".\RCDC\$varfilename.xml";
						$typeatt = $RCDC.OwnerDocument.CreateAttribute("type");
                        $typeatt.Value = "file";
                        $L = $RCDC.Attributes.Append($typeatt);
                        Write-Host "Exporting RCDC: " $varfilename -ForegroundColor Yellow
                    }
                    Catch {
                        Write-Host "Exporting RCDC - " $varfilename "- failed" -ForegroundColor Red
						Write-Host $_.Exception.Message -ForegroundColor Red
                        Break
                    }
                }

                $WF = $resOperation.AttributeOperations.AttributeOperation|Where-Object { $_.name -eq 'XOML'};

                if ($WF -ne $null) {
                    Try {
                        $varfilename = Remove-InvalidFileNameChars $xfileName
                        $fpath = $outPath + "\Workflows\{0}.xml" -f $varfilename;
                        $WF."#text"| Set-Content "$fpath" -Encoding UTF8; 
                        $WF."#text" = ".\Workflows\$varfilename.xml";
						$typeatt = $WF.OwnerDocument.CreateAttribute("type");
                        $typeatt.Value = "file";
                        $L = $WF.Attributes.Append($typeatt);
                        Write-Host "Exporting Workflow: " $varfilename -ForegroundColor Yellow
                    }
                    Catch {
                        Write-Host "Exporting Workflow - "  $varfilename  "- failed" -ForegroundColor Red
						Write-Host $_.Exception.Message -ForegroundColor Red
                        Break
                    }
                }
            }
        }
    }
}

$loc = Get-Location
$joined = Join-Path -Path $loc -ChildPath $finalPolicyConfigPath
$xmlSchema.Save($joined);

Write-Host " "
Write-Host " "
Write-Host "Email Templates, RCDC and WorkFlows separated successfully" -ForegroundColor Green
