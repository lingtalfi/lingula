#!/bin/bash

############################################################
# GOAL: 
# to update the CONFIG[depository_path] value.
# Doing so allow the user to redefine the depository
# from the config file, which is handful.
############################################################

startTask "depository_path"

CONFIG[depository_path]="$VALUE"


log "depository_path: depository_path is now set to $VALUE for the current project"



endTask "depository_path"




