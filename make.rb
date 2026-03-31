#!/usr/bin/env ruby

#######################################################################
#                           Dotfiles                                  #
# This script creates symlinks from the home directory to any desired #
# dotfiles in ~/dotfiles (or whatever you change the variable         #
# dotfiles_folder_name to be.                                         #
#######################################################################

require "fileutils"
require "rbconfig"

###############################
#          Variables          #
###############################

# dotfiles folder name.  Change to "private_dotfile" for a seperate repo that you
# can track secrets into but never push to github
DOTFILES_FOLDER_NAME = "dotfiles"

# old dotfiles backup directory
BACKUP_DIR = File.join(
  Dir.home,
  "#{DOTFILES_FOLDER_NAME}_backups",
  "dotfiles_#{Time.now.strftime("%Y-%m-%d_%H-%M-%S")}"
)

# Get current directory of script
DIR = File.realpath(File.dirname(__FILE__))

# dotfiles directory
DOTFILES_DIR = File.join(Dir.home, DOTFILES_FOLDER_NAME)

# list of files/folders to symlink in homedir (mirrors `ls $DIR` — excludes dot-prefixed entries)
FILES = Dir.children(DIR).reject { |f| f.start_with?(".") }

SKIP_FILES = %w[
  README.md
  MODERN.md
  make.rb
  fresh_install_script
  sample_this_machine
  complex
  config
  inane
].freeze


###############################
#           Helpers           #
###############################

# Move an existing file/dir to backup_dir, then create a symlink from source to target.
# If guard_dir is provided, the symlink is only created when that directory exists.
def backup_and_link(source, target, backup_dest, guard_dir: nil)
  if File.symlink?(target) && File.readlink(target) == source
    puts "    Already linked: #{target}"
    return
  end

  if File.exist?(target) || File.symlink?(target)
    puts "    Making backup of #{File.basename(target)} in #{backup_dest}"
    FileUtils.mkdir_p(File.dirname(backup_dest))
    FileUtils.mv(target, backup_dest)
  end

  if guard_dir && !File.directory?(guard_dir)
    puts "    Skipping symlink (#{guard_dir} does not exist): #{target}"
    return
  end

  puts "    Creating symlink to #{target}"
  begin
    File.symlink(source, target)
  rescue Errno::EACCES
    raise unless windows?
    abort <<~MSG

      Error:
      You must enable Developer Mode in Windows for this script to create symlinks.

      Open an elevated command prompt and run this command:

        reg add "HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"

      Or enable it via Settings > System > For developers > Developer Mode

      Then re-run this script.
    MSG
  end
end

def backup_and_link_inane(mapping)
  source_dir = mapping[:source_dir]
  backup_dir = mapping[:backup_dir]

  dest_dir =
    if darwin?
      mapping.dig(:dest_dir, :darwin?)
    elsif windows?
      mapping.dig(:dest_dir, :windows?)
    else
      mapping.dig(:dest_dir, :linux?)
    end

  Dir.children(source_dir).each do |file|
    next if dest_dir.nil?
    source = File.join(source_dir, file)
    dest   = File.join(dest_dir, file)
    backup = File.join(backup_dir, file)

    backup_and_link(source, dest, backup)
  end
end

# OS detection
def darwin?  = RbConfig::CONFIG["host_os"] =~ /darwin/i
def windows? = RbConfig::CONFIG["host_os"] =~ /mswin|mingw|cygwin/i


###############################
#            Logic            #
###############################

# Make sure the directory's name is dotfiles... otherwise the user could be
# getting more than he or she bargained for
if File.basename(DIR) != DOTFILES_FOLDER_NAME
  abort <<~MSG
    The folder you ran this script from isn't named '#{DOTFILES_FOLDER_NAME}'... so the script
    has been blocked to prevent you from accidentally creating a bunch of symlinks you don't actually want.
    Please clone the dotfiles repo to ~/#{DOTFILES_FOLDER_NAME} and run `make.rb` from within that dir.
  MSG
end

# create backup_dir in homedir
puts "Creating #{BACKUP_DIR} for backup of any existing dotfiles in ~"
FileUtils.mkdir_p(File.join(BACKUP_DIR, "complex"))
FileUtils.mkdir_p(File.join(BACKUP_DIR, "config"))
puts "...done"

