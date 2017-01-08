#!/bin/bash

#######################################################################
#                           Dotfiles                                  #
# This script creates symlinks from the home directory to any desired #
# dotfiles in ~/dotfiles                                              #
#######################################################################


###############################
#          Variables          #
###############################

# old dotfiles backup directory
backup_dir=${HOME}/dotfiles_backups/dotfiles_$(date +"%Y-%m-%d_%H-%M-%S")

# Get current directory of script
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# list of files/folders to symlink in homedir
files="$(ls $DIR)"

# dotfiles directory
dir=${HOME}/dotfiles


###############################
#            Logic            #
###############################

# Make sure the directory's name is dotfiles... otherwise the user could be
# getting more than he or she bargained for
if [ "$( cd ${DIR} && echo ${PWD##*/} )" != "dotfiles" ]
then
  echo "The folder you ran this script from isn't named 'dotfiles'... so the script \nhas been blocked from to prevent you from accidentally creating a bunch of symlinks you don't actually want"
  echo "Symlinks that would have been made:  ${files}"
  exit 1
fi

# create dotfiles_old in homedir
echo "Creating ${backup_dir} for backup of any existing dotfiles in ~"
mkdir -p ${backup_dir}/complex
echo "...done"

# change to the dotfiles directory
echo "Changing to the ${dir} directory"
cd ${dir}
echo "...done"

# move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks
for file in $files; do

  # skip the README.md and make.sh file #
  if [ "$file" = "README.md" ] || [ "$file" = "make.sh" ] || [ "$file" = "fresh_install_script" ] || [ "$file" = "sample_this_machine" ] || [ "$file" = "complex" ]
  then
    echo "skipping $file"
    continue      # Skip rest of this particular loop iteration.
  fi


  echo "Moving any existing dotfiles from ~ to $backup_dir"
  [ -e ${HOME}/.${file} ] && mv ${HOME}/.${file} ${HOME}/dotfiles_old/
  echo "Creating symlink to $file in home directory."
  ln -s $dir/$file ${HOME}/.$file
done

# Complex Phase
#
#   The primary configuration file for Atom is `~/.atom/config.cson`
# We don't want to version control anything else, and we don't want anything in
# that folder removed when we run `~/.make.sh`  other than a few specific
# config files.  So we can drop the config files in `~/dotfiles/complex/atom/`
# to have them directly installed into the proper place...

# change to the dotfiles directory
echo "Changing to the $dir/complex directory"
cd ${dir}/complex
echo "...done"

folders="$(ls ${PWD})"
for folder in $folders; do
  echo "folder name: ${folder}"

  # cd into the folder
  cd $folder
  complex_files="$(ls ${PWD})"
  for file in ${complex_files}; do
    echo "Making backup of ${file} in ${backup_dir}/complex/${folder}/${file}"
    mkdir ${backup_dir}/complex/${folder}
    [ -e ${HOME}/.${folder}/${file} ] && mv ${HOME}/.${folder}/${file} ${backup_dir}/complex/${folder}/${file}

    echo "Creating symlink to ~/.${folder}/${file}"
    [ -e ${HOME}/.${folder}/ ] && ln -s ${PWD}/${file} ${HOME}/.${folder}/${file}
  done

done

exit
