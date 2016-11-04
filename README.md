# Dotfile Configuration Manager
These are my dotfiles.  Some of them are handy aliases, some of them serve mostly as notes on important commands.  Some of them are my personal configurations for apps.

## Using this scheme of dotfile management

If you'd like to start using this scheme of dotfiles, clone this down and delete all the files in the root of this repo EXCEPT `make.sh`, `README.md`, `.gitignore`, and finally `fresh_install_script`.  Then copy all of your existing dotfiles into this repo and track them into version control, and push them to your github account. You've now made publically viewable backups of all your dotfiles!  That's kind of a problem if you had sensative passwords in any of those dotfiles...  If you do have passwords, I like to put those in `~/.this_machine` and have those backed up my my usual backup service (burp).  Feel free to take a look at my [.bashrc file](https://github.com/TheNotary/dotfiles/blob/c76373b598163597f8375e3b3223754aa85dd98f/bashrc#L8-L11) to see how I source in other dotfiles such as `.this_machine`

## To deploy the configs on a new machine

    $ cd ~
    
    # With write access to my repo...
    $ git clone git@github.com:TheNotary/dotfiles.git

    # or with just read access from an untrusted server
    $ git clone https://github.com/TheNotary/dotfiles.git

    $ cd dotfiles
    $ ./make.sh
    
Once complete that should create backups of all files it tries to overwrite and move them to ~/dotfiles_old.  Then it creates symlinks to all files found in ~/dotfiles (excluding this file and make.sh).  If you cloned with write access, remember you can continue making changes to your dotfiles as you always have ~/.bashrc for example.  If you'd like to upload your changes, simply do:

    $  cd ~/dotfiles
    $  git add .
    $  git commit -m "added new handy aliases"
    $  git push -u origin master

## Complex Config Files

Not all apps use a single config file, rather they keep an entire folder of configs.  Those complex configurations can be version controlled too.  For instance, the `~/.atom/config.cson` file is a prominent config file in atom.  To manage it, create the folder(s) `dotfiles/complex/atom` in this repo.  Now running `./make.sh` will soft link any files placed in the `dotfiles/complex/atom/config.cson` to `~/.atom/config.cson`.  Please note that this only works one layer deep as written.  


## Credits
I only lightly modified the bash script and wrote this readme.  Credit for the idea and most of the bash tricks goes to https://github.com/michaeljsmalley

