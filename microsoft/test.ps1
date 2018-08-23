<#
 .SYNOPSIS
  Example of DMZ and User Defined Routing in an isolated network (Azure only, no hybrid connections)

 .DESCRIPTION
  This script will build out a sample DMZ setup containing:
   - A default storage account for VM disks
   - Three new cloud services
   - Three Subnets (SecNet, FrontEnd, and BackEnd subnets)
   - A Network Virtual Appliance (NVA), in this case a Barracuda NextGen Firewall
   - One server on the FrontEnd Subnet
   - Three Servers on the BackEnd Subnet
   - IP Forwading from the FireWall out to the internet
   - User Defined Routing FrontEnd and BackEnd Subnets to the NVA

  Before running script, ensure the network configuration file is created in
  the directory referenced by $NetworkConfigFile variable (or update the
  variable to reflect the path and file name of the config file being used).

 .Notes
  Everyone's security requirements are different and can be addressed in a myriad of ways.
  Please be sure that any sensitive data or applications are behind the appropriate
  layer(s) of protection. This script serves as an example of some of the techniques
  that can be used, but should not be used for all scenarios. You are responsible to
  assess your security needs and the appropriate protections needed, and then effectively
  implement those protections.

  Security Service (SecNet subnet 10.0.0.0/24)
   myFirewall - 10.0.0.4

  FrontEnd Service (FrontEnd subnet 10.0.1.0/24)
   IIS01      - 10.0.1.4

  BackEnd Service (BackEnd subnet 10.0.2.0/24)
   DNS01      - 10.0.2.4
   AppVM01    - 10.0.2.5
   AppVM02    - 10.0.2.6

#>

# Fixed Variables
    $LocalAdminPwd = Read-Host -Prompt "Enter Local Admin Password to be used for all VMs"
    $VMName = @()
    $ServiceName = @()
    $VMFamily = @()
    $img = @()
    $size = @()
    $SubnetName = @()
    $VMIP = @()

# User Defined Global Variables
  # These should be changes to reflect your subscription and services
  # Invalid options will fail in the validation section

  # Subscription Access Details
    $subID = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  # VM Account, Location, and Storage Details
    $LocalAdmin = "theAdmin"
    $DeploymentLocation = "Central US"
    $StorageAccountName = "vmstore02"

  # Service Details
    $SecureService = "SecSvc001"
    $FrontEndService = "FrontEnd001"
    $BackEndService = "BackEnd001"

  # Network Details
    $VNetName = "CorpNetwork"
    $VNetPrefix = "10.0.0.0/16"
    $SecNet = "SecNet"
    $FESubnet = "FrontEnd"
    $FEPrefix = "10.0.1.0/24"
    $BESubnet = "BackEnd"
    $BEPrefix = "10.0.2.0/24"
    $NetworkConfigFile = "C:\Scripts\NetworkConf3.xml"

  # VM Base Disk Image Details
    $SrvImg = Get-AzureVMImage | Where {$_.ImageFamily -match 'Windows Server 2012 R2 Datacenter'} | sort PublishedDate -Descending | Select ImageName -First 1 | ForEach {$_.ImageName}
    $FWImg = Get-AzureVMImage | Where {$_.ImageFamily -match 'Barracuda NextGen Firewall'} | sort PublishedDate -Descending | Select ImageName -First 1 | ForEach {$_.ImageName}

  # UDR Details
    $FERouteTableName = "FrontEndSubnetRouteTable"
    $BERouteTableName = "BackEndSubnetRouteTable"

  # NSG Details
    $NSGName = "MyVNetSG"

# User Defined VM Specific Config
    # Note: To ensure UDR and IP forwarding is setup
    # properly this script requires VM 0 be the NVA.

    # VM 0 - The Network Virtual Appliance (NVA)
      $VMName += "myFirewall"
      $ServiceName += $SecureService
      $VMFamily += "Firewall"
      $img += $FWImg
      $size += "Small"
      $SubnetName += $SecNet
      $VMIP += "10.0.0.4"

    # VM 1 - The Web Server
      $VMName += "IIS01"
      $ServiceName += $FrontEndService
      $VMFamily += "Windows"
      $img += $SrvImg
      $size += "Standard_D3"
      $SubnetName += $FESubnet
      $VMIP += "10.0.1.4"

    # VM 2 - The First Appliaction Server
      $VMName += "AppVM01"
      $ServiceName += $BackEndService
      $VMFamily += "Windows"
      $img += $SrvImg
      $size += "Standard_D3"
      $SubnetName += $BESubnet
      $VMIP += "10.0.2.5"

    # VM 3 - The Second Appliaction Server
      $VMName += "AppVM02"
      $ServiceName += $BackEndService
      $VMFamily += "Windows"
      $img += $SrvImg
      $size += "Standard_D3"
      $SubnetName += $BESubnet
      $VMIP += "10.0.2.6"

    # VM 4 - The DNS Server
      $VMName += "DNS01"
      $ServiceName += $BackEndService
      $VMFamily += "Windows"
      $img += $SrvImg
      $size += "Standard_D3"
      $SubnetName += $BESubnet
      $VMIP += "10.0.2.4"

