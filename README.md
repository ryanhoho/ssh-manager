# SSH Manager


A simple script to manage ssh connections on *inx ( Such as UNIX, Linux, Mac OS, etc)

![screenshot](https://github.com/robinparisi/ssh-manager/raw/master/screenshot.png)

## 基础介绍

    在原脚本基础上做了一定的调整。
    1. 去除了机器状态ping功能
    2. 可以管理密码，并自动链接
    3. 新增了sftp链接
    4. 修改密码

    [ryan@heshiweideMacBook-Pro ~ ]$ rssh
    ----    ----    ----    ----    ----    ----    ----    ----
    List of availables servers for user ryan
    ----    ----    ----    ----    ----    ----    ----    ----
    [OK]    test1 ==> root@192.186.1.8 -> 22     passwd: 123456
    [OK]    test ==> root@192.168.1.8 -> 22  passwd: 123456
    ----    ----    ----    ----    ----    ----    ----    ----
    Availables commands
    ----    ----    ----    ----    ----    ----    ----    ----
    /Users/ryan/Workspace/RemoteServers/ssh-manager/ssh-manager.sh ssh  <alias> [username]      connect to server
    /Users/ryan/Workspace/RemoteServers/ssh-manager/ssh-manager.sh sftp <alias> [username]      connect to sftp
    /Users/ryan/Workspace/RemoteServers/ssh-manager/ssh-manager.sh add  <alias>:<user>:<host>:[port]:[password] add new server
    /Users/ryan/Workspace/RemoteServers/ssh-manager/ssh-manager.sh del  <alias>             delete server
    /Users/ryan/Workspace/RemoteServers/ssh-manager/ssh-manager.sh export                   export config
    /Users/ryan/Workspace/RemoteServers/ssh-manager/ssh-manager.sh search   <alias>             search servers by alias
    /Users/ryan/Workspace/RemoteServers/ssh-manager/ssh-manager.sh passwd   <alias> password                modify password of server
    [ryan@heshiweideMacBook-Pro ~ ]$ cat .ssh_servers
    test1:root:192.186.1.8::123456
    test:root:192.168.1.8::123456
    [ryan@heshiweideMacBook-Pro ~ ]$


## Installation

    $ cd ~
    $ git clone https://github.com/ryanhoho/ssh-manager.git
    $ cd ssh-manager
    $ chmod +x ssh-manager.sh
    $ ./ssh-manager.sh
    
For more convenience, you can create an alias into your .bashrc, .zshrc, etc...

For example :

    alias rssh="/Users/robin/ssh-manager.sh"

## Use

    ssh  <alias>                        
    add <alias>:<user>:<host>:[port]:[password]             
    del <alias>             
    passwd <alias> newpassword
    search <alias>                         
    export                                           

### Authors and Contributors

Original script by Errol Byrd
Copyright (c) 2010, Errol Byrd 

Modified by Robin Parisi (@robinparisi)

Modifyed by Ryan
