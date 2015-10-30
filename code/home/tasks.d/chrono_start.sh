#!/bin/bash

############################################################
# GOAL: 
# chrono_start and chrono_stop allows you to measure how much time
# the backup took to execute.
# For projects with a lot of files, or a big database, this information
# might be valuable.
# 
# The mechanism used is the following:
# chrono_start.sh is the first task to be run, it writes the 
# current time in a given file.
# Then the backup process occurs.
# When it's done, chrono_stop.sh is run (it should be the last task), 
# it reads the time in the file, writes a second line with the 
# new time, plus a third line that computes the difference between
# the two timestamps in a human readable format.
# 
# The file used by chrono_start.sh and chrono_stop.sh typically looks
# like this:
# 
# started: 2015-09-09 20:47:51      # 1417376871
# stopped: 2015-09-09 21:00:12      # 1417377612
# ellapsed: 12 minutes 21 seconds
# 
# 
# 
############################################################



startTask "chrono_start"

timeFile="$VALUE"



chronoDir=$(dirname "$timeFile")
mkdir -p "$chronoDir"

if [ 0 -eq $? ]; then
    
    # writing data to the timer file
    currentTime=$(printCurrentTime)
    timestamp=$(date +%s)
    CONFIG[chrono_task_timerfile]="$timeFile"
    echo "started: $currentTime   # $timestamp" > "$timeFile"
    
    
    if [ 0 -eq $? ]; then
        log "chrono_start: writing the current time to $timeFile"
    else
        error "chrono_start: Could not write the time file: $timeFile"
    fi
    
    

else
    error "chrono_start: Could not create the chrono dir: $chronoDir"
fi





endTask "chrono_start"




