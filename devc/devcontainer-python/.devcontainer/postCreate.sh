#!/bin/zsh

# Configure shell to activate mise
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc

# Trust project folder and install tools from mise.toml
mise trust
mise install

# activate mise so that we can invoke tool "uv"
eval "$(mise activate zsh)"

# Create the virtual environment with modules of pyproject.toml
uv sync
