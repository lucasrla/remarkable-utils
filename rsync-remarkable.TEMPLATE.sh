#!/bin/sh

# crontab executes commands with none of the "usual" env variables available
# to make sure rsync is found, you can either set your PATH explicitly 
# or source your shell user config file, like: 
# source $HOME/.zshrc
# source $HOME/.bashrc
# 
# see: https://stackoverflow.com/a/57696409

# !!! EDIT AND UNCOMMENT !!!
# PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:/usr/sbin:/sbin


remarkable_data_dir="/home/root/.local/share/remarkable/xochitl/"
remarkable_rsync_path="/opt/bin/rsync"
hostname="remarkable"

# !!! EDIT AND UNCOMMENT !!!
# local_backup_dir="/PATH/TO/YOUR/BACKUP_DIR/"


# add/remove --exclude flags depending on your needs (e.g. save space on your computer or not?)
# *.pagedata: the Notebook template that was selected for each page (only relevant for Notebooks)
# *.cache, *.thumbnails, *.textconversion, *.highlights: self explanatory?
# see: https://remarkablewiki.com/tech/filesystem

# !!! EDIT AND UNCOMMENT !!!
# if rsync -rv -zz --rsync-path=$remarkable_rsync_path --exclude='*.cache' --exclude='*.thumbnails' $hostname:$remarkable_data_dir $local_backup_dir ; then
    timestamp=$(date +"%Y/%m/%d %T")
    echo "$timestamp SUCCESS: rsync done! $remarkable_data_dir <-> $local_backup_dir"
else 
    timestamp=$(date +"%Y/%m/%d %T")
    echo "$timestamp ERROR: $?"
fi