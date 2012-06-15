#!/bin/bash
# thysm, cleanup
# This script builds the following structure in /opt/ depending on its parameters
# ├── javahome -> /opt/javajdk/jdk1.7.0_04
# ├── javajdk
# │   ├── jdk1.6.0_23
# │   └── jdk1.7.0_04

# Exit codes
E_NOTROOT=87 # Non-root exit error.
E_WRONG_ARGS=85  # Wrong arguments

ARG_COUNT=$# # get the script argument count here early

APPLICATION_ROOT="/opt"
DATA_ROOT="/opt/data"

USER_HOME="/home"
SHELL="/bin/bash"

JAVA_GROUP_ID=61003
    
JAVA_HOME_DIR="/opt/javahome"
JDK_HOME="/opt/javajdk"
JDK_LATEST="latest"

MAJOR_VERSION_THREE="3"
MAJOR_VERSION_FOUR="4"
MAJOR_VERSION_FIVE="5"
MAJOR_VERSION_SIX="6"
MAJOR_VERSION_SEVEN="7"

MAJOR_VERSION_NUMBER=$1
MAJOR_VERSION=1.${MAJOR_VERSION_NUMBER}
MINOR_VERSION=$2
UPDATE_NUMBER=$3

JAVA_VERSION=${MAJOR_VERSION}.${MINOR_VERSION}

SQL_SERVER_JDBC_DRIVER="sqljdbc4.jar"
SYBASE_ASE_JDBC_DRIVER="jconn4.jar"
FIREBIRD_JDBC_DRIVER="jaybird-full-2.1.6.jar"
JTDS_JDBC_DRIVER="jtds-1.2.5.jar"
TIME_ZONE_UPDATE_UTILITY="tzupdater.jar"

MACHINE=$(uname -m)
MACHINE_X86="i686"
MACHINE_X64="amd64"
ARCHITECTURE_X86="i586"
ARCHITECTURE_X64="x64"

INSTALL_API_DOCS="$4"
INSTALL_AS_LATEST="$5"


# currently all binaries are co-located with this script
SCRIPT_PATH=.
setScriptPath() {
    if [[ -L $0 ]]
    then
        ME=$(readlink $0)
    else
        ME=$0
    fi
    SCRIPT_PATH=$(dirname $ME)
}
setScriptPath

# folder paths into assembled JDK
# the archive the jdk ships in is named, say 7u4, but it extracts to jdk1.7.0_04.
# We can rename the binary, or fix like below
if [[ ${#UPDATE_NUMBER} = 1 ]]
then
    FIXED_UPDATE_NUMBER=0${UPDATE_NUMBER}
else
    FIXED_UPDATE_NUMBER=${UPDATE_NUMBER}
fi

TARGET_ASSEMBLY_NAME=jdk${JAVA_VERSION}_${FIXED_UPDATE_NUMBER}
INSTALL_TREE_ROOT=${SCRIPT_PATH}/${TARGET_ASSEMBLY_NAME}
JAVA_EXT_FOLDER=${INSTALL_TREE_ROOT}/jre/lib/ext/

if [[ ${MACHINE} = ${MACHINE_X86} ]]
    then ARCHITECTURE=${ARCHITECTURE_X86}
    else ARCHITECTURE=${ARCHITECTURE_X64}
fi

printUsage() {
    echo "Usage: $0 <Major Version Number> <Minor Version> <Update Number> <Install API docs (Y|N)> <Install as current (Y|N)>"
    echo "Example: $0 7 0 4 N N"
    echo ""
}

isRoot() {
    if [[ ${UID} -ne 0 ]]
    then
      echo "You have to be root to install the assembled JDK"
      exit $E_NOTROOT
    fi  
}

printArgs() {
    echo "Architecture: ${ARCHITECTURE}"
    echo "Major version: ${MAJOR_VERSION_NUMBER}"
    echo "Minor Version: ${MINOR_VERSION}"
    echo "Update Number: ${UPDATE_NUMBER}"
    echo "Java Version: ${JAVA_VERSION}"
    echo "Install Docs: ${INSTALL_API_DOCS}"
    echo "Make current: ${INSTALL_AS_LATEST}"
}

validateArgs() {
    echo Validating arguments
    if [[ ${ARG_COUNT} -lt 5 ]]
	then
	    echo "Error: incorrect invocation of this script"
	    printArgs
	    echo ""
	    printUsage
	    exit ${E_WRONG_ARGS}
    fi
}

makeDirectories() {
    DIRECTORIES="${APPLICATION_ROOT} ${DATA_ROOT} ${JDK_HOME}"
    echo "Making target directories: ${DIRECTORIES}"
    for d in ${DIRECTORIES}
    do
        mkdir -p $d
        if (( $? != 0 ))
        then
            echo "WARNING: Failed to make directory $d"
        else
            echo "Created $d"
        fi
        
    done
}

setEnvironment() {
    ENVFILE=/etc/profile.d/java_environment.sh
    BASHRC=/etc/bash.bashrc
    echo "Setting up Environment Variables. Adding profile to ${ENVFILE}"
    echo "export JAVA_HOME=${JAVA_HOME_DIR}" > ${ENVFILE}
    echo "export PATH=JAVA_HOME/bin:$PATH" >> ${ENVFILE}
    chmod a+x ${ENVFILE}

    BASH_RC_ENTRY=". ${ENVFILE}"
    if ! [[ $(grep "${BASH_RC_ENTRY}" ${BASHRC}) ]]
        then
	    echo "Adding ${BASH_RC_ENTRY} to ${BASHRC}"
	    echo "" >> ${BASHRC}
	    echo "# Added by $0 at $(date)" >> ${BASHRC}
            echo "${BASH_RC_ENTRY}" >> ${BASHRC}
    fi
}

addJDKVersion3To6() {
    echo "Installing JDK < 7 in ${INSTALL_TREE_ROOT}"
    chmod a+x ./jdk-${MAJOR_VERSION_NUMBER}u${UPDATE_NUMBER}-linux-${ARCHITECTURE}.bin
    ./jdk-${MAJOR_VERSION_NUMBER}u${UPDATE_NUMBER}-linux-${ARCHITECTURE}.bin
    unzip ./jce_policy-${MAJOR_VERSION_NUMBER}.zip -d ./
    cp ./jce/local_policy.jar ${INSTALL_TREE_ROOT}/jre/lib/security/
    cp ./jce/US_export_policy.jar ${INSTALL_TREE_ROOT}/jre/lib/security/
    rm -rf ./jce
}

addJDKVersion7() {
    echo "Extracting JDK >= 7 in ${INSTALL_TREE_ROOT}"
    SECURITY_FOLDER=${INSTALL_TREE_ROOT}/jre/lib/security/
    tar -zxf ./jdk-${MAJOR_VERSION_NUMBER}u${UPDATE_NUMBER}-linux-${ARCHITECTURE}.tar.gz

    # Install Java Cryptography Extentions
    unzip ./UnlimitedJCEPolicyJDK${MAJOR_VERSION_NUMBER}.zip -d ./
    cp -v ./UnlimitedJCEPolicy/local_policy.jar ${SECURITY_FOLDER}
    cp -v ./UnlimitedJCEPolicy/US_export_policy.jar ${SECURITY_FOLDER}
    rm -rf ./UnlimitedJCEPolicy
}

addJDKTree() {
    echo "Preparing installation tree..."
    case ${MAJOR_VERSION_NUMBER} in 
        ${MAJOR_VERSION_THREE}) 
            addJDKVersion3To6
            ;; 
        ${MAJOR_VERSION_FOUR}) 
            addJDKVersion3To6
            ;; 
        ${MAJOR_VERSION_FIVE}) 
            addJDKVersion3To6
            ;;
        ${MAJOR_VERSION_SIX})
            addJDKVersion3To6
            ;; 
        ${MAJOR_VERSION_SEVEN}) 
            addJDKVersion7 
            ;;
    esac
}


