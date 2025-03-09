#!/bin/sh

# use specific version (manually updated) to match zoom version installed on desktop
rpmFile=zoomvdi-universal-plugin-centos_6.0.12.rpm
url=https://zoom.us/download/vdi/6.0.12.25240/$rpmFile

curl -L "$url" -o /container/$rpmFile

echo "Downloaded: $rpmFile" into: `pwd`
ls -al /container
pwd
ls -al /container/$rpmFile

