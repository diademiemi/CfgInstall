# CfgInstall
This Bash script can download and check out configuration files from a bare Git repository, and can be customised to do partial checkouts.  

# Usage
This script is configured with the `cfginstall.conf` file, edit it with your required values.  

Set `SET_CFG_REPO_URL` to the URL to your Git repository.  
Set `SET_CFG_REPO_DIR` to where you want the Git repository to be cloned if you want to use a different directory than `~/.cfg`. This directory will be a [Git bare repository](https://marcel.is/managing-dotfiles-with-git-bare-repo/)  
Set `SET_CFG_WORK_TREE` to where you want the files to be checked out. This should be seen as the "root" directory of your configuration, because of this, you'll likely want to use `$HOME`.  

`CHECKOUT_GLOBAL` includes the patterns on what files to always include or exclude, regardless of option.  

Now you have to define one or more options in `OPTIONS`. In the example `cfginstall.conf`, I have an option `FULL` and `EXAMPLE`. Enter your options in the parenthesis, don't comma separate them, this is a Bash array.  

For every option you have defined in `OPTIONS`, you'll have to set a description. Create a variable called how you named the option, with `_INFO` appended, like this:  
`FULL_INFO="full: Clone all config files in this repository"`  
The second required option is the checkout. This defines which files from the repository will be cloned. Create a variable called how you named the option, with `_CHECKOUT` appended. If you want to clone all files, use `/*`. It should look like this.  
`FULL_CHECKOUT="/*"`  

There are two optional variables too:  
`_SUBMODULES` defines the path(s) where submodules are present that need to be checked out. The paths defined will be traveled recursively to update the submodules.  
`_COMMAND` defines a command to run every update.  

When you're done configuring this, you can run the script! It will prompt you which option you will want, then it'll checkout as configured.  
If the configuration file is not located at `$HOME/.cfginstall.conf`, you can define it with the `CFG_CONF` environment variable.  
If you want the script to retrieve the config file, you can set `CFG_URL`.  
