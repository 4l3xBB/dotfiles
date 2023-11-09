#!/bin/bash

function help(){
cat <<HELP

	[!] ¡¡ WARNING !! First of All, X server Installation is needed -->

		XMing --> https://sourceforge.net/projects/xming/

		VcXSrv --> https://sourceforge.net/projects/vcxsrv/

	[*] Description: Allow Stablish Connection with X Server

	[*] Syntax: ${0} [-f|-x]

	[*] Usage: ${0} [-f|-x]

	[*] Options:

		-f --> Stablish Inbound Rules on WSL Network Adapter

		-x --> Set DISPLAY Variable on ${HOME}/.bashrc

		-h --> Display This Help

HELP
}

function ctrl_c(){
	echo -e "\n\t [!] Exiting...\n"; sleep 3; exit 1
}

trap ctrl_c INT

# WSL NET-ADAPTER FIREWALL RULE ALLOWING ALL INBOUND TRAFFIC

firewall_rule(){

	/mnt/c/Windows/system32/WindowsPowerShell/v1.0/powershell.exe -Command 'New-NetFirewallRule -DisplayName "WSL" -Direction Inbound  -InterfaceAlias "vEthernet (WSL)"  -Action Allow'
}

# EXTRACT IP ADDRESS WSL INTERFACE FUNCTION

wsl_x_conf(){
	wsl_ip=$(ip r s | grep -oiPa '^default\svia\s\K\d{1,3}(\.\d{1,3}){3}')
	echo "export DISPLAY="${wsl_ip}":0" >> "${HOME}"/.bashrc
}

f_flag=false
x_flag=false

while getopts "fxh" arg; do
	case "${arg}" in

		f) f_flag=true;;

		x) x_flag=true;;

		h) help; exit 0;;

		*) echo; echo -e "\t[!] Undefined Option -"${OPTARG}" .Try Again :)\n" >&2; exit 1;;

		?) echo; echo -e "\t[!] Invalid Option -"${OPTARG}". Try Again :)\n" <&2; exit 1;;

	esac
done

if [ "${#}" -eq 0 ]; then

	echo -e "\n\t[!] Need Arguments...\n"
	help; exit 0

fi

if $f_flag; then

	echo -e "\n\t[*] Stablishing WSL Firewall Rule...\n"
	firewall_rule
	echo -e "\n\t[*] Firewall Rule Stablished --> \n\n"

	/mnt/c/Windows/system32/WindowsPowerShell/v1.0/powershell.exe -Command "Get-NetFirewallRule -DisplayName 'WSL'"; echo

fi

if $x_flag; then

	echo -e "\n\t[*] Setting DISPLAY Variable..."
	wsl_x_conf
	echo -e "\n\t[*] DISPLAY Variable Line added on ${HOME}/.bashrc\n"

fi



