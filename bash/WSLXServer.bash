#!/usr/bin/env bash

help()
{
cat <<HELP

	[!] ¡¡ WARNING !! First of All, The X server Installation is needed -->

		XMing --> https://sourceforge.net/projects/xming/

		VcXSrv --> https://sourceforge.net/projects/vcxsrv/

	[*] Description: It Allows to stablish a connection with a X Server

	[*] Syntax: $0 [-f|-x]

	[*] Usage: $0 [-f|-x]

	[*] Options:

		-f --> Stablish Inbound Rules on WSL Network Adapter

		-x --> Set DISPLAY Variable on ${HOME}/.bashrc

		-h --> Display This Help

HELP
}

sigintHandler()
{
	printf "%s\n" "[!] Exiting..." 1>&2
 	trap - SIGINT
  	kill -SIGINT "$$"
}

# WSL NET-ADAPTER FIREWALL RULE ALLOWING ALL INBOUND TRAFFIC
firewall_rule()
{
	/mnt/c/Windows/system32/WindowsPowerShell/v1.0/powershell.exe -Command 'New-NetFirewallRule -DisplayName "WSL" -Direction Inbound  -InterfaceAlias "vEthernet (WSL)"  -Action Allow'
}

# EXTRACT IP ADDRESS WSL INTERFACE FUNCTION
wsl_x_conf()
{
	wsl_ip=$(ip r s | grep -oiP '^default\svia\s\K\d{1,3}(\.\d{1,3}){3}')
	printf "%s\n" "export DISPLAY=${wsl_ip}:0" >> "${HOME}"/.bashrc
}

trap sigintHandler SIGINT

f_flag=false
x_flag=false

while getopts "fxh" arg; do
	case $arg in
 
		f)	f_flag=true
  			;;
     
		x)	x_flag=true
  			;;

		h)	help ; exit 0
  			;;

		*) 	printf "\n\t[!] Undefined Option - %s .Try Again :)\n" "$OPTARG" 1>&2
  			exit 99
     			;;

		?)	printf "\n\t[!] Invalid Option - %s . Try Again :) \n" "$OPTARG" 1>&2
  			exit 1
     			;;
	esac
done

(( $# )) || {
	printf "\n\t[!] Need Arguments...\n" 1>&2
	help
 	exit 99
}

if "$f_flag" ; then

	printf "\n\t[*] Stablishing WSL Firewall Rule...\n"
 
	firewall_rule
 
	printf "\n\t[*] Firewall Rule Stablished --> \n\n"

	/mnt/c/Windows/system32/WindowsPowerShell/v1.0/powershell.exe -Command "Get-NetFirewallRule -DisplayName 'WSL'"

 	echo

fi

if "$x_flag" ; then

	printf "\n\t[*] Setting DISPLAY Variable..."
 
	wsl_x_conf
 
	printf "\n\t[*] DISPLAY Variable Line added on ${HOME}/.bashrc\n"

fi
