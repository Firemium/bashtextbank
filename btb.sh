#!/bin/bash

#    data storage manager - bash text bank
#    Copyright (C) 2021  lazypwny751
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Define Variables
btb_file_extension="btb"
btb_cwd="${PWD}"
btb_name="$(basename ${BASH_SOURCE[0]})"

_file-name() {
    # Alternative filename function
    # If the filename command is not installed
    # This function without the need to install packages
    # get an alternative parser with we will.

    if [[ "${#}" -gt 0 ]] ; then
        if ! command -v filename &> /dev/null ; then
            for y in $(seq 1 ${#}) ; do
                echo ${@:y:1} | tr "/" " " | awk '{print $NF}'
            done
        else
            filename ${@}
        fi
    else
        echo -e "Usage: Enter 1 parameter file/directory path. Sample\n> _file-name /tmp/test/test.sh\n< test.sh"
        return 1
    fi
}

_btbui() {
    case "${1}" in
        [fF][aA][tT][aA][lL]|--[fF][aA][tT][aA][lL]|-[fF])
            echo -e "\033[1;31mFatal: ${2}!\033[0m"
            return 1
        ;;
        [eE][rR][rR][oO][rR]|--[eE][rR][rR][oO][rR]|-[eE])
            echo -e "\033[1;31merror\033[0m: ${2}.\033[0m"
            [[ ! -z "${3}" ]] && return "${3}"
        ;;
        [sS][uU][cC][cC][sS][eE][sS][sS]|--[sS][uU][cC][cC][sS][eE][sS][sS]|-[sS])
            echo -e "\033[1;32msuccess\033[0m: ${2}.\033[0m"
        ;;
        [iI][nN][fF][oO]|--[iI][nN][fF][oO]|-[iI])
            echo -e "\033[1;35minfo\033[0m: ${2}.\033[0m"
        ;;
    esac
}

# Bash Text Bank Tmp Manager
_btbtmpm() {
    case "${1}" in
        [oO][pP][eE][nN]|--[oO][pP][eE][nN]|-[oO])
            if ! [[ -d "/tmp/${btb_name}" ]] ; then
                mkdir -p "/tmp/${btb_name}" || _btbui --fatal "${btb_name} could not creating"
            fi
        ;;
        [cC][lL][oO][sS][eE]|--[cC][lL][oO][sS][eE]|-[cC])
            if [[ -d "/tmp/${btb_name}" ]] ; then
                rm -rf "/tmp/${btb_name}" || _btbui --fatal "${btb_name} could not removed"
            fi
        ;;
        [cC][oO][mM][pP][rR][eE][sS][sS]|--[cC][oO][mM][pP][rR][eE][sS][sS]|-[cC][rR])
            if [[ -f "/tmp/${btb_name}/metafile" ]] ; then
                cd "/tmp/${btb_name}" # change directory to btb temp dir
                . metafile # source the bank metadata file
                tar -zcf "${btb_cwd}/${btb_bank}.${btb_file_extension}" ./* && _btbui --success "${btb_bank} compressed" || _btbui --error "the bank is can not compressing" "1"
                rm -rf "/tmp/${btb_name}" # remove old dir
                cd "${btb_cwd}" # change directory to current working directory
            else
                _btbui --error "metafile not found" "1"
            fi
        ;;
        [eE][xX][tT][rR][aA][cC][tT]|--[eE][xX][tT][rR][aA][cC][tT]|-[eE])
            if [[ $(file "${2}" | grep "gzip compressed data") ]] && [[ ! -d "/tmp/${btb_name}" ]] ; then
                mkdir -p "/tmp/${btb_name}" && cp "${2}" "/tmp/${btb_name}" || _btbui --fatal "${btb_name} could not creating"
                cd "/tmp/${btb_name}"
                tar -xf "$(_file-name ${2})" # extract old bank
                rm "$(_file-name ${2})" # remove old bank
                . metafile # source the metadata file of bank
            fi
        ;;
    esac
}

# Define Functions
_req:btb() {
    _btbtmpm --close
    if ! [[ $(command -v gzip) ]] ; then
        echo "gzip not found!"
        return 1
    fi

    if ! [[ $(command -v tar) ]] ; then
        echo "tar not found!"
        return 1
    fi
}

_req:btb

# Generate bank, base, data (null)
btb:generate() {
    case "${1}" in
        [bB][aA][nN][kK]|--[bB][aA][nN][kK]|-[bB])
            [[ -z "${2}" ]] && btb_bank="artemis" || btb_bank="${2}"
            _btbtmpm --open
            echo "btb_bank='${btb_bank}'" > "/tmp/${btb_name}/metafile"
            _btbtmpm --compress
        ;;
        [bB][aA][sS][eE]|--[bB][aA][sS][eE]|-[bB])
            if [[ $(tar -ztf "${2}" | grep -w "metafile") ]] 2> /dev/null && [[ "${#}" -ge 3 ]] ; then
                _btbtmpm --extract "${2}"
                for i in ${@:3} ; do
                    mkdir "${i}" 2> /dev/null && _btbui --succsess "${i} created" || _btbui --info "${i} is already exist"
                done
                _btbtmpm --compress
            else
                if [[ "${#}" -lt 3 ]] ; then
                    _btbui --error "wrong argument usage" "1"
                else
                    _btbui --error "the file ${2} isn't bash text bank" "1"
                fi
            fi
        ;;
        [dD][aA][tT[aA]|--[dD][aA][tT[aA]|-[dD])
            :
        ;;
        [hH][eE][lL][pP]|--[hH][eE][lL][pP]|-[hH])
            echo "Wiht the function '${FUNCNAME[0]}' you can create 'bank', 'base' and null 'data'

${FUNCNAME[0]} --bank <bank name>:
    create a new bank.

${FUNCNAME[0]} --base <bank file name> <base name 1> <base name 2> <base name 3>..:
    create bases in any bank

${FUNCNAME[0]} --data
"
        ;;
        *)
            echo "Wrong usage: Type '${FUNCNAME[0]} --help' to learn more information."
            return 1
        ;;
    esac
}

# Generate and write, rewrite or add tail of data 
btb:write() {
    :
}

# Remove base or data
btb:remove() {
    :
}

# Check if exist base, data
btb:check() {
    :
}

# Print if exist data
btb:print() {
    :
}

# Call base number, data number, list base and list data
btb:call_value() {
    :
}

# All help texts is here
btb:help() {
    :
}