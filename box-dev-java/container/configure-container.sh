#!/bin/bash

sudo mkdir -p /opt/sdk
sudo chown "$(id -un)":"$(id -gn)" /opt/sdk
echo Installing SDKMAN
export SDKMAN_DIR="/opt/sdk/sdkman" && curl -s "https://get.sdkman.io?rcupdate=false" | bash
chsh -s /bin/bash
bash -l -c ". /opt/sdk/sdkman/bin/sdkman-init.sh ; sdk install java 21-local /usr/lib/jvm/java-21-openjdk-amd64"
bash -l -c ". /opt/sdk/sdkman/bin/sdkman-init.sh ; sdk install maven 3.8-local /usr/share/maven"
bash -l -c ". /opt/sdk/sdkman/bin/sdkman-init.sh ; sdk default java 21-local"
bash -l -c ". /opt/sdk/sdkman/bin/sdkman-init.sh ; sdk default maven 3.8-local"
bash -l -c ". /opt/sdk/sdkman/bin/sdkman-init.sh ; sdk version ; sdk current"