setupDerbyDB() {
    echo "Change Java DB to point to Derby Installed Instances"
    # note this script does not actually install derby here, so the link could be broken
    rm -rf ${INSTALL_TREE_ROOT}/db
    ln -s /usr/derby ${INSTALL_TREE_ROOT}/db
}

addAPIDocos() {
    DOCFILE=./jdk-${MAJOR_VERSION_NUMBER}u${UPDATE_NUMBER}-apidocs.zip
    echo "Installing API Documentation"
    if [[ ${INSTALL_API_DOCS} = "Y" ]]
        then 
	    if [[ -f ${DOCFILE} ]]
	    then
		unzip -q ${DOCFILE}
		rm -rf ${INSTALL_TREE_ROOT}/docs
		mv docs ${INSTALL_TREE_ROOT}/    
	    else
		echo "WARNING: Documentation was marked for installation but the file ${DOCFILE} does not exist"
	    fi
    fi
}

addJDBCDrivers() {
    echo "Installing JDBC Drivers"
    cp ./${SQL_SERVER_JDBC_DRIVER} ${JAVA_EXT_FOLDER}
    #cp ./${JTDS_JDBC_DRIVER} ${JAVA_EXT_FOLDER}
    cp ./${SYBASE_ASE_JDBC_DRIVER} ${JAVA_EXT_FOLDER}
    cp ./${FIREBIRD_JDBC_DRIVER} ${JAVA_EXT_FOLDER}
}

addTimezoneSupport() {
    echo "Installing the Time Zone Update Utility"
    cp ./${TIME_ZONE_UPDATE_UTILITY} ${JAVA_EXT_FOLDER}
}

moveAssembledJDKToJDKInstances() {
    echo "Remove existing instances, if they exist, and move in the new instance"
    rm -rf ${JDK_HOME}/${TARGET_ASSEMBLY_NAME}
    mv ${INSTALL_TREE_ROOT} ${JDK_HOME}/

    echo "Changing the version being run on the system to be the one being installed"
    if [[ ${INSTALL_AS_LATEST} = "Y" ]]
        then 
            unlink ${JAVA_HOME_DIR}
            ln -s ${JDK_HOME}/${TARGET_ASSEMBLY_NAME} ${JAVA_HOME_DIR}
    fi
}

setSecurity() {
    echo "User and Group Creation"
    groupadd --gid 61003 "java"

    echo "Set permissions On The Java Instances"
    chown -R root:java ${JDK_HOME}
    chown -R root:java ${JAVA_HOME_DIR} 
    chmod -R 770 ${JDK_HOME}
}


assemble() {
    echo "Assembling JDK tree in ${SCRIPT_PATH}"
    cd ${SCRIPT_PATH}
    addJDKTree
    addJDBCDrivers
    addAPIDocos
    addTimezoneSupport
}

installJDK() {
    echo "Installing assembled JDK"
    isRoot
    makeDirectories
    moveAssembledJDKToJDKInstances
    setupDerbyDB
    setSecurity
    setEnvironment
    echo "Please log out then in again for changes to the environment to take effect"
}

main() {
    validateArgs
    printArgs
    assemble
    installJDK
}

main
exit 