# ----------------------------- #
# No User Defined Varibles or   #
# Configuration past this point #
# ----------------------------- #

  # Get your Azure accounts
    Add-AzureAccount
    Set-AzureSubscription –SubscriptionId $subID -ErrorAction Stop
    Select-AzureSubscription -SubscriptionId $subID -Current -ErrorAction Stop

  # Create Storage Account
    If (Test-AzureName -Storage -Name $StorageAccountName) {
        Write-Host "Fatal Error: This storage account name is already in use, please pick a diffrent name." -ForegroundColor Red
        Return}
    Else {Write-Host "Creating Storage Account" -ForegroundColor Cyan
          New-AzureStorageAccount -Location $DeploymentLocation -StorageAccountName $StorageAccountName}

  # Update Subscription Pointer to New Storage Account
    Write-Host "Updating Subscription Pointer to New Storage Account" -ForegroundColor Cyan
    Set-AzureSubscription –SubscriptionId $subID -CurrentStorageAccountName $StorageAccountName -ErrorAction Stop

# Validation
$FatalError = $false

If (-Not (Get-AzureLocation | Where {$_.DisplayName -eq $DeploymentLocation})) {
     Write-Host "This Azure Location was not found or available for use" -ForegroundColor Yellow
     $FatalError = $true}

If (Test-AzureName -Service -Name $SecureService) {
    Write-Host "The SecureService service name is already in use, please pick a different service name." -ForegroundColor Yellow
    $FatalError = $true}
Else { Write-Host "The FrontEndService service name is valid for use." -ForegroundColor Green}

If (Test-AzureName -Service -Name $FrontEndService) {
    Write-Host "The FrontEndService service name is already in use, please pick a different service name." -ForegroundColor Yellow
    $FatalError = $true}
Else { Write-Host "The FrontEndService service name is valid for use" -ForegroundColor Green}

If (Test-AzureName -Service -Name $BackEndService) {
    Write-Host "The BackEndService service name is already in use, please pick a different service name." -ForegroundColor Yellow
    $FatalError = $true}
Else { Write-Host "The BackEndService service name is valid for use." -ForegroundColor Green}

If (-Not (Test-Path $NetworkConfigFile)) {
    Write-Host 'The network config file was not found, please update the $NetworkConfigFile variable to point to the network config xml file.' -ForegroundColor Yellow
    $FatalError = $true}
Else { Write-Host "The network config file was found" -ForegroundColor Green
        If (-Not (Select-String -Pattern $DeploymentLocation -Path $NetworkConfigFile)) {
            Write-Host 'The deployment location was not found in the network config file, please check the network config file to ensure the $DeploymentLocation varible is correct and the netowrk config file matches.' -ForegroundColor Yellow
            $FatalError = $true}
        Else { Write-Host "The deployment location was found in the network config file." -ForegroundColor Green}}

If ($FatalError) {
    Write-Host "A fatal error has occured, please see the above messages for more information." -ForegroundColor Red
    Return}
Else { Write-Host "Validation passed, now building the environment." -ForegroundColor Green}

# Create VNET
    Write-Host "Creating VNET" -ForegroundColor Cyan
    Set-AzureVNetConfig -ConfigurationPath $NetworkConfigFile -ErrorAction Stop

# Create Services
    Write-Host "Creating Services" -ForegroundColor Cyan
    New-AzureService -Location $DeploymentLocation -ServiceName $SecureService -ErrorAction Stop
    New-AzureService -Location $DeploymentLocation -ServiceName $FrontEndService -ErrorAction Stop
    New-AzureService -Location $DeploymentLocation -ServiceName $BackEndService -ErrorAction Stop

