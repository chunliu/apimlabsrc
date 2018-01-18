
#
# PowerShell Workflow runbook for Azure Automation. 
# This runbook helps to create multiple APIM instances in parallel
#
workflow APIMCreation-workflow
{
    Param(
        [Parameter (Mandatory= $true)]
        [int]$startIndex,
        [Parameter (Mandatory= $true)]
        [int]$endIndex,
        [string]$apimName = "apimlabsu",
        [string]$uName = "user",
        [string]$domainName = "@apimlabs.onmicrosoft.com",
        [string]$rgName = "apimlabrg",
        [string]$location = "West US",
        [string]$organization = "APIM Labs",
        [string]$sku = "Developer"
    )
    
    # Create APIM instance settings array
    $apimSettings = @()
    for($i = $startIndex; $i -le $endIndex; $i++)
    {
        if($i -lt 10)
        {
            $an = $apimName + "0" + $i
            $email = $uName + "0" + $i + $domainName
            $rn = $rgName + "0" + $i
        }
        else
        {
            $an = $apimName + $i
            $email = $uName + $i + $domainName
            $rn = $rgName + $i                
        }

        $setting = [PSCustomObject]@{
                        PSTypeName = "ApimSettings"
                        ApimName = $an
                        ResourceGroupName = $rn
                        Location = $location
                        Organization = $organization
                        AdminEmail = $email
                        Sku = $sku
                    }
        
        $apimSettings += $setting
    }

    ForEach -Parallel ($apimSetting in $apimSettings)
    {
        InlineScript
        {
            $apimSetting = $Using:apimSetting
            
            # Authenticate to Azure
            $Conn = Get-AutomationConnection -Name AzureRunAsConnection
            Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID `
                -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint
            
            Write-Output "Creating $($apimSetting.ApimName), $($apimSetting.ResourceGroupName), $($apimSetting.AdminEmail)"

            # Create APIM instance
            New-AzureRmApiManagement -ResourceGroupName "$($apimSetting.ResourceGroupName)" `
                -Location "$($apimSetting.Location)" -Name "$($apimSetting.ApimName)" `
                -Organization "$($apimSetting.Organization)" `
                -AdminEmail "$($apimSetting.AdminEmail)" -Sku "$($apimSetting.Sku)"
        }
    }

    Write-Output "Complete"
}