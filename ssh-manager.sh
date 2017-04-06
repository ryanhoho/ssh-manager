#!/bin/bash
#########################################
# Original script by Errol Byrd
# Copyright (c) 2010, Errol Byrd <errolbyrd@gmail.com>
#########################################
# Modified by Robin Parisi
# Contact at parisi.robin@gmail.com
# Github https://github.com/robinparisi/ssh-manager
# github.io Page https://robinparisi.github.io/ssh-manager/

##########################################
# Modify by Ryan
# 新增查询命令，新增sftp链接功能，新增密码修改功能
#================== Globals ==================================================

# Version
VERSION="0.6"

# Configuration
HOST_FILE="$HOME/.ssh_servers"
DATA_DELIM=":"
DATA_ALIAS=1
DATA_HUSER=2
DATA_HADDR=3
DATA_HPORT=4
DATA_PASSWD=5
PING_DEFAULT_TTL=20
SSH_DEFAULT_PORT=22

#================== Functions ================================================

function exec_ping() {
	case $(uname) in 
		MINGW*)
			ping -n 1 -i $PING_DEFAULT_TTL $@
			;;
		*)
			ping -c1 -t$PING_DEFAULT_TTL $@
			;;
	esac
}

function test_host() {
	exec_ping $* > /dev/null
	if [ $? != 0 ] ; then
		echo -n "["
		cecho -n -red "KO"
		echo -n "]"
	else
		echo -n "["
		cecho -n -green "UP"
		echo -n "]"
	fi 
}

function separator() {
	echo -e "----\t----\t----\t----\t----\t----\t----\t----"
}

function list_commands() {
	separator
	echo -e "Availables commands"
	separator
	echo -e "$0 ssh\t<alias> [username]\t\tconnect to server"
	echo -e "$0 sftp\t<alias> [username]\t\tconnect to sftp"
	echo -e "$0 add\t<alias>:<user>:<host>:[port]:[password]\tadd new server"
	echo -e "$0 del\t<alias>\t\t\t\tdelete server"
	echo -e "$0 export\t\t\t\t\texport config"
	echo -e "$0 search\t<alias>\t\t\t\tsearch servers by alias"
	echo -e "$0 passwd\t<alias>\tpassword\t\t\t\tmodify password of server"
}

function probe ()
{
	als=$1
	grep -e $als $HOST_FILE > /dev/null
	return $?
}

function get_raw ()
{
	als=$1
	grep -w -e $als $HOST_FILE 2> /dev/null
}

function get_raw_pattern ()
{
	als=$1
	grep -i -s -e $als $HOST_FILE 2> /dev/null
}

function get_addr ()
{
	als=$1
	get_raw "$als" | awk -F "$DATA_DELIM" '{ print $'$DATA_HADDR' }'
}

function get_port ()
{
	als=$1
	get_raw "$als" | awk -F "$DATA_DELIM" '{ print $'$DATA_HPORT'}'
}

function get_user ()
{
	als=$1
	get_raw "$als" | awk -F "$DATA_DELIM" '{ print $'$DATA_HUSER' }'
}

function get_passwd ()
{
	als=$1
	get_raw "$als" | awk -F "$DATA_DELIM" '{ print $'$DATA_PASSWD' }'
}

function server_add() {
	echo add "$alias"
	tmp=$(echo $alias | awk -F ":" '{print $1}')
	probe $(echo "$tmp:")
	if [ $? -eq 0 ]; then
		echo "$0: alias '$tmp' is in use"
	else
		echo "$alias" >> $HOST_FILE
		echo "new alias '$alias' added"
	fi
}


function search_servers () {
	echo "search result for $alias"
	get_raw_pattern "$alias" | while IFS=: read label user ip port password         
	do    
	test_host $ip
	echo -ne "\t"
	cecho -n -blue $label
	echo -ne ' ==> '
	cecho -n -red $user 
	cecho -n -yellow "@"
	cecho -n -white $ip
	echo -ne ' -> '
	if [ "$port" == "" ]; then
		port=$SSH_DEFAULT_PORT
	fi
	cecho -yellow $port
	echo -ne '\t '
	cecho -n -magenta $password
	echo
	done 

}

