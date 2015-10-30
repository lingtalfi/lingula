#!/bin/bash

############################################################
# GOAL: 
# to rotate tarballs to avoid too much tarballs in the same directory.
# We use two main modes:
# - number based (default, with value n=10)
# - mtime based
# 
# 
###################################
# NUMBER BASE MODE
###################################
# In the number based mode, we specify a number x which represent the
# maximum number of tarballs allowed in the depository (CONFIG[depository_path]).
# If there is more than x tarballs in the depository, the oldest tarballs
# are removed one by one until x tarballs only remain in the depository.
# 
# Notation (in the config file) is:
#       n=${number}
# For instance, to allow 10 tarballs max:
#       n=10    
# 
###################################
# MTIME BASED MODE
###################################
# In this mode, the tarball is removed if it is older than a certain duration.
# 
# 
# The duration is specified using the following format:
# ----- (${number}${unit})+
# --------- 1y      # 1 year
# --------- 2m      # 2 months
# --------- 3d      # 3 days
# --------- 3h      # 3 hours
# --------- 3i      # 3 minutes
# --------- 1y3i    # 1 year and 3 minutes
# --------- 1y2m5d  # 1 year 2 months and 5 days
# 
# Note: in this system, a month equals 30 days, 
# and a year is 365 days.

############################################################

startTask "rotate"




instruction="$VALUE"
depo=${CONFIG[depository_path]}



# duration is expressed with the special notation
# decscribed above, the one without the plus symbol, for instance 1d03s
# It returns 1 if the format couldn't be read properly
function printDurationToMinutes # (duration)
{
    local unit
    local nbMinutes
    local nbTotalMinutes=0
    invalidFormat=0
    while read -r line; do
        unit="${line:${#line}-1:${#line}}"	
        nbMinutes="${line:0:${#line}-1}"    	
        case "$unit" in
            i|I) (( nbMinutes=nbMinutes )) ;;
            h|H) (( nbMinutes=nbMinutes*60 )) ;;
            d|D) (( nbMinutes=nbMinutes*60*24 )) ;;
            m|M) (( nbMinutes=nbMinutes*60*24*30 )) ;;
            y|Y) (( nbMinutes=nbMinutes*60*24*365 )) ;;
            *)   (( invalidFormat=1 )) ;;
        esac
        (( nbTotalMinutes+=nbMinutes ))
    done < <(echo "$1" | grep -oE "[[:digit:]]{1,}[[:alpha:]]")
    echo "$nbTotalMinutes"
    if [ 1 -eq $invalidFormat ]; then
        return 1
    fi
    return 0
}



old="$(pwd)"
cd "$depo"




MODE=1      # 1: number, 2:mtime
number=10 # max number of files allowed
filesToRemove=()

if ! [ 'n=' = "${instruction:0:2}" ]; then
    MODE=2
fi



f1=0 # flag for numbers
f1=2 # flag for numbers

# Rotate files if their number exceed the given max
if [ 1 -eq $MODE ];then

    number="${instruction:2}"
    log "rotate: use mode 1: keeping only the first $number files (default alphanumerical sort)"
    ((number++))
    while read -r line; do
        if [ -f "$line" ]; then
            filesToRemove+=("$line")
            f1=1
        fi
    done < <(ls -t | xargs -0 -n 1 | tail -n +${number})
elif [ 2 -eq $MODE ]; then

    
    nbMin=$(printDurationToMinutes "${instruction}")
    if [ 0 -eq $? ]; then
        log "rotate: use mode 2: removing files older than $nbMin minutes"
        while read -r line; do
            if [ -f "$line" ]; then
                filesToRemove+=("$line")
            fi
        done < <(find . -type f -mmin +${nbMin} -print0 | xargs -0 -I file echo file)
    else
        error "rotate: invalid time format: $instruction"
    fi
    
fi


    

    

for i in "${filesToRemove[@]}"; do
    rm "$i"
    log "rotate: removing file $i"
done






endTask "rotate"



