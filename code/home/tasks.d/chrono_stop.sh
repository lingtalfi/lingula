#!/bin/bash

############################################################
# GOAL: 
# see chrono_start 
############################################################


startTask "chrono_stop"


function displayEllapsedTime {
  local T=$1
  local D=$((T/60/60/24))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))
  [[ $D > 0 ]] && printf '%d days ' $D
  [[ $H > 0 ]] && printf '%d hours ' $H
  [[ $M > 0 ]] && printf '%d minutes ' $M
  [[ $S > 0 ]] && printf '%d seconds' $S
}




timeFile="${CONFIG[chrono_task_timerfile]}"



if [ -n "$timeFile" ]; then
    if [ -f "$timeFile" ]; then
        
        
        # reading start time from the given file
        chronoStartTimestamp=0
        while read line || [ -n "$line" ]; do
            chronoStartTimestamp=$(echo $line | cut -d# -f2 | xargs)
        done < "$timeFile"
        
        if [ 0 -ne "$chronoStartTimestamp" ]; then
        
            
        
            currentTime=$(printCurrentTime)
            timestamp=$(date +%s)
            ((ellapsed= $timestamp - $chronoStartTimestamp ))
            ellapsedHuman=$(displayEllapsedTime "$ellapsed")
            
            
            echo "stopped: $currentTime   # $timestamp" >> "$timeFile"
            echo "ellapsed: $ellapsedHuman" >> "$timeFile"        
            if [ 0 -eq $? ]; then
                log "chrono_stop: writing time info to $timeFile"
            fi
            
        else
            error "chrono_stop: could not find a valid timestamp in $timeFile"
        fi
    else
        error "chrono_stop: exception: file not found $timeFile"
    fi
else
    error "chrono_stop: timeFile not set (should have been set by chrono_start task)"
fi





endTask "chrono_stop"




