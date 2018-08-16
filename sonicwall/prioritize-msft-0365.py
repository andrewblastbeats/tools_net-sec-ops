from urllib.request import urlopen
from bs4 import BeautifulSoup
import xml.etree.ElementTree as ET
import sonicwall_module



def sortProductAddressTypes(child, productName, productAddrTypeList, prodAddrTypeDict):
    i = 1
    addrType = child.attrib['type']
    if addrType == 'IPv4':
        for baby in child:
            if baby.text[-3:] == '/32':
                productAddrTypeList.append([productName, str(i), 'host', baby.text.replace('/32', '')])
                prodAddrTypeDict[productName].append([productName, str(i), 'host', baby.text.replace('/32', '')])
            else:
                productAddrTypeList.append([productName, str(i), addrType, baby.text.replace('/', ' /')])
                prodAddrTypeDict[productName].append([productName, str(i), addrType, baby.text.replace('/', ' /')])
            i += 1
    elif addrType == 'IPv6':
        for baby in child:
            productAddrTypeList.append([productName, str(i), addrType, baby.text.replace('/', ' /')])
            prodAddrTypeDict[productName].append([productName, str(i), addrType, baby.text.replace('/', ' /')])
            i += 1
    else:
        for baby in child:
            productAddrTypeList.append([productName, str(i), addrType, baby.text])
            prodAddrTypeDict[productName].append([productName, str(i), addrType, baby.text])
            i += 1

def buildProductLists(parent, prodNameDict, prodVarNameList, prodsLinkedList):
    for child in parent:
        prodNameDict.update({child.attrib['name']: child})
        prodVarNameList.append(child.attrib['name'])
        prodsLinkedList.append(child)


def downloadFile(file_name):
    # function
    # download the XML file provided by MSFT; be sure to copy old file before new file is dl'd
    url_msft_defns = "https://support.content.office.net/en-us/static/O365IPAddresses.xml"
    # should be a global variable
    file_name = "MSFT-O365IPAddresses.xml"
    filestream_msft_defns = urllib2.urlopen(url_msft_defns)
    file_msft_defns = open(file_name, 'wb')
    meta = u.info()
    file_size = int(meta.getheaders("Content-Length")[0])
    # show download status
    # print ("Downloading: %s Bytes: %s" % (file_name, file_size)

    file_size_dl = 0
    block_size = 8192
    while True:
        buffer = filestream_msft_defns.read(block_size)
        if not buffer:
            break

            file_size_dl += len(buffer)
            file_msft_defns.write(buffer)
            status = r"%10d  [%3.2f%%]" % (file_size_dl, file_size_dl *100. / file_size)
            status = status + chr(8)*(len(status)+1)
            print(status)
    file_msft_defns.close()


# this was for using BS, which appears to not support xml as well as EF
# open xml and give var

# start ES work
# productsLinkedList[0].attrib <> root.getchildren()[0].attrib    (product name)
# productsLinkedList[0].getchildren()[0].attrib                   (addresslist type)
# productsLinkedList[0].getchildren()[0].getchildren()[0].text    (address)
# child of productsLinkList should be a list of  to each address type of the product
# want to

# full product_type list building code, without use of function


def main():
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
        product_dict_ipv4.update({child.attrib['name']: []})
        product_dict_ipv4.update({child.attrib['name']: []})
    for child in productsLinkedList:
        for baby in child:
            if baby.attrib['type'] == 'IPv4':
                if child.attrib['name'] ==
                sortProductAddressTypes(baby, child.attrib['name'], product_ipv4, product_dict_ipv4)
            if baby.attrib['type'] == 'IPv6':
                sortProductAddressTypes(baby, child.attrib['name'], product_ipv6, product_dict_ipv4)
            if baby.attrib['type'] == 'URL':
                sortProductAddressTypes(baby, child.attrib['name'], product_url, product_dict_ipv4)
    # for prods in productNameDict['name']
    with open('sonicwall_addressObj.txt', 'w') as objOut_file, open('sonicwall_addressGroup.txt', 'w') as grpOut_file:
        snwlCreateMSFTo365IPv4AddressObject(productVarNameList, product_ipv4, objOut_file, grpOut_file)
        snwlCreateMSFTo365IPv6AddressObject(productVarNameList, product_ipv6, objOut_file, grpOut_file)
        snwlCreateMSFTo365UrlAddressObject(productVarNameList, product_url, objOut_file, grpOut_file)