# Standard Phase — move any existing dotfiles in homedir to backup_dir, then create symlinks
puts "Changing to the #{DOTFILES_DIR} directory"

FILES.each do |file|
  # skip list
  if SKIP_FILES.include?(file)
    # puts "skipping one:  #{file}"
    next
  end

  # OS-specific skip
  if file == "mac_fixes" && !darwin?
    # puts "skipping one:  #{file}"
    next
  end

  source = File.join(DOTFILES_DIR, file)
  target = File.join(Dir.home, ".#{file}")
  backup = File.join(BACKUP_DIR, file)

  backup_and_link(source, target, backup)
end

# Complex Phase
#
#   The primary configuration file for Atom is `~/.atom/config.cson`
# We don't want to version control anything else, and we don't want anything in
# that folder removed when we run `~/.make.rb`  other than a few specific
# config files.  So we can drop the config files in `~/dotfiles/complex/atom/`
# to have them directly installed into the proper place...

complex_dir = File.join(DOTFILES_DIR, "complex")
puts "Changing to the #{complex_dir} directory"
puts ""

Dir.children(complex_dir).reject { |f| f.start_with?(".") }.each do |folder|
  puts "  folder name: #{folder}"

  folder_path = File.join(complex_dir, folder)
  next unless File.directory?(folder_path)

  Dir.children(folder_path).reject { |f| f.start_with?(".") }.each do |file|
    source     = File.join(folder_path, file)
    target     = File.join(Dir.home, ".#{folder}", file)
    backup     = File.join(BACKUP_DIR, "complex", folder, file)
    guard_dir  = File.join(Dir.home, ".#{folder}")

    backup_and_link(source, target, backup, guard_dir: guard_dir)
  end
end

# .config Phase
#
config_dir = File.join(DOTFILES_DIR, "config")
puts "Changing to the #{config_dir} directory"
puts ""

Dir.children(config_dir).reject { |f| f.start_with?(".") }.each do |folder|
  puts "  folder name: #{folder}"

  folder_path = File.join(config_dir, folder)
  next unless File.directory?(folder_path)

  Dir.children(folder_path).reject { |f| f.start_with?(".") }.each do |file|
    source     = File.join(folder_path, file)
    target     = File.join(Dir.home, ".config", folder, file)
    backup     = File.join(BACKUP_DIR, "config", folder, file)
    guard_dir  = File.join(Dir.home, ".config", folder)

    backup_and_link(source, target, backup, guard_dir: guard_dir)
  end
end

# Inane Phase
#
#   Some config files are absolutely inane like the VS Code config file.  We will
# manually map these inane files here.
#
puts "    Creating symlink to Inane stuff"

inane_mappings = [
  {
    source_dir: File.join(DOTFILES_DIR, "inane", "vscode"),
    backup_dir: File.join(BACKUP_DIR, "inane_vscode"),
    dest_dir: {
      darwin?: File.join(Dir.home, "Library", "Application Support", "Code", "User"),
      windows?: File.join(ENV.fetch("APPDATA", File.join(Dir.home, "AppData", "Roaming")), "Code", "User"),
      linux?: File.join(Dir.home, ".config", "Code", "User")
    }
  },
  {
    source_dir: File.join(DOTFILES_DIR, "inane", "powershell"),
    backup_dir: File.join(BACKUP_DIR, "inane_powershell"),
    dest_dir: {
      windows?: ENV.fetch("OneDrive") ?
        File.join(ENV.fetch("OneDrive"), "Documents", "PowerShell") :
        File.join(Dir.home, "Documents", "PowerShell")
    }
  },
  {
    source_dir: File.join(DOTFILES_DIR, "inane", "zed"),
    backup_dir: File.join(BACKUP_DIR, "inane_zed"),
    dest_dir: {
      darwin?: File.join(Dir.home, ".config", "zed"),
      windows?: File.join(ENV.fetch("APPDATA", File.join(Dir.home, "AppData", "Roaming")), "Zed"),
      linux?: File.join(Dir.home, ".config", "zed")
    }
  }
]

inane_mappings.each do |mapping|
  backup_and_link_inane(mapping)
end

puts "done."
