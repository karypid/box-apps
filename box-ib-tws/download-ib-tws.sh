#!/bin/sh

_channel=${1:-stable}
_CHANNELS="stable,latest"
[[ "$_CHANNELS" =~ (,|^)$_channel(,|$) ]] || {
    echo "Channel must be one of: $_CHANNELS -- Got: $_channel"
    exit 1
}

echo "Downloading current [$_channel] channel"

url=https://www.interactivebrokers.co.uk/en/trading/tws-offline-$_channel.php
echo "URL: $url"
_dl_urls=$(curl -sL "$url" | grep "tws-$_channel-standalone-linux-x64.sh" ) 
_source64=$(echo "$_dl_urls" | sed -En 's|^.*href="(.+tws-'"$_channel"'-standalone-linux-x64.sh)".*|\1|p' )
_rpmFile=$(echo "$_source64" | rev | cut -d'/' -f 1 | rev)

[ -f "$_rpmFile" ] && echo "Already downloaded: $_rpmFile" || curl "$_source64" -o $_rpmFile

