# Minimum viable scaffold for Python 2025

This is a sample project for VS Code with modern technologies

- Dev container to install a clean environment across workstations
- MISE en place for installation of Python and tools
- UV for python dependency management

## Dev container

The dev container is a base Linux image without any tooling, as we prefer to use MISE to install tools. For this reason, we use the following dev container settings:

- Extensions that explicitly install Python tooling
- The MISE "feature" which ensures `mise` is available in the container
- A `postCreateCommand` to invoke script `postCreate.sh`

## Python virtual environment

The file `mise.toml` is used by `postCreate.sh` to install:
    - Python
    - uv
    - ripgrep

The file `pyproject.toml` is used by `postCreate.sh` to create the python virtual environment with UV.

> To see which packages are installed, use `uv pip list` as the virtual environment is managed by UV. A SIMPLE `pip list` will not show the contents of the virtual environment.
