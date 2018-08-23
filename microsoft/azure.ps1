Connect-AzureRmAccount
Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionId ''
$vmParams = @{
  ResourceGroupName = $resourceGroupName
  Name = $vmName
  ImageName = 'Win2016Datacenter'
  PublicIpAddressName = ''
  Credential = $cred
  OpenPorts = 3389
}

New-AzureRmVirtualNetworkGateway -Name vnetgw1 -ResourceGroupName testrg `
-Location 'West US' -IpConfigurations $gwipconfig -GatewayType Vpn `
-VpnType RouteBased
