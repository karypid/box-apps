#!/bin/bash

sudo mkdir -p /opt/sdk
sudo chown "$(id -un)":"$(id -gn)" /opt/sdk
export SDKMAN_DIR="/opt/sdk/sdkman" && curl -s "https://get.sdkman.io" | bash
chsh -s /bin/bash
bash -l -c " sdk install java 21.0.4-tem ; sdk version"

