import csv
from paramiko import client

class ssh:
    client = none


    def __init__(self, address, username, password):
        print('Connecting to the SonicWALL.')
        self.client = client.SSHClient()
        self.client.set_missing_host_key_policy(client.AutoAddPolicy())
        self.client.connect(address, username=username, password=password, look_for_keys=False)


    def sendCommand(self, command):

sonicwall_list = []
file_name = "sonicwall-backup-inventory.csv"
with open(file_name, 'r') as csv_in:
    csv_reader = csv.reader(csv_in, delimiter=';')
    for row in csv_reader:
        sonicwall_list.append(row)

sonicwall_list_header = sonicwall_list.pop(0)
bkup_ip = sonicwall_list[0][5]
for sonicwall in sonicwall_list:
    snwl_name = sonicwall[0]
    snwl_host_lan = sonicwall[2]
    snwl_username = sonicwall[3]
    snwl_password = sonicwall[4]
    bkup_protocol = sonicwall[6]
    bkup_username = sonicwall[7]
    bkup_password = sonicwall[8]
    if bkup_protocol == 'ftp':
        print('ftp')
    if bkup_protocol == 'scp':
        print('scp')
    get_backup_shellscript = subprocess.Popen(['get_backup_ftp.sh'], stdin=get_backup_shellscript.PIPE)

set host [lindex $argv 0]
set password [lindex $argv 1]
set cityCountry [lindex $argv 2]
set username [lindex $argv 3]
set scp_s_user [lindex $argv 4]
set scp_s_pass [lindex $argv 5]
set scp_server [lindex $argv 5]
set date [clock format [clock seconds] -format %Y%m%d]


set ssh_switch1 "-oKexAlgorithms=diffie-hellman-group1-sha1"
set ssh_switch2 "-oStrictHostKeyChecking=no"
set file_name_prefix "SNWL_CC-"

# SonicWALL CLI config
set user_pattern "User:"
set password_pattern "*?assword:"
set exit_command "exit"
set newline "\n"
set top_prompt "*>"
set config_prompt "#"

# Establish SSH to SNWL
spawn ssh $ssh_switch1 $ssh_switch2 $username@$host
expect {
  "(yes/no)?" {
    sleep 1
    send "yes$newline"
    #exp_continue
  }
}

# log into SonicWALL CLI interface
expect "$password_pattern"
send -- "$password$newline"
expect "$top_prompt"

# Export to SCP
send "export current-config cli scp scp://$scp_s_user@$scp_server/$file_name_prefix$cityCountry-$date.txt $newline"
expect {
  -- "*(yes/no)?" {
    sleep 1
    send "yes$newline"
  }
}
expect "$password_pattern"
send "$scp_s_pass$newline"
sleep 1
expect "$top_prompt"
send "exit"
