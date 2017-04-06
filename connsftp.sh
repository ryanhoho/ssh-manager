#!/usr/bin/expect -f
# sftp 链接
#
################################
set user [lindex $argv 0]
set host [lindex $argv 1]
set password [lindex $argv 2]
set timeout 30
 
spawn sftp $user@$host
expect {
"*assword:*" { send "$password\r" }
"(yes/no)?" { send "yes\r";exp_continue }
}
interact
#expect eof

