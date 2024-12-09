# Build the image

There are multiple ways to build the image: cloud-based, local and local-containerized.

## cloud-based

We use GitHub Actions to build the image. The job is defined in [.github/workflow/build-image.yml](https://github.com/batchworksde/iksdp_desktop/actions/workflows/build-image.yml).

As soon as you open a new development branch, commit, and push changes within the `debian-live` directory, the build process will run. It will take about 30 minutes to complete.

When the build is successful, the image is copied to [http://iksdp.pfadfinderzaunten.org](http://iksdp.pfadfinderzaunten.org). The image will remain accessible there for 5 days.


## local build 

The local build must be run on a Debian-based distribution. We have tested Ubuntu 24.04, which is also used by the cloud-based build.

run the local build:

```bash
git clone https://github.com/batchworksde/iksdp_desktop.git
cd iksdp_desktop
./debian-live/build.sh localBuild
```

***optional: using local apt proxy***

It can be helpful to use a local APT proxy, such as `apt-cacher-ng`.

Install the proxy:
```bash
apt install apt-cacher-ng -y
```

Set the `LB_APT_HTTP_PROXY` environment variable to your APT proxy location:

```bash
LB_APT_HTTP_PROXY="http://localhost:3142"
```

## Local-Containerized

If you do not have access to a Debian-based distribution, but still want to build locally, this option is for you.

As a prerequisite, have Docker or Podman installed.

Run the local containerized build:

```bash
git clone https://github.com/batchworksde/iksdp_desktop.git
cd iksdp_desktop
./debian-live/container-build.sh -a

Use apt caching proxy (highly recommended)? [Y|n]:Y
Apt caching proxy URL [http://localhost:3142]:
```

As you can see, the APT proxy location is configurable when running the build script.

## Target Directory

When the build is successful, the `*.iso` file will be accessible in the directory specified by `BUILD_DIR`.

```sh
grep BUILD_DIR debian-live/build.env
BUILD_DIR="build"
s -1 build/*.mso
build/debian-live-bookworm-0.2.0-20241209171119-arm64.hybrid.iso
```

