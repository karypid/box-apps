#!/bin/sh

echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
mise trust
mise install
