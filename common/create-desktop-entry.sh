#!/bin/bash

show_help()
{
        cat << EOF
create-container-entry - Create a desktop entry file for executing a command within a container.

Usage:

	create-container-entry --container my_container --exec "/path/to/command %U" --name "My desktop entry" --icon /path/to/icon/in/container

Options:

        --container/-c:         name of the container
        --exec/-e:              command to execute within the container
        --icon/-i:              icon file to use
        --name/-n:              name of generated desktop entry
	--verbose/-v:           show more verbosity
        --help/-h:              show this message
EOF
}

container=""
exec=""
verbose=0
while :; do
        case $1 in
                -h | --help)
                        # Call a "show_help" function to display a synopsis, then exit.
                        show_help
                        exit 0
                        ;;
                -v | --verbose)
                        shift
                        verbose=1
                        ;;
                -c | --container)
                        if [ -n "$2" ]; then
                                container="$2"
                                shift
                                shift
                        fi
                        ;;
                -e | --exec)
                        if [ -n "$2" ]; then
                                exec="$2"
                                shift
                                shift
                        fi
                        ;;
                -i | --icon)
                        if [ -n "$2" ]; then
                                icon="$2"
                                shift
                                shift
                        fi
                        ;;
                -n | --name)
                        if [ -n "$2" ]; then
                                name="$2"
                                shift
                                shift
                        fi
                        ;;
                -*) # Invalid options.
                        printf >&2 "ERROR: Invalid flag '%s'\n\n" "$1"
                        show_help
                        exit 1
                        ;;
                *) # Default case: If no more options then break out of the loop.
                        break ;;
	esac
done

set -o errexit
set -o nounset
# set verbosity
if [ "${verbose}" -ne 0 ]; then
        set -o xtrace
fi

if [ -z "${container}" ] || [ -z "${exec}" ] || [ -z "${name}" ]; then
        printf >&2 "Error: Invalid arguments.\n"
        printf >&2 "Error: missing container and/or execute command.\n"
        exit 2
fi

_host_xdg_dir="${XDG_DATA_HOME:-${HOME}/.local/share}"

if [ ! -z "${icon}" ]; then
	_ct_icon_fname=$( basename "$icon" )
	_host_icon_dir="${_host_xdg_dir}/icons/$container"
	mkdir -p "$_host_icon_dir"
	_host_icon="$_host_icon_dir/$_ct_icon_fname"
	podman cp "$container":"$icon" "$_host_icon"
fi

_host_apps_dir="${_host_xdg_dir}/applications"
_host_desktop_entry=$( echo "${container}-${name}" | sed 's/ /_/' )
mkdir -p "$_host_apps_dir"
cat << EOF > "${_host_apps_dir}/${_host_desktop_entry}.desktop"
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=$name (on $container)
Icon=$_host_icon
Exec=/usr/bin/distrobox-enter -n $container -- $exec
EOF

