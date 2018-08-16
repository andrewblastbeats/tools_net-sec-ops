# module to support sonicwall operations, connections, defined objects, etc

# class SnwlAddressObject:

# name convention:
#   MSFT-ProductName-AddressType-SeqNum-
#   MSFT-WAC-IPv4-01

# info
def snwlCreateMSFTo365IPv4AddressObject(productList, prodAddrTypeList, f_addrObj, f_addrGrp, prodDict):
    zone_statement = 'zone WAN\n'
    exit_statement = 'exit\n'
    for prod, addr in prodDict.items():
        if addr != []:
            addrGroup_statement = 'address-group ipv4 AG_MSFT-' + prod + '-IPv4\n'
            f_addrGrp.write(addrGroup_statement)
            if elems[2] == 'host':
                for elems in addr:
                    ao_name = 'MSFT-' + elems[0] + '-IPv4-' + elems[1]
                    ao_statement = 'address-object host ' + ao_name + '\n'
                    addr_statement = 'host ' + elems[3] + '\n'
                    f_addrGrp.write(ao_statement)
                    f_addrObj.write(ao_statement)
                    f_addrObj.write(addr_statement)
                    f_addrObj.write(zone_statement)
                    f_addrObj.write(exit_statement)
                f_addrGrp.write(exit_statement)
            else:
                for elems in addr:
                    ao_name = 'MSFT-' + elems[0] + '-IPv4-' + elems[1]
                    ao_statement = 'address-object ipv4 ' + ao_name + '\n'
                    addr_statement = 'network ' + elems[3] + '\n'
                    f_addrGrp.write(ao_statement)
                    f_addrObj.write(ao_statement)
                    f_addrObj.write(addr_statement)
                    f_addrObj.write(zone_statement)
                    f_addrObj.write(exit_statement)
                f_addrGrp.write(exit_statement)
    '''for addr in prodAddrTypeList:
        addr[1][2] = 'ipv4'
        ao_name = 'MSFT-' + addr[1][0] + '-IPv4-' + str(addr[1][1])
        ao_statement = 'address-object ipv4 ' + str(ao_name) + '\n'
        addr_statement = 'network ' + str(addr[1][3]) + '\n'
        f_addrObj.write(ao_statement)
        f_addrObj.write(addr_statement)
        f_addrObj.write(zone_statement)
        f_addrObj.write(exit_statement)
    for prod in productList:
        addrGroup_statement = 'address-group ipv4 AG_MSFT-' + prod + '-IPv4\n'
        f_addrGrp.write(addrGroup_statement)
        for addr in prodAddrTypeList:
            if prod == addr[0]:
                ao_name = 'MSFT-' + addr[0] + '-' + addr[2] + '-' + addr[1]
                ao_statement = 'address-object ipv4 ' + ao_name + '\n'
                f_addrGrp.write(ao_statement)
        f_addrGrp.write('exit\n')'''


def snwlCreateMSFTo365IPv6AddressObject(productList, prodAddrTypeList, f_addrObj, f_addrGrp, prodDict):
    zone_statement = 'zone WAN\n'
    exit_statement = 'exit\n'
    for prod, addr in prodDict.items():
        if addr != []:
            addrGroup_statement = 'address-group ipv6 AG_MSFT-' + prod + '-IPv6\n'
            f_addrGrp.write(addrGroup_statement)
            for elems in addr:
                elems[2] = 'ipv6'
                ao_name = 'MSFT-' + elems[0] + '-IPv6-' + elems[1]
                ao_statement = 'address-object ipv6 ' + ao_name + '\n'
                addr_statement = 'network ' + elems[3] + '\n'
                f_addrGrp.write(ao_statement)
                f_addrObj.write(ao_statement)
                f_addrObj.write(addr_statement)
                f_addrObj.write(zone_statement)
                f_addrObj.write(exit_statement)
            f_addrGrp.write(exit_statement)
    '''for addr in prodAddrTypeList:
        addr[2] = 'ipv6'
        ao_name = 'MSFT-' + addr[0] + '-IPv6-' + addr[1]
        ao_statement = 'address-object ipv6 ' + ao_name + '\n'
        addr_statement = 'network ' + addr[3] + '\n'
        f_addrObj.write(ao_statement)
        f_addrObj.write(addr_statement)
        f_addrObj.write(zone_statement)
        f_addrObj.write(exit_statement)
    addrType = 'ipv6'
    for prod in productList:
        addrGroup_statement = 'address-group ipv6 AG_MSFT-' + prod + '-IPv6\n'
        f_addrGrp.write(addrGroup_statement)
        for addr in prodAddrTypeList:
            if prod == addr[0]:
                ao_name = 'MSFT-' + addr[0] + '-' + addr[2] + '-' + addr[1]
                ao_statement = 'address-object ipv6 ' + ao_name + '\n'
                f_addrGrp.write(ao_statement)
        f_addrGrp.write('exit\n')'''


def snwlCreateMSFTo365UrlAddressObject(productList, prodAddrTypeList, f_addrObj, f_addrGrp, prodDict):
    zone_statement = 'zone WAN\n'
    exit_statement = 'exit\n'
    for prod, addr in prodDict.items():
        if addr != []:
            addrGroup_statement = 'address-group fqdn AG_MSFT-' + prod + '-FQDN\n'
            f_addrGrp.write(addrGroup_statement)
            for elems in addr:
                elems[2] = 'fqdn'
                ao_name = 'MSFT-' + elems[0] + '-FQDN-' + elems[1]
                ao_statement = 'address-object fqdn ' + ao_name + '\n'
                addr_statement = 'domain ' + elems[3] + '\n'
                f_addrGrp.write(ao_statement)
                f_addrObj.write(ao_statement)
                f_addrObj.write(addr_statement)
                f_addrObj.write(zone_statement)
                f_addrObj.write(exit_statement)
            f_addrGrp.write(exit_statement)
    '''for addr in prodAddrTypeList:
        addr[2] = 'fqdn'
        ao_name = 'MSFT-' + addr[0] + '-FQDN-' + addr[1]
        ao_statement = 'address-object fdqn ' + ao_name + '\n'
        addr_statement = 'domain ' + addr[3] + '\n'
        f_addrObj.write(ao_statement)
        f_addrObj.write(addr_statement)
        f_addrObj.write(zone_statement)
        f_addrObj.write(exit_statement)
    for prod in productList:
        addrGroup_statement = 'address-group fqdn AG_MSFT-' + prod + '-FQDN\n'
        f_addrGrp.write(addrGroup_statement)
        for addr in prodAddrTypeList:
            if prod == addr[0]:
                ao_name = 'MSFT-' + addr[0] + '-' + addr[2] + '-' + addr[1]
                ao_statement = 'address-object fqdn ' + ao_name + '\n'
                f_addrGrp.write(ao_statement)
        f_addrGrp.write('exit\n')'''


def snwlCreateMSFTAddressGroups(productList, prodDict, f_addrGrp):



def snwlCreateGenericIPv4AddressObject(addrObjName, addrObjectType, f_addrObj):
    print(addrObjName)


#def snwlCreateBandwidthObject()
