Function Get-HostUptime 
{
    param ([string]$ComputerName)
    $Uptime = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $ComputerName
    $LastBootUpTime = $Uptime.ConvertToDateTime($Uptime.LastBootUpTime)
    $Time = (Get-Date) - $LastBootUpTime
    Return '{0:00} Days, {1:00} Hours, {2:00} Minutes, {3:00} Seconds' -f $Time.Days, $Time.Hours, $Time.Minutes, $Time.Seconds
}

Function Test-AzureRMAccountTokenExpiry
{
	# Credit James Rooke    
	[CmdletBinding()]
	Param 
	(
		
	)
	
	$TokenExpiredOrDoesNotExist = $false
    try
    {
        $TokenCache = [Microsoft.IdentityModel.Clients.ActiveDirectory.TokenCache]::DefaultShared
        $ContextTenantId = [Microsoft.WindowsAzure.Commands.Common.AzureRMProfileProvider]::Instance.Profile.Context.Tenant.Id.Guid
        $TenantToken = $TokenCache.ReadItems() | Where-Object { $_.TenantId -eq $ContextTenantId }
        $CurrentDateTime = Get-Date
        Write-Verbose "Context Tenant Token ExpiresOn: $($TenantToken.ExpiresOn)"
        Write-Verbose "Current DateTime in UTC: $($CurrentDateTime.ToUniversalTime())"
        if ($TenantToken.ExpiresOn -lt $CurrentDateTime)
        {
            Write-Verbose "Tenant Token has expired, calling Add-AzureRmAccount"
            $TokenExpiredOrDoesNotExist = $true
        }
        else
        {
            Write-Verbose "Tenant Token is still valid"
        }
    }
    catch [System.Management.Automation.RuntimeException]
    {
        $TokenExpiredOrDoesNotExist = $true
    }
 
    if ($TokenExpiredorDoesNotExist) { 
		try 
		{
			Add-AzureRmAccount
		}
		catch
		{
			Write-Warning "Error"
			break
		}
		Finally
		{
		
		}
	}
}

Function Connect-AzureRunAsConnection
{
	#Credit Keith Ellis
	[CmdletBinding()]
	Param 
	(
		
	)
	Write-Output ("Prepare Azure Connection")
	$connectionName = "AzureRunAsConnection"
	try
	{
	    # Get the connection "AzureRunAsConnection "
	    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

	    #"Logging in to Azure..."
	    Add-AzureRmAccount `
	        -ServicePrincipal `
	        -TenantId $servicePrincipalConnection.TenantId `
	        -ApplicationId $servicePrincipalConnection.ApplicationId `
	        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint | Out-Null 
	}
	catch {
	    if (!$servicePrincipalConnection)
	    {
	        $ErrorMessage = "Connection $connectionName not found."
	        throw $ErrorMessage
	    } else{
	        Write-Error -Message $_.Exception
	        throw $_.Exception
	    }
	}
}

Function List-ReportsAll
{
	Write-Warning "In development"
	Pause
	$reports = (Get-Command run-report*) 
    foreach ($report in $reports) 
    {Write-output  $report}
}

Function Run-ReportsAll
{
	param
	(
		$ReportPath
	)
 
 	Write-Warning "In development"
	Pause
	$Reports = @(Get-Command run-report*)
	foreach ($Report in $Reports )
	{
		Write-output ("running.... " + $Report.Source)
		. $Report.Source -reportPath $ReportPath
	}
}

