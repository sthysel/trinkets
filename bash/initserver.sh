#!/bin/bash
# thysm

declare -A USERS=( 
    [frkkie]='(
	[nd_id]=""
	[full_name]=""
	[room_number]=""
	[work_phone]=""
    )'
    [thysm]='(
	[nd_id]=""
	[full_name]="Thys Meintjes" 
	[room_number]=""
	[work_phone]=""
    )'
)

SHELL="/bin/bash"
DEFAULT_PWD="supersecret"


# Exit if not run as root
noRootExit() {
    if [[ ${UID} -ne 0 ]]
    then
      echo "You have to be root to execute this function"
      exit 87
    fi  
}


createSysctlConfFile() {
    SYSCTL=/etc/sysctl.conf

    echo "Creating file: ${SYSCTL}...."

    echo "#" > ${SYSCTL}
    echo "# This file was created by $0 on $(date)" >> ${SYSCTL}
    echo "# ${SYSCTL} - Configuration file for setting system variables" >> ${SYSCTL}
    echo "# See /etc/sysctl.d/ for additional system variables" >> ${SYSCTL}
    echo "# See sysctl.conf (5) for information." >> ${SYSCTL}
    echo "#" >> ${SYSCTL}
    echo "" >> ${SYSCTL}
    echo "kernel.domainname = nd.edu.au" >> ${SYSCTL}
    echo "" >> ${SYSCTL}
    echo "# Uncomment the following to stop low-level messages on console" >> ${SYSCTL}
    echo "#kernel.printk = 3 4 1 3" >> ${SYSCTL}
    echo "" >> ${SYSCTL}
    echo "##############################################################" >> ${SYSCTL}
    echo "# Functions previously found in netbase" >> ${SYSCTL}
    echo "#" >> ${SYSCTL}
    echo "" >> ${SYSCTL}
    echo "# Uncomment the next two lines to enable Spoof protection (reverse-path filter)" >> ${SYSCTL}
    echo "# Turn on Source Address Verification in all interfaces to" >> ${SYSCTL}
    echo "# prevent some spoofing attacks" >> ${SYSCTL}
    echo "net.ipv4.conf.default.rp_filter = 1" >> ${SYSCTL}
    echo "net.ipv4.conf.all.rp_filter = 1" >> ${SYSCTL}
    echo "" >> ${SYSCTL}
    echo "# Uncomment the next line to enable TCP/IP SYN cookies" >> ${SYSCTL}
    echo "# See http://lwn.net/Articles/277146/" >> ${SYSCTL}
    echo "# Note: This may impact IPv6 TCP sessions too" >> ${SYSCTL}
    echo "net.ipv4.tcp_syncookies = 1" >> ${SYSCTL}
    echo "" >> ${SYSCTL}
    echo "# Uncomment the next line to enable packet forwarding for IPv4" >> ${SYSCTL}
    echo "net.ipv4.ip_forward = 1" >> ${SYSCTL}
    echo "" >> ${SYSCTL}
    echo "# Uncomment the next line to enable packet forwarding for IPv6" >> ${SYSCTL}
    echo "#  Enabling this option disables Stateless Address Autoconfiguration" >> ${SYSCTL}
    echo "#  based on Router Advertisements for this host" >> ${SYSCTL}
    echo "net.ipv6.conf.all.forwarding = 1" >> ${SYSCTL}
    echo "" >> ${SYSCTL}
    echo "" >> ${SYSCTL}
    echo "###################################################################" >> ${SYSCTL}
    echo "# Additional settings - these settings can improve the network" >> ${SYSCTL}
    echo "# security of the host and prevent against some network attacks" >> ${SYSCTL}
    echo "# including spoofing attacks and man in the middle attacks through" >> ${SYSCTL}
    echo "# redirection. Some network environments, however, require that these" >> ${SYSCTL}
    echo "# settings are disabled so review and enable them as needed." >> ${SYSCTL}
    echo "#" >> ${SYSCTL}
    echo "# Do not accept ICMP redirects (prevent MITM attacks)" >> ${SYSCTL}
    echo "net.ipv4.conf.all.accept_redirects = 0" >> ${SYSCTL}
    echo "net.ipv6.conf.all.accept_redirects = 0" >> ${SYSCTL}
    echo "# _or_" >> ${SYSCTL}
    echo "# Accept ICMP redirects only for gateways listed in our default" >> ${SYSCTL}
    echo "# gateway list (enabled by default)" >> ${SYSCTL}
    echo "net.ipv4.conf.all.secure_redirects = 1" >> ${SYSCTL}
    echo "#" >> ${SYSCTL}
    echo "# Do not send ICMP redirects (we are not a router)" >> ${SYSCTL}
    echo "net.ipv4.conf.all.send_redirects = 0" >> ${SYSCTL}
    echo "#" >> ${SYSCTL}
    echo "# Do not accept IP source route packets (we are not a router)" >> ${SYSCTL}
    echo "net.ipv4.conf.all.accept_source_route = 0" >> ${SYSCTL}
    echo "net.ipv6.conf.all.accept_source_route = 0" >> ${SYSCTL}
    echo "#" >> ${SYSCTL}
    echo "# Log Martian Packets" >> ${SYSCTL}
    echo "net.ipv4.conf.all.log_martians = 1" >> ${SYSCTL}
    echo "#" >> ${SYSCTL}
    echo "# Disable IPV6" >> ${SYSCTL}
    echo "net.ipv6.conf.all.disable_ipv6 = 1" >> ${SYSCTL}
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> ${SYSCTL}
    echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> ${SYSCTL}
}

