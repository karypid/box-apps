#!/bin/sh

set -e

_container=${1:-tbox-citrix}

_host_xdg_dir="${XDG_DATA_HOME:-${HOME}/.local/share}"

# copy desktop file
_tmp_ct_desktop=$( mktemp )
podman cp "$_container:/usr/share/applications/wfica.desktop" "$_tmp_ct_desktop"

# copy icon file to host
_ct_icon=$( grep "^Icon=" "$_tmp_ct_desktop" | cut -d'=' -f 2 )
_ct_icon_fname=$( basename "$_ct_icon" )
_icon=$( mktemp )
_host_icon_dir="${_host_xdg_dir}/icons/$_container"
mkdir -p "$_host_icon_dir"
_host_icon="$_host_icon_dir/$_ct_icon_fname"
podman cp "$_container":"$_ct_icon" "$_host_icon"

# create desktop file
_host_apps_dir="${_host_xdg_dir}/applications"
mkdir -p "$_host_apps_dir"
cat "$_tmp_ct_desktop" | \
    sed 's/^Exec=/Exec=toolbox run -c '"$_container"' /' | \
    sed '/^Icon=/ s\=.*\='"$_host_icon"'\' | \
    sed '/^Name=/ s/=/=['"$_container"'] /' | \
    grep -v "^TryExec=" > "$_host_apps_dir/${_container}__wfica.desktop"

# cleanup
rm -f "$_tmp_ct_desktop"

