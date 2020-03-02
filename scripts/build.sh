#!/bin/sh

currentDir=$PWD
BRANCH_VERSION=18.7


# cd /usr/core
# git fetch origin
# for branch in "master" "stable/$BRANCH_VERSION"; do
#     git checkout -f $branch
#     git reset --hard origin/$branch

#     cd /usr/core/src/opnsense/mvc/app/views/OPNsense/CaptivePortal
#     diff -u clients.volt $currentDir/captiveportal/src/opnsense/mvc/app/views/OPNsense/CaptivePortal/clients.volt  > clients.patch
#     patch < clients.patch

#     cd /usr/core/src/opnsense/scripts/OPNsense/CaptivePortal/htdocs_default
#     diff -crB $PWD/ $currentDir/captiveportal/src/opnsense/scripts/OPNsense/CaptivePortal/htdocs_default > htdocs_default.patch
#     patch -p0 < htdocs_default.patch

#     cd /usr/core 
# done
# make plist-fix
# make upgrade 

# cd /usr/src
# git fetch origin
# git checkout -f master
# git reset --hard origin/master
# git checkout -f stable/$BRANCH_VERSION
# git reset --hard origin/stable/$BRANCH_VERSION

# cd /usr/ports
# git fetch origin
# git checkout -f master
# git reset --hard origin/master

# cd /usr/plugins
# git fetch origin
# for branch in "master" "stable/$BRANCH_VERSION"; do
#     git checkout -f $branch
#     git reset --hard origin/$branch

#     # freeradius plugin
#     rm -rf net/kp-freeradius
#     cp -pr $currentDir/freeradius net/kp-freeradius
#     git add .
#     git commit -am "add kp-freeradius plugin"
# done

# cd /usr/tools
# git fetch origin
# git checkout master
# git reset --hard origin/master
# git checkout -B tags/$BRANCH_VERSION
# git reset --hard $BRANCH_VERSION

# echo "net/kp-freeradius                              arm" >> config/$BRANCH_VERSION/plugins.conf

# make src
# make core
# make ports
# make clean-plugins
# make plugins

# pkg install /usr/obj/usr/tools/config/18.7/OpenSSL:amd64/.pkg-new/All/os-kp-freeradius-1.8.0.txz

# tar -xpf os-kp-freeradius-1.8.0.txz -C bin/
# cp freeradius/src/opnsense/service/templates/OPNsense/Freeradius/* bin/usr/local/opnsense/service/templates/OPNsense/Freeradius/
# cd bin/ 
# tar -cpf /usr/obj/usr/tools/config/18.7/OpenSSL:amd64/.pkg-new/All/os-kp-freeradius-1.8.0.txz *
# cd ..
# pkg install -y /usr/obj/usr/tools/config/18.7/OpenSSL:amd64/.pkg-new/All/os-kp-freeradius-1.8.0.txz



# mv src/opnsense/www/js/bootstrap-select.old.js src/opnsense/www/js/bootstrap-select.js
# mv src/opnsense/www/js/bootstrap-select.old.js.map src/opnsense/www/js/bootstrap-select.js.map
# mv src/opnsense/www/js/bootstrap-select.min.old.js src/opnsense/www/js/bootstrap-select.min.js
# mv src/opnsense/www/themes/opnsense/build/css/bootstrap-select.old.css src/opnsense/www/themes/opnsense/build/css/bootstrap-select.css
# mv src/opnsense/www/themes/opnsense/assets/stylesheets/bootstrap-select/less/bootstrap-select.old.less src/opnsense/www/themes/opnsense/assets/stylesheets/bootstrap-select/less/bootstrap-select.less
# mv src/opnsense/www/themes/opnsense/assets/stylesheets/bootstrap-select/less/variables.old.less src/opnsense/www/themes/opnsense/assets/stylesheets/bootstrap-select/less/variables.less

# cp -f $currentDir/core/assets/bootstrap-select/js/bootstrap-select.js src/opnsense/www/js
# cp -f $currentDir/core/assets/bootstrap-select/js/bootstrap-select.js.map src/opnsense/www/js
# cp -f $currentDir/core/assets/bootstrap-select/js/bootstrap-select.min.js src/opnsense/www/js
# cp -f $currentDir/core/assets/bootstrap-select/css/bootstrap-select.css src/opnsense/www/themes/opnsense/build/css
# cp -f $currentDir/core/assets/bootstrap-select/css/bootstrap-select.less src/opnsense/www/themes/opnsense/assets/stylesheets/bootstrap-select/less
# cp -f $currentDir/core/assets/bootstrap-select/css/variables.less src/opnsense/www/themes/opnsense/assets/stylesheets/bootstrap-select/less

# cp -prf $currentDir/core/layout_partials/* src/opnsense/mvc/app/views/layout_partials/

# cd /usr/core
# make plist-fix
# make upgrade 

# cd /usr/plugins
# rm -rf net/kp-captiveportal
# cp -pr $currentDir/captiveportal net/kp-captiveportal
# cd net/kp-captiveportal
# make upgrade

cd /usr/plugins
rm -rf net/kp-freeradius
cp -pr $currentDir/freeradius net/kp-freeradius
cd net/kp-freeradius
make upgrade