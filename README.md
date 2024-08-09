# python-package-github-action

Create Python distribution packages: source, wheel and Debian packages

## Table of Contents

- [Features](#features)
- [Inputs](#inputs)
  - [Platform independent or native package creation](#platform-independent-or-native-package-creation)
  - [Cross-platform package creation](#cross-platform-package-creation)
- [Outputs](#outputs)
- [Usage](#usage)
  - [Create Python packages with FPM](#create-python-packages-with-fpm)
  - [Create Python packages with dh-virtualenv](#create-python-packages-with-dh-virtualenv)
  - [Create cross-platform Python application packages](#create-cross-platform-python-application-packages)

## Features

- Create Python source and wheel packages
- Create Debian packages from Python projects (supports [FPM](https://fpm.readthedocs.io/en/latest/)
  and [dh-virtualenv](https://dh-virtualenv.readthedocs.io/en/latest/) packaging)
- Cross-platform package creation using QEMU, Docker buildx and devcontainer

## Inputs

- `package-version`: Version of the package to create (if not provided, will use the given git tag)
- `use-devcontainer`: Create packages using a devcontainer (default: `false`)
- `pre-build-command`: Command to run before the package creation
- `post-build-command`: Command to run after the package creation

### Platform independent or native package creation

- `python-version`: Python version to use for the package creation (default: `3.9`)
- `add-source-dist`: Add source distribution to the package creation (default: `true`)
- `add-wheel-dist`: Add wheel distribution to the package creation (default: `true`)
- `debian-dist-type`: Type of the Debian package to create: `fpm-deb`/`dh-virtualenv`/`none` (default: `none`)
- `debian-dist-command`: Command to run for the Debian package creation (default: `pack_python . -s fpm-deb` or `pack_python . -s dh-virtualenv`)

### Cross-platform package creation

- `docker-registry`: Docker registry to use (default: `docker.io`)
- `docker-username`: Docker registry username
- `docker-password`: Docker registry password
- `container-platform`: Devcontainer platform (eg. `linux/amd64,linux/arm64,linux/arm/v7`, default: `linux/amd64`)
- `container-config`: Devcontainer configuration selector `.devcontainer/<config>/devcontainer.json` (if not
  specified, it will use `.devcontainer/devcontainer.json`)
- `packaging-folder`: Optional subfolder for running the packaging command (default: `.`)
- `packaging-command`: Command to run in the devcontainer

## Outputs

- `upload-name`: Name of the uploaded artifact (repository name)

## Usage

### Create Python packages with FPM

Will generate source and wheel packages.
In addition, it will create a Debian package using FPM: python3-<library>.deb
Upon installing on a Debian system, it will install the library to the system's Python3 environment.

```yaml
jobs:
  package:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: EffectiveRange/python-package-github-action@v1
        with:
          debian-dist-type: 'fpm-deb'
```

### Create Python packages with dh-virtualenv

Will generate source and wheel packages.
In addition, it will create a Debian package using dh-virtualenv: <application>.deb

```yaml
jobs:
  package:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: EffectiveRange/python-package-github-action@v1
        with:
          debian-dist-type: 'dh-virtualenv'
```

### Create cross-platform Python application packages

Will build the platform dependent packages in a devcontainer using a build script or command.

> [!Note]
> The application should have a `devcontainer.json` configuration with the necessary setup.

```yaml
jobs:
  package:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: EffectiveRange/python-package-github-action@v1
        with:
          use-devcontainer: 'true'
          docker-username: ${{ secrets.DOCKERHUB_USERNAME }}
          docker-password: ${{ secrets.DOCKERHUB_TOKEN }}
          container-platform: 'linux/arm/v7'
          container-config: 'arm32v7'
          packaging-command: 'pack_python . --all'
```
