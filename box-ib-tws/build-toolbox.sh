#!/bin/sh

_container=${1:-tbox-ib-tws}
echo "Building image/container: $_container"

podman image build -t "$_container" . && \
    toolbox create -i "$_container:latest" "$_container"

# Actual installation using logged in account's uid/gid
toolbox run -c "$_container" -- sh /container/configure-container.sh stable
toolbox run -c "$_container" -- sh /container/configure-container.sh latest

# export apps to host
../common/create-desktop-entry.sh --container $_container \
	--exec "sh -c \"GDK_BACKEND=x11 /inst/tws/stable/tws -J-DjtsConfigDir=/home/karypid@ad.home.lan/Jts %U\"" \
	--icon /inst/tws/stable/.install4j/tws.png --name "IB TWS 10.19" --wmclass install4j-jclient-LoginFrame
../common/create-desktop-entry.sh --container $_container \
	--exec "sh -c \"GDK_BACKEND=x11 /inst/tws/latest/tws -J-DjtsConfigDir=/home/karypid@ad.home.lan/Jts %U\"" \
	--icon /inst/tws/latest/.install4j/tws.png --name "IB TWS 10.31" --wmclass install4j-jclient-LoginFrame

