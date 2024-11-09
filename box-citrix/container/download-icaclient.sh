#!/bin/sh

url=https://www.citrix.com/downloads/workspace-app/linux/workspace-app-for-linux-latest.html

#pkgver=24.5.0.76
#_dl_urls="$(curl -sL "$url" | grep -E "rhel-$pkgver.*\.rpm\?__gda__.*")"

_dl_urls="$(curl -sL "$url" | grep -E "\-rhel-.*\.rpm\?__gda__.*")"
_source64=https:"$(echo "$_dl_urls" | sed -En 's|^.*rel="(//.+.x86_64.rpm[^"]*)".*$|\1|p' )"
_rpmFile=$(echo "$_source64" | cut -d'?' -f 1 | rev | cut -d'/' -f 1 | rev)

[ -f "$_rpmFile" ] || curl "$_source64" -o $_rpmFile

echo "Downloaded: $_rpmFile" into: `pwd`