# Build VMs
    $i=0
    $VMName | Foreach {
        Write-Host "Building $($VMName[$i])" -ForegroundColor Cyan
        If ($VMFamily[$i] -eq "Firewall")
            {
            New-AzureVMConfig -Name $VMName[$i] -ImageName $img[$i] –InstanceSize $size[$i] | `
                Add-AzureProvisioningConfig -Linux -LinuxUser $LocalAdmin -Password $LocalAdminPwd  | `
                Set-AzureSubnet  –SubnetNames $SubnetName[$i] | `
                Set-AzureStaticVNetIP -IPAddress $VMIP[$i] | `
                New-AzureVM –ServiceName $ServiceName[$i] -VNetName $VNetName -Location $DeploymentLocation
            # Set up all the EndPoints we'll need once we're up and running
            # Note: All traffic goes through the firewall, so we'll need to set up all ports here.
            #       Also, the firewall will be redirecting traffic to a new IP and Port in a forwarding
            #       rule, so all of these endpoint have the same public and local port and the firewall
            #       will do the mapping, NATing, and/or redirection as declared in the firewall rules.
            Add-AzureEndpoint -Name "MgmtPort1" -Protocol tcp -PublicPort 801  -LocalPort 801  -VM (Get-AzureVM -ServiceName $ServiceName[$i] -Name $VMName[$i]) | Update-AzureVM
            Add-AzureEndpoint -Name "MgmtPort2" -Protocol tcp -PublicPort 807  -LocalPort 807  -VM (Get-AzureVM -ServiceName $ServiceName[$i] -Name $VMName[$i]) | Update-AzureVM
            Add-AzureEndpoint -Name "HTTP"      -Protocol tcp -PublicPort 80   -LocalPort 80   -VM (Get-AzureVM -ServiceName $ServiceName[$i] -Name $VMName[$i]) | Update-AzureVM
            Add-AzureEndpoint -Name "RDPWeb"    -Protocol tcp -PublicPort 8014 -LocalPort 8014 -VM (Get-AzureVM -ServiceName $ServiceName[$i] -Name $VMName[$i]) | Update-AzureVM
            Add-AzureEndpoint -Name "RDPApp1"   -Protocol tcp -PublicPort 8025 -LocalPort 8025 -VM (Get-AzureVM -ServiceName $ServiceName[$i] -Name $VMName[$i]) | Update-AzureVM
            Add-AzureEndpoint -Name "RDPApp2"   -Protocol tcp -PublicPort 8026 -LocalPort 8026 -VM (Get-AzureVM -ServiceName $ServiceName[$i] -Name $VMName[$i]) | Update-AzureVM
            Add-AzureEndpoint -Name "RDPDNS01"  -Protocol tcp -PublicPort 8024 -LocalPort 8024 -VM (Get-AzureVM -ServiceName $ServiceName[$i] -Name $VMName[$i]) | Update-AzureVM
            # Note: A SSH endpoint is automatically created on port 22 when the appliance is created.
            }
        Else
            {
            New-AzureVMConfig -Name $VMName[$i] -ImageName $img[$i] –InstanceSize $size[$i] | `
                Add-AzureProvisioningConfig -Windows -AdminUsername $LocalAdmin -Password $LocalAdminPwd  | `
                Set-AzureSubnet  –SubnetNames $SubnetName[$i] | `
                Set-AzureStaticVNetIP -IPAddress $VMIP[$i] | `
                Set-AzureVMMicrosoftAntimalwareExtension -AntimalwareConfiguration '{"AntimalwareEnabled" : true}' | `
                Remove-AzureEndpoint -Name "RemoteDesktop" | `
                Remove-AzureEndpoint -Name "PowerShell" | `
                New-AzureVM –ServiceName $ServiceName[$i] -VNetName $VNetName -Location $DeploymentLocation
            }
        $i++
    }

# Configure UDR and IP Forwarding
    Write-Host "Configuring UDR" -ForegroundColor Cyan

  # Create the Route Tables
    Write-Host "Creating the Route Tables" -ForegroundColor Cyan
    New-AzureRouteTable -Name $BERouteTableName `
        -Location $DeploymentLocation `
        -Label "Route table for $BESubnet subnet"
    New-AzureRouteTable -Name $FERouteTableName `
        -Location $DeploymentLocation `
        -Label "Route table for $FESubnet subnet"

  # Add Routes to Route Tables
    Write-Host "Adding Routes to the Route Tables" -ForegroundColor Cyan
    Get-AzureRouteTable $BERouteTableName `
        |Set-AzureRoute -RouteName "All traffic to FW" -AddressPrefix 0.0.0.0/0 `
        -NextHopType VirtualAppliance `
        -NextHopIpAddress $VMIP[0]
    Get-AzureRouteTable $BERouteTableName `
        |Set-AzureRoute -RouteName "Internal traffic to FW" -AddressPrefix $VNetPrefix `
        -NextHopType VirtualAppliance `
        -NextHopIpAddress $VMIP[0]
    Get-AzureRouteTable $BERouteTableName `
        |Set-AzureRoute -RouteName "Allow Intra-Subnet Traffic" -AddressPrefix $BEPrefix `
        -NextHopType VNETLocal
    Get-AzureRouteTable $FERouteTableName `
        |Set-AzureRoute -RouteName "All traffic to FW" -AddressPrefix 0.0.0.0/0 `
        -NextHopType VirtualAppliance `
        -NextHopIpAddress $VMIP[0]
    Get-AzureRouteTable $FERouteTableName `
        |Set-AzureRoute -RouteName "Internal traffic to FW" -AddressPrefix $VNetPrefix `
        -NextHopType VirtualAppliance `
        -NextHopIpAddress $VMIP[0]
    Get-AzureRouteTable $FERouteTableName `
        |Set-AzureRoute -RouteName "Allow Intra-Subnet Traffic" -AddressPrefix $FEPrefix `
        -NextHopType VNETLocal

  # Assoicate the Route Tables with the Subnets
    Write-Host "Binding Route Tables to the Subnets" -ForegroundColor Cyan
    Set-AzureSubnetRouteTable -VirtualNetworkName $VNetName `
        -SubnetName $BESubnet `
        -RouteTableName $BERouteTableName
    Set-AzureSubnetRouteTable -VirtualNetworkName $VNetName `
        -SubnetName $FESubnet `
        -RouteTableName $FERouteTableName

 # Enable IP Forwarding on the Virtual Appliance
    Get-AzureVM -Name $VMName[0] -ServiceName $ServiceName[0] `
        |Set-AzureIPForwarding -Enable

# Configure NSG
    Write-Host "Configuring the Network Security Group (NSG)" -ForegroundColor Cyan

  # Build the NSG
    Write-Host "Building the NSG" -ForegroundColor Cyan
    New-AzureNetworkSecurityGroup -Name $NSGName -Location $DeploymentLocation -Label "Security group for $VNetName subnets in $DeploymentLocation"

  # Add NSG Rule
    Write-Host "Writing rules into the NSG" -ForegroundColor Cyan
    Get-AzureNetworkSecurityGroup -Name $NSGName | Set-AzureNetworkSecurityRule -Name "Isolate the $VNetName VNet from the Internet" -Type Inbound -Priority 100 -Action Deny `
        -SourceAddressPrefix INTERNET -SourcePortRange '*' `
        -DestinationAddressPrefix VIRTUAL_NETWORK -DestinationPortRange '*' `
        -Protocol *

  # Assign the NSG to two Subnets
    # The NSG is *not* bound to the Security Subnet. The result
    # is that internet traffic flows only to the Security subnet
    # since the NSG bound to the Frontend and Backback subnets
    # will Deny internet traffic to those subnets.
    Write-Host "Binding the NSG to two subnets" -ForegroundColor Cyan
    Set-AzureNetworkSecurityGroupToSubnet -Name $NSGName -SubnetName $FESubnet -VirtualNetworkName $VNetName
    Set-AzureNetworkSecurityGroupToSubnet -Name $NSGName -SubnetName $BESubnet -VirtualNetworkName $VNetName

# Optional Post-script Manual Configuration
  # Configure Firewall
  # Install Test Web App (Run Post-Build Script on the IIS Server)
  # Install Backend resource (Run Post-Build Script on the AppVM01)
  Write-Host
  Write-Host "Build Complete!" -ForegroundColor Green
  Write-Host
  Write-Host "Optional Post-script Manual Configuration Steps" -ForegroundColor Gray
  Write-Host " - Configure Firewall" -ForegroundColor Gray
  Write-Host " - Install Test Web App (Run Post-Build Script on the IIS Server)" -ForegroundColor Gray
  Write-Host " - Install Backend resource (Run Post-Build Script on the AppVM01)" -ForegroundColor Gray
  Write-Host
