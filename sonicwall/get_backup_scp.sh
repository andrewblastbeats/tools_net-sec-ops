#!/usr/bin/expect
#
# Rules to add to fw
#     1) sudo ufw allow from [src] to any port 22 proto tcp
# If password contains a $, escape using \

# Args from STDIN
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
