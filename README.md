# python-package-github-action

Create Python distribution packages: source, wheel and Debian packages

## Features

- Create Python source and wheel packages
- Create Debian packages for Python libraries and applications
- Cross-platform package creation using QEMU, Docker buildx and devcontainer

## Inputs

- `package-version`: Version of the package to create (if not provided, will use the given git tag)
- `is-cross-platform`: Create cross-platform packages using Docker buildx and QEMU (default: `false`)

### Platform independent or native package creation

- `python-version`: Python version to use for the package creation (default: `3.9`)
- `add-source-dist`: Add source distribution to the package creation (default: `true`)
- `add-wheel-dist`: Add wheel distribution to the package creation (default: `true`)
- `debian-dist-type`: Type of the Debian package to create: `library`/`application`/`none` (default: `none`)
- `debian-dist-command`: Command to run for the Debian package creation (default: FPM build for libraries, dh-virtualenv for applications)

### Cross-platform package creation

- `docker-registry`: Docker registry to use (default: `docker.io`)
- `docker-username`: Docker registry username
- `docker-password`: Docker registry password
- `devcontainer-config`: Devcontainer configuration selector `.devcontainer/<config>/devcontainer.json` (if not specified, it will use `.devcontainer/devcontainer.json`)
- `devcontainer-command`: Command to run in the devcontainer

## Outputs

- `upload-name`: Name of the uploaded artifact (repository name)

## Usage

### Create Python library packages

Will generate source and wheel packages.
In addition, it will create a Debian package for the library using FPM: python3-<library>.deb
Upon installing on a Debian system, it will install the library to the system's Python3 environment.

```yaml
jobs:
  package:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: EffectiveRange/python-package-github-action@v1
        with:
          debian-dist-type: 'library'
```

### Create Python application packages

Will generate source and wheel packages.
In addition, it will create a Debian package for the application using dh-virtualenv: <application>.deb

> [!Note]
> The application should have the `debian` directory with the necessary files for the package creation.

```yaml
jobs:
  package:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: EffectiveRange/python-package-github-action@v1
        with:
          debian-dist-type: 'application'
          debian-dist-command: 'make package'
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
          is-cross-platform: 'true'
          debian-dist-type: 'application'
          docker-username: ${{ secrets.DOCKERHUB_USERNAME }}
          docker-password: ${{ secrets.DOCKERHUB_TOKEN }}
          devcontainer-config: 'arm32v7'
          devcontainer-command: '.devcontainer/build.sh'
```