function modify_password ()
{
	echo "moidfy $alias password to $newpasswd"
	probe "$alias"
	if [ $? == 0 ]; then
		cat $HOST_FILE | sed 's/^\('$alias$DATA_DELIM'\)\(.*\)\('$DATA_DELIM.*'\)/\1\2'$DATA_DELIM$newpasswd'/g' > /tmp/.tmp.$$
		mv /tmp/.tmp.$$ $HOST_FILE
	else
		echo "$0: unknown alias $alias"
	fi
}



function cecho() {
	while [ "$1" ]; do
		case "$1" in 
			-normal)        color="\033[00m" ;;
			-black)         color="\033[30m" ;;
			-red)           color="\033[31m" ;;
			-green)         color="\033[32m" ;;
			-yellow)        color="\033[33m" ;;
			-blue)          color="\033[34m" ;;
			-magenta)       color="\033[35m" ;;
			-cyan)          color="\033[36m" ;;
			-white)         color="\033[37m" ;;
			-n)             one_line=1;   shift ; continue ;;
			*)              echo -n "$1"; shift ; continue ;;
		esac
	shift
	echo -en "$color"
	echo -en "$1"
	echo -en "\033[0m"
	shift
done
if [ ! $one_line ]; then
	echo
fi
}

#=============================================================================

cmd=$1
alias=$2
user=$3

# if config file doesn't exist
if [ ! -f $HOST_FILE ]; then touch "$HOST_FILE"; fi

# without args
if [ $# -eq 0 ]; then
	separator 
	echo "List of availables servers for user $(whoami) "
	separator
	while IFS=$DATA_DELIM read label user ip port password         
	do    
	echo -ne "["
	cecho -n -green "OK"
	echo -ne "]\t"
	cecho -n -blue $label
	echo -ne ' ==> '
	cecho -n -red $user 
	cecho -n -yellow "@"
	cecho -n -white $ip
	echo -ne ' -> '
	if [ "$port" == "" ]; then
		port=$SSH_DEFAULT_PORT
	fi
	cecho -yellow $port
	echo -ne "\t passwd: "
	cecho -n -magenta "$password"
	echo
done < $HOST_FILE

list_commands

exit 0
fi

case "$cmd" in
	# Connect to host
	ssh )
		probe "$alias"
		if [ $? -eq 0 ]; then
			if [ "$user" == ""  ]; then
				user=$(get_user "$alias")
			fi
			addr=$(get_addr "$alias")
			port=$(get_port "$alias")
			password=$(get_passwd "$alias")
			# Use default port when parameter is missing
			if [ "$port" == "" ]; then
				port=$SSH_DEFAULT_PORT
			fi
			echo "connecting to '$alias' ($addr:$port) -passwd $password"
			#ssh $user@$addr -p $port
			basepath=$(cd `dirname $0`; pwd)
			$basepath/connssh.sh "$user" "$addr" "$password"
		else
			echo "$0: unknown alias '$alias'"
			exit 1
		fi
		;;

	sftp )
		probe "$alias"
		if [ $? -eq 0 ]; then
			if [ "$user" == ""  ]; then
				user=$(get_user "$alias")
			fi
			addr=$(get_addr "$alias")
			port=$(get_port "$alias")
			password=$(get_passwd "$alias")
			# Use default port when parameter is missing
			if [ "$port" == "" ]; then
				port=$SSH_DEFAULT_PORT
			fi
			echo "connecting to '$alias' ($user@$addr:$port) -passwd $password"
			#ssh $user@$addr -p $port
			basepath=$(cd `dirname $0`; pwd)
			$basepath/connsftp.sh "$user" "$addr" "$password"
		else
			echo "$0: unknown alias '$alias'"
			exit 1
		fi
		;;

	# Add new alias
	add )
		server_add
		;;
	# Export config
	export )
		echo
		cat $HOST_FILE
		;;

	#search
	search )
		search_servers
		;;
	#modify password
	passwd )
		newpasswd=$3
		modify_password
		;;
	# Delete ali
	del )
		probe "$alias"
		if [ $? -eq 0 ]; then
			cat $HOST_FILE | sed '/^'$alias$DATA_DELIM'/d' > /tmp/.tmp.$$
			mv /tmp/.tmp.$$ $HOST_FILE
			echo "alias '$alias' removed"
		else
			echo "$0: unknown alias '$alias'"
		fi
		;;
	* )
		echo "$0: unrecognised command '$cmd'"
		exit 1
		;;
esac
