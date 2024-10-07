#!/bin/sh

_channel=${1:-stable}
_CHANNELS="stable,latest"
[[ "$_CHANNELS" =~ (,|^)$_channel(,|$) ]] || {
    echo "Channel must be one of: $_CHANNELS -- Got: $_channel"
    exit 1
}

_dst="/inst/tws/$_channel"
if [ -f "$_dst/uninstall" ]; then
    echo "Already installed..."
    exit 1
fi

_uid=$(id -u)
_gid=$(id -g)

sudo mkdir -p /inst/$_i
sudo chown -R $_uid:$_gid /inst

sh "/container/tws-$_channel-standalone-linux-x64.sh" -q -dir "$_dst"

