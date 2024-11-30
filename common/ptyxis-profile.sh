#!/bin/bash

print_usage() {
  echo "Usage: $(basename "$0") [options]
 
  Options:
    -n, --container-name <name>       Container name
    -i, --container-id <id>           Container ID
    -l, --label <label>               User-defined label
    -h, --help                        Print this help message and exit
 
  Required options:
    --label must be provided.

  Exclusive options:
    Only one of --container-name or --container-id can be used."
}

parse_arguments() {
  declare -g CONTAINER_NAME=""
  declare -g CONTAINER_ID=""
  declare -g LABEL=""

  while getopts ":n:i:l:h" opt; do
      case $opt in
          n) CONTAINER_NAME="$OPTARG";;
          i) CONTAINER_ID="$OPTARG";;
          l) LABEL="$OPTARG";;
          h) print_usage; exit ;;
          \?) echo "Invalid option -- '$OPTARG'." >&2; exit 1 ;;
          :) echo "Option '--${opt}' requires an argument." >&2; exit 1 ;;
      esac
  done

  shift $((OPTIND - 1))
}

validate_params() {
  # Validate that we received required arguments
  if [ -z "$LABEL" ]; then
    echo "Error: --label is a required parameter."
    exit 1
  fi

  # Check if both name and id are provided, but not both
  if [ ! -z "$CONTAINER_NAME" ] && [ ! -z "$CONTAINER_ID" ]; then
    echo "Error: Exactly one of --container-name and --container-id must be provided."
    exit 1
  elif [ -n "$CONTAINER_NAME" ] || [ -n "$CONTAINER_ID" ]; then
    if [ -n "$CONTAINER_NAME" ]; then
      CONTAINER=$CONTAINER_NAME
    else
      CONTAINER=$CONTAINER_ID
    fi
  else
    echo "Error: Neither --container-name nor --container-id are provided."
    exit 1
  fi

  # Print values for debugging purposes
  echo "Label: $LABEL"
  echo "Container ID: $CONTAINER_ID"
  echo "Container Name: $CONTAINER_NAME"
}

find_ptyxis_profile() {
  target_label=$1
  PTYXIS_PROFILES=$(dconf list /org/gnome/Ptyxis/Profiles/| while read line; do echo "${line::-1}"; done)
  for profile in $PTYXIS_PROFILES; do
    label=$(dconf read /org/gnome/Ptyxis/Profiles/$profile/label)
    label=${label#\'}
    label=${label%\'}
    if [ "$label" = "$target_label" ]; then
      container=$(dconf read /org/gnome/Ptyxis/Profiles/$profile/default-container)
      container=${container:1:12}
      echo "$profile"
      echo "$container"
      return
    fi
  done
}

strip_edge_char() {
  local str=$1
  local char=$2
  str=${str#"${str%%[!$char]*}"}
  str="${str%"${str##*[!$char]}"}"
  echo "$str"
}

# Call the new function to parse arguments
parse_arguments "$@"
validate_params

profile_info=($(find_ptyxis_profile "$LABEL"))
profile_id=${profile_info[0]}
profile_container_sid=${profile_info[1]}

distrobox_container=$(distrobox ls | grep $profile_container_sid | cut -d' ' -f1)
if [ ! -z "$distrobox_container" ]; then
  podman_container=$(podman inspect $distrobox_container --format='{{.ID}}')
fi

if [ ! -z "$podman_container" ]; then
  distrobox_name=$(distrobox ls | grep $profile_container_sid | cut -d'|' -f2)
  distrobox_name=$(strip_edge_char "${distrobox_name}" " ")
  echo "Profile $profile_id is called $LABEL with existing container $profile_container_sid with distrobox name _${distrobox_name}_"
else
  distrobox_id=$(distrobox ls | grep $CONTAINER_NAME | cut -d'|' -f1)
  distrobox_id=$(strip_edge_char "${distrobox_id}" " ")
  echo "Profile $profile_id is called $LABEL with MISSING container $profile_container_sid with distrobox id _${distrobox_id}_"
  if [ ! -z "${distrobox_id}" ]; then
    podman_container=$(podman inspect $distrobox_id --format='{{.ID}}')
    echo "Found distrobox container with matching id: $distrobox_id for name: ${CONTAINER_NAME}"
    echo "Podman container full id: $podman_container"
    gsettings set org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/${profile_id}/ default-container ${podman_container}
  else
    echo "Also unable to find distrobox container with matching name: ${CONTAINER_NAME}"
  fi
fi