createHostsFile() {
    HOSTS=/etc/hosts
    echo "Creating file: hosts..."
    echo "# This file was created by $0 on $(date)" > ${HOSTS}
    echo "127.0.1.1 `uname -n`" >> ${HOSTS}
    cat hosts >> ${HOSTS}
}

createResolvConfFile() {
    RESOLV=/etc/resolv.conf
    echo "Creating file: ${RESOLV}..."
    echo "# This file was created by $0 on $(date)" > ${RESOLV}
    echo "domain klipwerf.com" >> ${RESOLV}
    echo "nameserver 10.10.10.1" >> ${RESOLV}
    echo "search klipwerf.com" >> ${RESOLV}
}

setupHTTPProxy() {
    echo "Adding HTTP Proxy"
    PROFILE=/etc/profilpwerfe
    HTTP_PROXY_ENTRY="export http_proxy=http://proxy:3128"
    grep "$HTTP_PROXY_ENTRY" ${PROFILE} > /dev/null
    if [[ $? -ne 0 ]]
    then
	echo "" >> ${PROFILE}
	echo "# This file was updated by $0 on $(date)" >> ${PROFILE}
        echo "$HTTP_PROXY_ENTRY" >> ${PROFILE}
	source ${PROFILE}
    fi
}

performSystemUpdates() { 
    apt-get update
    apt-get -y upgrade
    apt-get install chkconfig
    apt-get -y autoremove
}

installUsefulTools() {
    TOOLS="subversion git tree openssh-server tmux"
    apt-get install ${TOOLS}
}


deleteAllUsers() {
    noRootExit
    for k in "${!USERS[@]}"
    do
	declare -A user=${USERS[$k]}
	local login=$k
	local fullName=${user[full_name]}
	local NDid=${user[nd_id]}
	
	# delete the user 
	if [[ NDid != 1002 ]]
	then
	    echo "Deleting User: ${fullName} (${login}) "
	    deluser ${login}
	fi
    done
}

addAllGroups() {
    noRootExit
    addgroup java
    addgroup admin
}

addAllUsers() {
    noRootExit
    for k in "${!USERS[@]}"
    do
	declare -A user=${USERS[$k]}
	local login=$k
	local fullName=${user[full_name]}
	local NDid=${user[nd_id]}
	local roomNumber=${user[nd_id]}
	local workPhone=${user[work_phone]}

	# Add the user 
	echo "Adding User: $fullName ($login) id: ${NDid}"
	adduser --uid ${NDid} --shell ${SHELL} --disabled-login --gecos "${fullName},${roomNumber},${workPhone}," ${login}
        echo ${login}:${DEFAULT_PWD} | chpasswd
        passwd --expire ${login}

	# Add the user to admin and java groups
	adduser ${login} "admin"
	adduser ${login} "java"
    done
}


userManagement() {
    # deleteAllUsers
    addAllGroups
    addAllUsers
}

systemSetup() {
    createSysctlConfFile
    createHostsFile
    createResolvConfFile
    setupHTTPProxy
    performSystemUpdates
    installUsefulTools
}

main() {
    userManagement
    systemSetup
}

main
echo "Please log out then in again for changes to the environment to take effect"
exit 0
