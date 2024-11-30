#!/bin/sh

_container=${1:-dbox-ib-tws}
echo "Building image/container: $_container"

podman image build -t "$_container" . && \
    DBX_CONTAINER_MANAGER=podman DBX_CONTAINER_ALWAYS_PULL=0 distrobox create --image $_container:latest --name $_container

# Actual installation using logged in account's uid/gid
distrobox enter -n "$_container" -- sh /container/configure-container.sh stable
distrobox enter -n "$_container" -- sh /container/configure-container.sh latest

# export apps to host
../common/create-desktop-entry.sh --container $_container \
	--exec "sh -c \"GDK_BACKEND=x11 /inst/tws/stable/tws -J-DjtsConfigDir=/home/karypid@ad.home.lan/Jts %U\"" \
	--icon /inst/tws/stable/.install4j/tws.png --name "IB TWS (stable)" --wmclass install4j-jclient-LoginFrame
../common/create-desktop-entry.sh --container $_container \
	--exec "sh -c \"GDK_BACKEND=x11 /inst/tws/latest/tws -J-DjtsConfigDir=/home/karypid@ad.home.lan/Jts %U\"" \
	--icon /inst/tws/latest/.install4j/tws.png --name "IB TWS (latest)" --wmclass install4j-jclient-LoginFrame

