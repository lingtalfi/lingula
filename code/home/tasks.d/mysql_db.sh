#!/bin/bash

############################################################
# GOAL: to create a mysqldump of THE WHOLE DATABASE and put 
# it into the temporary depository
# (=create another task for more flexibility)
# value format: dbName:user:pass
#
# Since passing the password directly to the mysqldump command
# leads to security issues, we use the mysqldump command
# without the password switch, and put the password in
# a temporary secured (chmod 600) config file, and we refer to that file using
# the --defaults-file=myFile switch.
# 
# http://superuser.com/questions/490521/running-mysql-dump-in-a-cron-job-without-exposing-passwords
# 
# 
# This script should be run by the super user, or at least a privileged user, so that the
# cnf file cannot be read by another malicious user.
# 
# Here is a link about how to write password to a file in a secure way:
# http://stackoverflow.com/questions/11279335/bash-write-to-file-without-echo
# 
# 
############################################################

startTask "mysql_db"
    
    
dbName=$(echo "$VALUE" | gawk -F: '{print $1}')
dbUser=$(echo "$VALUE" | gawk -F: '{print $2}')
dbPass=$(echo "$VALUE" | gawk -F: '{print $3}')
    
    
    
    
#dumpProjectConfig    
    
# checking value, dbPass can possibly be empty    
ok=1
if [ -z "$dbName" ]; then
    ok=0
    error "mysql_db: dbName not found in $VALUE"
fi
if [ -z "$dbUser" ]; then
    ok=0
    error "mysql_db: dbUser not found in $VALUE"
fi
    
    
if [ 1 -eq $ok ]; then
    
    tmpDir="${CONFIG[tmp_depository_path]}"
    if ! [ -d "$tmpDir" ]; then
        mkdir -p "$tmpDir"
    fi
    
    if [ -d "$tmpDir" ]; then
        log "mysql_db: creating mysqldump of database $dbName in $tmpDir"
        f=/tmp/lingula_mysql_db
        file="$(newFileName $f)"
        if [ 0 -eq $? ]; then
            chmod 600 "$file"
            cat <<EOFFF > "$file"

[client]
password=${dbPass}


EOFFF


            mysqldump --defaults-file="${file}" -u${dbUser} ${dbName} > "$tmpDir/${dbName}.sql"
            
            if ! [ 0 -eq $? ]; then
                warning "mysql_db: an error occurred with the dump file: $tmpDir/${dbName}.sql"
            fi
            
            # removing the temporary file and directory
            rm "$file"
            rm -r /tmp/lingula_mysql_db
               
        else
            error "mysql_db: cannot create the temporary file"
        fi
    else
        error "mysql_db: couldn't create the temporary dir ($tmpDir)"
    fi
fi






endTask "mysql_db"



