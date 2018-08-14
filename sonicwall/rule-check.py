productNameDict = {}
product_ipv4 = []  #[['ProductName', 'SeqNumber', 'AddressType', 'Address']]
product_ipv6 = []  #[['ProductName', 'SeqNumber', 'AddressType', 'Address']]
product_url = []  #[['ProductName', 'SeqNumber', 'AddressType', 'Address']]
productVarNameList = []
product_dict_ipv4 = {}
product_dict_ipv6 = {}
product_dict_url = {}
productsLinkedList = []
file_name = "O365IPAddresses.xml"
# downloadFile(file_name)
xml_in = ET.parse(file_name)
root = xml_in.getroot()
# print(ET.tostring(root, encoding='utf8').decode('utf8'))
buildProductLists(root, productNameDict, productVarNameList, productsLinkedList)
for child in productsLinkedList:
    product_dict_ipv4.update({child.attrib['name']: []})
    product_dict_ipv6.update({child.attrib['name']: []})
    product_dict_url.update({child.attrib['name']: []})
for child in productsLinkedList:
    for baby in child:
        if baby.attrib['type'] == 'IPv4':
            sortProductAddressTypes(baby, child.attrib['name'], product_ipv4, product_dict_ipv4)
        if baby.attrib['type'] == 'IPv6':
            sortProductAddressTypes(baby, child.attrib['name'], product_ipv6, product_dict_ipv6)
        if baby.attrib['type'] == 'URL':
            sortProductAddressTypes(baby, child.attrib['name'], product_url, product_dict_url)
print(product_ipv6[50])
print(product_url[50])
print(productNameDict)
print(str(product_url[50][1]))
with open('sonicwall_addressObj.txt', 'w') as objOut_file, open('sonicwall_addressGroup.txt', 'w') as grpOut_file:
    snwlCreateMSFTo365IPv4AddressObject(productVarNameList, product_ipv4, objOut_file, grpOut_file, product_dict_ipv4)
    snwlCreateMSFTo365IPv6AddressObject(productVarNameList, product_ipv6, objOut_file, grpOut_file, product_dict_ipv6)
    snwlCreateMSFTo365UrlAddressObject(productVarNameList, product_url, objOut_file, grpOut_file, product_dict_url)



#for addr in product_dict_ipv4.items():
for prod, addr in product_dict_ipv4.items():
    if addr != []:
        addrGroup_statement = 'address-group ipv4 AG_MSFT-' + prod + '-IPv4\n'
        f_addrGrp.write(addrGroup_statement)
        for elems in addr:
            print(elems)
            elems[2] = 'ipv4'
            ao_name = 'MSFT-' + elems[0] + '-IPv4-' + elems[1]
            ao_statement = 'address-object ipv4 ' + ao_name + '\n'
            addr_statement = 'network ' + elems[3] + '\n'
            ao_name = 'MSFT-' + elems[0] + '-' + elems[2] + '-' + elems[1]
            ao_statement = 'address-object ipv6 ' + ao_name + '\n'
            f_addrGrp.write(ao_statement)
            f_addrObj.write(ao_statement)
            f_addrObj.write(addr_statement)
            f_addrObj.write(zone_statement)
            f_addrObj.write(exit_statement)
        f_addrGrp.write(exit_statement)
