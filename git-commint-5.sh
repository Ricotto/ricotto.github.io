#!/bin/sh
cd /var/www/project

git add *
timestamp(){
   date +"%d.%m.%Y um %H:%M"
}
git commit -am "Auto Server Commit $(timestamp)"
git push --repo https://[user]:[password]@github.com/[organisation]/[repo].git
