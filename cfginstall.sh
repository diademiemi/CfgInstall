#!/bin/bash

# Copyright © 2021 diademiemi
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# CFG_CONF:
# Where the configuration file for this script is located
if [ -z "$CFG_CONF" ]; then
    CFG_CONF=$HOME/.cfginstall.conf
fi

# CFG_URL:
# Download and retrieve the configuration file to $CFG_CONF
if [ ! -z "$CFG_URL" ]; then
    curl -o $CFG_CONF $CFG_URL
fi

source $CFG_CONF

if [ -z "$OPTIONS" ]; then
    echo "Invalid configuration file given"
    exit 1
fi

# Set configuration variables if needed.

# CFG_REPO_URL:
# The URL to the Git repository to clone
if [ -z "$CFG_REPO_URL" ]; then
    CFG_REPO_URL=$SET_CFG_REPO_URL
fi

# CFG_REPO_DIR:
# This is where the bare repository will be cloned
if [ -z "$CFG_REPO_DIR" ]; then
    CFG_REPO_DIR=$SET_CFG_REPO_DIR
fi

# CFG_WORK_TREE:
# This is where the repository will be checked out.
# You will likely want this as $HOME! But you can change this for testing
if [ -z "$CFG_WORK_TREE" ]; then
    CFG_WORK_TREE=$SET_CFG_WORK_TREE
fi

# Set alias temporarily. You should set this in your shell too!
shopt -s expand_aliases
alias cfg='/usr/bin/git --git-dir=$CFG_REPO_DIR --work-tree=$CFG_WORK_TREE'

# Clone the repository if the directory does not exist yet
if [ ! -d $CFG_REPO_DIR ]; then
    git clone --bare $CFG_REPO_URL $CFG_REPO_DIR
    # Disable showing untracked files. 
    # Since the work tree will usually be your entire home directory, this would be very annoying
    cfg config --local status.showUntrackedFiles no
    # Enable the sparse checkout feature, this is used to allow for partial downloads of your configs
    cfg config --local core.sparseCheckout true
fi

# Check if the .cfginstall.selected file exists 
# This is basically the first run script, and will prompt for configured choices
if [ ! -f $CFG_WORK_TREE/.cfginstall.selected ]; then
    echo "The following options are available"
    for option in "${OPTIONS[@]}"; do
        printf '\t'
        eval echo "\${${option}_INFO}"
    done
    printf '\n'
    echo "If files in the repository already exist locally, the local files will be overwritten!"
    read -p "Select an option: " RESPONSE

    RESPONSE=$(echo ${RESPONSE} | tr '[:lower:]' '[:upper:]' )

    for option in "${OPTIONS[@]}"; do
        if [ $RESPONSE = $option ]; then
            echo $RESPONSE > $CFG_WORK_TREE/.cfginstall.selected
        fi
    done
    
    if [ ! -f ${CFG_WORK_TREE}/.cfginstall.selected ]; then echo "Invalid option"; fi

fi

if [ -f ${CFG_WORK_TREE}/.cfginstall.selected ]; then

    SELECTED_OPTION=$(cat ${CFG_WORK_TREE}/.cfginstall.selected)

    # Build sparse-checkout file
    > $CFG_REPO_DIR/info/sparse-checkout
    for line in $CHECKOUT_GLOBAL; do
        echo "$line" >> $CFG_REPO_DIR/info/sparse-checkout
    done
    eval checkout=${SELECTED_OPTION}_CHECKOUT
    for line in "${!checkout}"; do
        echo "$line" >> $CFG_REPO_DIR/info/sparse-checkout
    done

    # Checkout
    cfg checkout --force
    cfg pull

    # Update submodules if specified
    eval submodules=${SELECTED_OPTION}_SUBMODULES

    if [ ! -z "$submodules" ]; then
        for line in "${!submodules}"; do
            cfg submodule update --init --recursive "$line"
        done
    fi

    # Run command if specified
    eval command=${SELECTED_OPTION}_COMMAND

    if [ ! -z "${!command}" ]; then
        bash -c "${!command}"
    fi

fi
