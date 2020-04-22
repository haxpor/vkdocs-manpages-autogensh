#!/bin/bash
# Script to pull upstream KhronosGroup/Vulkan-Docs
# This script is intended to be executed from parent Makefile

### Section of variable declarations ###

# this requires that user has setup SSH key on Github
git_upstream_repo=git@github.com:KhronosGroup/Vulkan-Docs.git
repo_dir=Vulkan-Docs
target_api_version_release=
is_need_fetch_latest_tag_release=0

### Section of logic code ###
# check if target api version is supplied, if not we use latest branch
if [ -z $1 ]; then
    echo "No target API version supplied."
    echo "This will fetch latest release."
    is_need_fetch_latest_tag_release=1
fi

# check if already pulled down upstream repo
# if not clone yet, then do it
if [ ! -d $repo_dir ]; then
    echo "Repo directory not exist, cloning ..."
    git clone $git_upstream_repo

    # if failed, then shout out error message
    if [ $? -ne 0 ]; then
        echo "Error cloning upstream repo"
        exit 1
    fi
fi

cd $repo_dir

git checkout master
git reset --hard
git clean -fx
git pull origin master

# install all required nodejs packages locally (as per package.json if exists)
# certain release version especially 1.2.138 includes nodejs as part of dependency, and
# users need to install a few packages as required per package.json states
if [ -f "package.json" ]; then
    npm install
    if [ $? -ne 0 ]; then
        echo "Error from installing required NodeJS packages"
        exit 1
    fi
fi

# get the most recent tag release
if [ $is_need_fetch_latest_tag_release -eq 1 ]; then
    target_api_version_release=`git tag --list --sort=-committerdate | head -n1`
else
    # set from forwarded parameter from parent Makefile
    target_api_version_release=$1
fi

# check if such tag release ever exists
git checkout $target_api_version_release
if [ $? -ne 0 -a $is_need_fetch_latest_tag_release -eq 1 ]; then
    echo "No such release for '$target_api_version_release'!"
    echo "Cloned repo is possibly corrupted."
    echo "Please remove cloned repo directory, then try again."
    exit 1
fi

# inject Makefile's patch to repo's Makefile
cat ../patches/Makefile >> Makefile

# clean possible generated files only manpages first
make clean_onlymanpages

# build only manpages
make -j4 onlymanpages

## FIXME: a few files will be linted with result of errors, for now we just let it complete. This
## applies for version 1.1.x.
if [ $? -ne 0 ]; then
    echo "Error in making manpages. Some files are failed in building!"
    exit 1
fi

# correct artifacts of generated manpages
ls out/man | grep -e '[vV][kK].*.3' | xargs -I{} sed -i -e 's/<code>/\\fB/g' -e 's|</code>|\\fR|g' -e 's|<strong\sclass="purple">|\\fI|g' -e 's|</strong>|\\fR|g' out/man/{};
ls out/man | grep -e 'PFN.*.3' | xargs -I{} sed -i -e 's/<code>/\\fB/g' -e 's|</code>|\\fR|g' -e 's|<strong\sclass="purple">|\\fI|g' -e 's|</strong>|\\fR|g' out/man/{};

# show stats result of number of manpages generated
total_files=$(($(ls out/man | grep -e '[vV][kK].*.3' | wc -l) + $(ls out/man | grep -e 'PFN.*.3' | wc -l)))
echo "Generated in total $total_files manpages"
