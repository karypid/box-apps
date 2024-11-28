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
	--launcher/-l:          launcer (toolbox or distrobox)
        --wmclass/-w:           set StartupWMClass property to this value
	--verbose/-v:           show more verbosity
        --help/-h:              show this message
EOF
}

launcher=""
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
                -l | --launcher)
                        if [ -n "$2" ]; then
                                launcher="$2"
                                shift
                                shift
                        fi
                        ;;
                -w | --wmclass)
                        if [ -n "$2" ]; then
                                wmclass="$2"
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

if [ -z "${launcher}" ]; then
	[[ "${container}" == tbox* ]] && launcher=toolbox
	[[ "${container}" == dbox* ]] && launcher=distrobox
fi
if [ "${launcher}" == "distrobox" ]; then
	_launch_cmd="/usr/bin/distrobox-enter -n \"$container\""
elif [ "${launcher}" == "toolbox" ]; then
	_launch_cmd="/usr/bin/toolbox run -c \"$container\""
else
        printf >&2 "Error: missing launcher and/or container name does not start with tbox/dbox.\n"
        exit 2
fi
#echo "Launcher type: ${launcher} -- ${_launch_cmd}"

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
	if [[ ! ${_host_icon##*.xpm} ]]; then
		_host_png_icon=${_host_icon%.xpm}.png
		echo "Converting icon to png in: ${_host_png_icon}"
		magick "${_host_icon}" "${_host_png_icon}" && rm -f "${_host_icon}"
		_host_icon=${_host_png_icon}
	fi
fi



_host_apps_dir="${_host_xdg_dir}/applications"
_host_desktop_entry=$( echo "${container}-${name}" | sed 's/ /_/' )
_host_desktop_file="${_host_apps_dir}/${_host_desktop_entry}.desktop"
mkdir -p "$_host_apps_dir"
cat << EOF > "${_host_desktop_file}"
[Desktop Entry]
Encoding=UTF-8
Type=Application
Name=$name (on $container)
Icon=$_host_icon
Exec=$_launch_cmd -- $exec
EOF
if [ ! -z "$wmclass" ]; then
	echo "StartupWMClass=$wmclass" >> "${_host_desktop_file}"
fi

