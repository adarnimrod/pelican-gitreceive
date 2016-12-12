#!/bin/sh
set -eu

# This part was copied verbatim from
# https://github.com/progrium/gitreceive/wiki/TipsAndTricks
fetch_submodules () {
    # We reinitialize .git to avoid conflicts
    rm -fr .git
    # GIT_DIR is previously set by gitreceive to ".", we want it back to default
    # for this
    unset GIT_DIR
    git init .

    # We read the submodules from .gitmodules
    git config -f .gitmodules --get-regexp '^submodule\..*\.path$' |
        while read path_key path
        do
            rm -fr $path
            url_key=`echo $path_key | sed 's/\.path/.url/'`
            url=`git config -f .gitmodules --get "$url_key"`
            git submodule add $url $path
        done
}

mkdir -p /var/tmp/gitreceive
cd /var/tmp/gitreceive
echo '----> Unpacking ...'
tar -xf -
if [ -f .gitmodules ]
then
    echo '----> Fetching submodules ...'
    fetch_submodules
fi
echo '----> Activating virtualenv ...'
. /var/lib/pelican-gitreceive/bin/activate
echo '----> Building blog ...'
fab  build
echo '----> Copying blog ...'
rsync -Prv --delete --cvs-exclude output/ {{ pelican_gitreceive_output }}
echo '----> Cleanup ...'
cd -
rm -rf /var/tmp/gitreceive
echo '----> OK.'
