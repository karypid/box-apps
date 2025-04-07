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

  # Check that exactly one of container name or id are provided
  if [ ! -z "$CONTAINER_NAME" ] && [ ! -z "$CONTAINER_ID" ]; then
    echo "Error: Exactly one of --container-name and --container-id must be provided, but not both."
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
  test ! -z "$CONTAINER_ID" && echo "Container ID: $CONTAINER_ID"
  test ! -z "$CONTAINER_NAME" && echo "Container Name: $CONTAINER_NAME"
}

# Looks up the profile id for a given profile name, along with its 
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

find_distrobox_container() {
  distrobox_container=$(distrobox ls | grep $1 | cut -d' ' -f1)
  if [ ! -z "$distrobox_container" ]; then
    podman_container=$(podman inspect $distrobox_container --format='{{.ID}}') || return
    echo "$distrobox_container | $podman_container"
  fi
}

find_toolbox_container() {
  toolbox_container=$(toolbox list --containers | grep $1 | cut -d' ' -f1)
  if [ ! -z "$toolbox_container" ]; then
    podman_container=$(podman inspect $toolbox_container --format='{{.ID}}') || return
    echo "$toolbox_container | $podman_container"
  fi
}

parse_arguments "$@"
validate_params

profile_info=($(find_ptyxis_profile "$LABEL"))
test -z "$profile_info" && ( echo "Could not find ptyxis profile for: $LABEL" ; exit 1 )
profile_id=${profile_info[0]}
profile_container_sid=${profile_info[1]}
echo "Profile id: $profile_id"
echo "Profile short container id sid: $profile_container_sid"

echo Checking existence of $profile_container_sid in distrobox...
r=$(find_distrobox_container $profile_container_sid)
distrobox_container=$(echo $r | cut -d'|' -f1)
podman_container=$(echo $r | cut -d'|' -f2)
if [ -z "$podman_container" ]; then
  echo Checking existence of $profile_container_sid in toolbox...
  r=$(find_toolbox_container $profile_container_sid)
  toolobox_container=$(echo $r | cut -d'|' -f1)
  podman_container=$(echo $r | cut -d'|' -f2)
fi

if [ ! -z "$podman_container" ]; then
  box_name=$(toolbox list --containers | grep $profile_container_sid | cut -d' ' -f3)
  box_name=$(strip_edge_char "${box_name}" " ")
  echo "Profile $profile_id is called $LABEL with existing container $profile_container_sid and distrobox name _${box_name}_"
  gsettings list-recursively org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/$profile_id/
  echo "NOT touching existing config..."
  test ! "$box_name" = "$CONTAINER_NAME" && echo NOTE: THE CONTAINER FOUND \($box_name\) DOES NOT MATCH GIVEN \($CONTAINER_NAME\)
  exit 1
fi

echo Container $profile_container_sid in profile no longer exists, safe to overwrite with $CONTAINER_NAME

echo Checking distrobox for $CONTAINER_NAME
r=$(find_distrobox_container $CONTAINER_NAME)
box_container=$(echo $r | cut -d'|' -f1)
if [ -z "$box_container" ]; then
  echo Checking toolbox for $CONTAINER_NAME
  r=$(find_toolbox_container $CONTAINER_NAME)
  box_container=$(echo $r | cut -d'|' -f1)
  echo Found in toolbox: $box_container
else
  echo Found in distrobox: $box_container
fi
podman_container=$(echo $r | cut -d'|' -f2)

if [ ! -z "$podman_container" ]; then
  echo "Profile $profile_id is called $LABEL with MISSING container $profile_container_sid - replacing with $podman_container"
  gsettings set org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/${profile_id}/ default-container ${podman_container}
fi

