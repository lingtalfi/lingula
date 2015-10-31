#!/bin/bash

############################################################
# GOAL: 
# This task does many things:
# -- it makes an archive (.tar) of the given application and  
#           puts that archive into the temporary depository
# -- it tarballs (.tar.gz) the content of the temporary depository
# -- it puts the tarball to the depository
# -- it creates a general symbolic link to that tarball 
#
#
############################################################
# The format of the given VALUE is the location of the 
# application directory that we want to tarball.
#       
#       path/to/application
############################################################
startTask "tarballs"





tmp_depository_path="${CONFIG[tmp_depository_path]}"
depository_path="${CONFIG[depository_path]}/$project"
targetDir="$VALUE"






############################################################
# Checking basic values
############################################################



if ! [ -d "$tmp_depository_path" ]; then
    mkdir -p "$tmp_depository_path"
fi
if ! [ -d "$depository_path" ]; then
    mkdir -p "$depository_path"
fi
ok=1
if [ ! -d "$targetDir" ]; then
    ok=0
    error "tarballs: targetDir not found: $targetDir"
fi
if ! [ -d "$tmp_depository_path" ]; then
    ok=0
    error "tarballs: Couldn't create the temporary depository dir ($tmp_depository_path)"
fi
if ! [ -d "$depository_path" ]; then
    ok=0
    error "tarballs: Couldn't create the depository dir ($depository_path)"
fi
    
if [ 1 -eq $ok ]; then

    
    oldDir="$(pwd)"
    
    
    ############################################################
    # First, we create the archive and place it in the temporary directory  
    ############################################################
    projectDir=$(dirname "$targetDir")
    projectDirName="${targetDir##*/}"
    cd "$projectDir"
    
    
    ############################################################
    # Regular Mode
    # we create an archive out of the project files,
    # and put the archive in the tmp directory
    ############################################################
    dst="$tmp_depository_path/${projectDirName}.tar"
    
    log "tarballs: regular Mode chosen"
    log "tarballs: creating archive from $targetDir to $dst"
    tar -cf "$dst" "$projectDirName"
    
        
    
    
    
    
    if [ 0 -eq $? ]; then
    
        ############################################################
        # Now, we create a tarball from all the files found in the tmp directory,
        # and move it to the depository
        ############################################################
        cd "$tmp_depository_path"
        date=$(printDate)
        tarballName="${project}.${date}.tar.gz"
#        tarballPath="${depository_path}/${tarballName}"
        tar -zcf "$tarballName" * 
        mv "$tarballName" "$depository_path"
        mvResult=$?
        log "tarballs: moving tarball to $depository_path"
        
        
        if [ 0 -eq $mvResult ]; then
        
            ############################################################
            # The tarball that we have created contains the date in
            # its filename (project.date.tar.gz). 
            # To ease the retrieval of the tarball, we create a 
            # symbolic link to the tarball and which name is date 
            # free (project.last.tar.gz)
            ############################################################
            _link="$depository_path/${project}.last.tar.gz"
            if [ -L "$_link" ]; then
                rm "$_link"
            fi
            ln -s "$depository_path/$tarballName" "$_link"
            log "tarballs: creating a symbolic link: $_link"
            
            
            ############################################################
            # remove the tmp depository
            ############################################################
            rm -r "$tmp_depository_path"
    
        fi
    
    fi
    
    cd "$oldDir"
fi



endTask "tarballs"
