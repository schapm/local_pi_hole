#!/bin/bash
set -e # exit on error

# author: schapm
# github.com/schapm/local_pi_hole

readonly HOSTS_FILE="/etc/hosts"
readonly HOSTS_BACKUP="${HOSTS_FILE}.backup"
readonly GITHUB_HOSTS_SOURCE="https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
readonly SCRIPT_NAME="$(basename "$0")"

func::notify_users() {
    readonly title="$1"
    readonly message="$2"
    readonly urgency="${2:-normal}"

    # notify all dbus-daemon processes that create session bus
    for dbus_session in "$(ps -eo user,args | grep "dbus-daemon.*--address=unix" | grep -v grep)"; do
        user="$(echo "${dbus_session}" | cut -d' ' -f 1)"
        bus_addr="$(echo "${dbus_session}" | sed 's/^.*--address=//;s/ .*$//' | cut -d "/" -f 1-4)/bus"
        # set dbus var & notify current user
        DBUS_SESSION_BUS_ADDRESS="$bus_addr" sudo -u $user -E /usr/bin/notify-send -u "$urgency" "$title" "$message"
    done
}

func::root_check() {
    if (( $(id -u) != 0 )); then
        echo "${SCRIPT_NAME}: run as root user" && func::notify_users "${SCRIPT_NAME}: run as root user"
        exit 1
    fi
}

func::check_hosts_source_conn() {
    if [[ ! $(curl --connect-timeout 10 -Is ${GITHUB_HOSTS_SOURCE} | head -1 | grep "200") ]]; then
        echo "${SCRIPT_NAME}: no connection to Github" && func::notify_users "${SCRIPT_NAME}: no connection to Github"
        exit 2
    fi
}

func::backup_hosts() {
    if [[ -f ${HOSTS_FILE} ]]; then
        cp ${HOSTS_FILE} ${HOSTS_BACKUP}
        echo "${SCRIPT_NAME}: backed up existing hosts file to ${HOSTS_BACKUP}"
    fi
}

func::update() {
    curl -sSL ${GITHUB_HOSTS_SOURCE} > ${HOSTS_FILE}
    echo "${SCRIPT_NAME}: ${HOSTS_FILE} updated" && func::notify_users "${SCRIPT_NAME}: ${HOSTS_FILE} updated"
}

###############################################################################
####################################[ MAIN ]###################################
###############################################################################

func::root_check
func::check_hosts_source_conn
func::backup_hosts
func::update
        
# EOF