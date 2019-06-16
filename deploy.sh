#!/bin/bash
SRVDIR=fanmatics.com

cd `dirname $0`
rsync $1 -av --exclude .git --exclude .gitignore --exclude .eslintrc.json -e "ssh" ./ paul@sol:$SRVDIR
ssh paul@sol "sudo cp -R fanmatics.com /srv;"
ssh paul@sol "sudo chown -R www-data:www-data /srv/fanmatics.com"