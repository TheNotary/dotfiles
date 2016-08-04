#!/bin/bash

#######################################################################
#                           Dotfiles                                  #
# This script creates symlinks from the home directory to any desired #
# dotfiles in ~/dotfiles                                              #
#######################################################################

###############################
#          Variables          #
###############################

dir=~/dotfiles                    # dotfiles directory
olddir=~/dotfiles_old             # old dotfiles backup directory
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )  # Get current directory of script
files="$(ls $DIR)"                # list of files/folders to symlink in homedir


###############################
#            Logic            #
###############################

# Make sure the directory's name is dotfiles... otherwise the user could be 
# getting more than he or she bargained for
if [ "$( cd $DIR && echo ${PWD##*/} )" != "dotfiles" ]
then
  echo "The folder you ran this script from isn't named 'dotfiles'... so the script \nhas been blocked from to prevent you from accidentally creating a bunch of symlinks you don't actually want"
  echo "Symlinks that would have been made:  $files"
  exit 1
fi

# create dotfiles_old in homedir
echo "Creating $olddir for backup of any existing dotfiles in ~"
mkdir -p $olddir
echo "...done"

# change to the dotfiles directory
echo "Changing to the $dir directory"
cd $dir
echo "...done"

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks 
for file in $files; do
  
  # skip the README.md and make.sh file #
  if [ "$file" = "README.md" ] || [ "$file" = "make.sh" ] || [ "$file" = "fresh_install_script" ] || [ "$file" = "sample_this_machine" ]
  then
   echo "skipping $file"
   continue      # Skip rest of this particular loop iteration.
  fi


	echo "Moving any existing dotfiles from ~ to $olddir"
	mv ~/.$file ~/dotfiles_old/
		echo "Creating symlink to $file in home directory."
	ln -s $dir/$file ~/.$file
done
