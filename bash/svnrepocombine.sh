#!/bin/bash
# thysm

NEWREPO=$(pwd)/ndmcms
NEWREPOCO="${NEWREPO}_co"
DUMPS=repodumps
REV="0:HEAD"
REPOROOT=/data/svn/2.2.1/repositories/
TOOLDIR=/opt/svn/2.2.1/bin/
PATH=${PATH}:${TOOLDIR}

# Repo mapping 
declare -A REPOS=( 
    [CMSEntityBeans]='(
        [newname]="EntityBeans"
    )'
    [CMSSpreadsheetImportServlet]='(
        [newname]="SpreadsheetImportServlet"
    )'
    [CMSSpreadsheetMappingXML]='(
        [newname]="SpreadsheetMappingXML"
    )'
    [CMSSpreadsheetImportProcess]='(
        [newname]="SpreadsheetImportProcess"
    )'
    [CMSSpreadsheetMappingProcess]='(
        [newname]="SpreadsheetMappingProcess"
    )'
    [CMSystemWeb]='(
        [newname]="Web"
    )'
    [CMSSystemBeans]='(
        [newname]="Beans"
    )'
)


dump() {
    rm -fr ${DUMPS}
    mkdir ${DUMPS}
    for repo in "${!REPOS[@]}"
    do
        local dumpfile=${DUMPS}/${repo}.dmp
    echo "Dumpimg Repo ${repo} to ${dumpfile}"
        svnadmin dump -r ${REV} ${REPOROOT}/${repo} > ${dumpfile}
    done
}

loadRepos() {
    # new big repo
    rm -fr ${NEWREPO}
    svnadmin create ${NEWREPO}
    svn mkdir file:///${NEWREPO}/trunk -m ""
    svn mkdir file:///${NEWREPO}/branches -m ""
    svn mkdir file:///${NEWREPO}/tags -m ""

    # add the old projects as modules
    for currentname in "${!REPOS[@]}"
    do  
        declare -A repo=${REPOS[$currentname]}
        local newname=${repo[newname]}
        echo "Loading repo ${currentname} soon to be ${newname}"
        dumpfile=${DUMPS}/${currentname}.dmp
        
        # import the current repo into a trmporary root position
        svn mkdir file:///${NEWREPO}/${currentname} -m "Made module ${currentname}"
        svnadmin load --parent-dir ${currentname} ${NEWREPO} < ${dumpfile}

        # now move stuff arround
        # first rename to new repo
        svn move file:///${NEWREPO}/${currentname} file:///${NEWREPO}/${newname} -m "Moved ${currentname} to ${newname}"
	# move trunk
        svn move file:///${NEWREPO}/${newname}/trunk file:///${NEWREPO}/trunk/${newname} -m "Done by $0"
        # now move branches and tags to a pre-merge directory
        for vc in {branches,tags}
        do
            echo "Moving the current content of $vc into ${NEWREPO}/${vc}/${newname}"
            svn move file:///${NEWREPO}/${newname}/${vc} file:///${NEWREPO}/${vc}/${newname} -m "Done by $0"
        done
    svn rm  file:///${NEWREPO}/${newname} -m "Removed old ${newname}"
    done
}

dump
loadRepos
