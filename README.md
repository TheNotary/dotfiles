#Dotfile Configuration Manager
These are my dotfiles.  Some of them are handy aliases, some of them serve mostly as notes on important commands.  Some of them are my personal configurations for apps.

##To deploy the configs on a new machine


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



## Credits
I only lightly modified the bash script and wrote this readme.  Credit for the idea and most of the bash tricks goes to https://github.com/michaeljsmalley

