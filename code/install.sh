#!/bin/bash


#----------------------------------------
# This script will setup lingula on an unix machine.
#----------------------------------------
# You need to cd to the directory that contains install.sh,
# and then execute it.
# This is important because paths are hardcoded.
# 
# What this script will do:
# -- check that bash is in version 4 (lingula needs bash4+) or abort!
# -- check that the caller is in the directory that contains install.sh, or abort!
# -- detect if you have a /usr/local/bin folder, if you don't, abort!
# -- detect if /usr/local/bin/lingula exists already, if it does, abort!
# -- ensures that home folder exists next to the install.sh script, or abort!
# -- ensures that lingula.sh script exists next to the install.sh script, or abort!
# -- create /usr/local/bin/lingula script and give it +x permissions
# ------ That script will define the _home variable with the absolute path to
# ------ the home folder next to this script.
# ------ Then it will source the content of the lingula.sh script next to this script

abort(){
    echo "install.sh: abort: $1"
    exit 1
}

bash4="/bin/bash"
localBin="/usr/local/bin"
command="$localBin/lingula"



echo "$($bash4 --version)" | head -n 1 | grep -q "version [4-9]"
if ! [ 0 -eq $? ]; then
    abort "lingula requires at least bash version 4, the bash command ($bash4) on your machine does not meet this requirement"
fi




if ! [ "./install.sh" = "$0" ]; then
    abort "you need to cd to the directory containing the install.sh script to execute it"
fi

if ! [ -d "$localBin" ]; then
    abort "$localBin directory not found!"
fi

if [ -f "$command" ]; then
    abort "lingula command already exist ($command)!"
fi



home="$(pwd)/home"
lingulaPath="$(pwd)/lingula.sh"

if ! [ -d "$home" ]; then
    abort "home folder not found: $home"
fi

if ! [ -f "$lingulaPath" ]; then
    abort "lingula.sh script not found: $lingulaPath"
fi


echo -e "#!/bin/bash\n_home=\"$home\"\n. \"$lingulaPath\"" > "$command"
if [ 0 -ne $? ]; then
    abort "Couldn't write the command into $command"
fi

chmod +x "$command"
if [ 0 -ne $? ]; then
    abort "Couldn't give execute permissions to $command"
fi





echo "installation was successful"

# ensure that /usr/local/bin is in the PATH.
echo $PATH | tr ':' '\n' | grep -q -e "^/usr/local/bin$"
if [ 0 -eq $? ]; then
    echo "you can now call lingula directly from the command line for this user"
fi





