#!/usr/bin/env bash

############################################################
# GOAL: 
# to update the CONFIG[tmp_depository_path] value.
# Doing so allow the user to redefine the depository
# from the config file, which is handful.
############################################################

startTask "tmp_depository_path"

CONFIG[tmp_depository_path]="$VALUE"


log "tmp_depository_path: tmp_depository_path is now set to $VALUE for the current project"



endTask "tmp_depository_path"




