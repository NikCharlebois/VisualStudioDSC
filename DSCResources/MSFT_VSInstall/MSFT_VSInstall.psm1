function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]  
        [System.String] 
        $ExecutablePath,

        [parameter(Mandatory = $false)] 
        [System.String[]] 
        $Workloads,
    
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present"
    )
    Write-Verbose -Message "Detecting a previous installation of Visual Studio"

    $x86Path = "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $installedItemsX86 = Get-ItemProperty -Path $x86Path | Select-Object -Property DisplayName
    
    $x64Path = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $installedItemsX64 = Get-ItemProperty -Path $x64Path | Select-Object -Property DisplayName

    $installedItems = $installedItemsX86 + $installedItemsX64 
    $installedItems = $installedItems | Select-Object -Property DisplayName -Unique    
    $spInstall = $installedItems | Where-Object -FilterScript { 
        $_ -match "Microsoft Visual Studio 2017" 
    }
    
    if ($spInstall) 
    {
        return @{
            ExecutablePath = $ExecutablePath
            Workloads = $Workloads
            Ensure = "Present"
        }
    } 
    else 
    {
        return @{
            ExecutablePath = $ExecutablePath
            Workloads = $Workloads
            Ensure = "Absent"
        }
    }
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]  
        [System.String] 
        $ExecutablePath,
    
        [parameter(Mandatory = $false)] 
        [System.String[]] 
        $Workloads,
    
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present"
    )
    
    Write-Verbose -Message "Installing Visual Studio 2017"

    $installer = Get-Item -Path $ExecutablePath

    if($installer)
    {
        $workloadArgs = ""
        foreach($workload in $Workloads)
        {
            $workloadArgs += " --add $workload"
        }
        Start-Process -FilePath $ExecutablePath -ArgumentList ("--quiet" + $workloadArgs) -Wait -PassThru
    }
    else{
        throw "The Installer could not be found at $ExecutablePath"
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]  
        [System.String] 
        $ExecutablePath,

        [parameter(Mandatory = $false)] 
        [System.String[]] 
        $Workloads,
    
        [ValidateSet("Present","Absent")]
        [System.String]
        $Ensure = "Present"
    )
    Write-Verbose -Message "Checking to see if Visual Studio 2017 is installed"
    $x86Path = "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $installedItemsX86 = Get-ItemProperty -Path $x86Path | Select-Object -Property DisplayName
    
    $x64Path = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    $installedItemsX64 = Get-ItemProperty -Path $x64Path | Select-Object -Property DisplayName

    $installedItems = $installedItemsX86 + $installedItemsX64 
    $installedItems = $installedItems | Select-Object -Property DisplayName -Unique    
    $spInstall = $installedItems | Where-Object -FilterScript { 
        $_ -match "Microsoft Visual Studio 2017" 
    }

    if($spInstall)
    {
	    return $true;
    }
    else
    {
    	return $false;
    }
}

Export-ModuleMember -Function *-TargetResource