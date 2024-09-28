#!/usr/bin/env bash

getSystemInfo()
{
        local -- _kernel _procKey _procValue \
                 _memKey _memValue _memUsed \
                 _diskInfo \
                 _diskRegex='^((/[a-zA-Z0-9_]+){1,})[[:space:]]+([[:digit:]]{1,}G).*([[:digit:]]{1,3}%)'

        local -A -- _mem

        . /etc/os-release # == source /etc/os-release

        IFS=' ' read -r _ _ _kernel < /proc/version

        while IFS=: read -r _procKey _procValue
        do
                [[ ${_procKey%${_procKey##*[![:space:]]}} == "model name" ]] && break

        done < /proc/cpuinfo

        while IFS=": " read -r _memKey _memValue _
        do
                [[ $_memKey == Mem@(Total|Free) ]] && _mem[$_memKey]=$(( _memValue / 1024 ))

        done < /proc/meminfo

        _memUsed=$(( _mem[MemTotal] - _mem[MemFree] ))

        IFS=$'\n' read -d '' -r _ _diskInfo < <( df -Ph "${PWD:-$( pwd )}" )

        [[ $_diskInfo =~ $_diskRegex ]]

        printf "Hostname:\t\t%s\n" "${HOSTNAME:-$(hostname --long )}"

        printf "Operating System:\t%s\n" "$PRETTY_NAME"

        printf "Kernel Version:\t\t%s\n" "${_kernel%% *}"

        printf "CPU Info:\t\t%s\n" "${_procValue/ }"

        printf "Memory Info:\t\t%sMib / %sMib\n" "$_memUsed" "${_mem[MemTotal]}"

        printf \
                "Disk Info:\t\t%s -> (%s / %s)\n" \
                "${BASH_REMATCH[1]:-NOT FOUND}" \
                "${BASH_REMATCH[-1]:-NOT FOUND}" \
                "${BASH_REMATCH[3]:-NOT FOUND}"
}

getSystemInfo
