#!/bin/bash

sudo mkdir -p /opt/sdk
sudo chown "$(id -un)":"$(id -gn)" /opt/sdk
export SDKMAN_DIR="/opt/sdk/sdkman" && curl -s "https://get.sdkman.io" | bash
chsh -s /bin/bash
bash -l -c "sdk install java 21-local /usr/lib/jvm/java-21-openjdk-amd64"
bash -l -c "sdk install maven 3.8-local /usr/share/maven"
bash -l -c "sdk default java 21-local"
bash -l -c "sdk default maven 3.8-local"
bash -l -c "sdk version ; sdk current"

