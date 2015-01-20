# OSTF development environment

## Purpose
Sets up OSTF development environment:
 - Ubuntu 12.04;
 - Installs all OSTF requirements;
 - Mounts host's home dir to guest home

## Links
 - [OSTF contirbutor's guide](http://docs.mirantis.com/fuel-dev/develop/ostf_contributors_guide.html)
 - [OSTF source code](https://github.com/stackforge/fuel-ostf)

## Prerequisites
 - Virtualbox
 - Vagrant
 - NFS server

## Recommendation
 - OS X users may want to use Homebrew to easily manage prerequisites

## Usage
 1. Make sure your system has all the prerequisites installed
 2. Set `OSTF_DIR` in Vagrantfile to a path where you want your OSTF sources
 3. Boot VM out of the work dir:

    ```
    $ cd ~/Documents/ostf-dev-env
    $ vagrant up ostf-dev
    ```
 4. Type your password when asked (this is needed for NFS export)
 5. If all goes well you will be able to SSH into the VM:

    ```
    $ vagrant ssh ostf-dev
    ```
 6. OSTF code by default is available in `~/Documents/ostf-fuel`

## Known issues
 - This was only tested on OS X 10.9 so far.
 - Windows is **not** supported due to NFS dependency.
 - There might be issues with OSX filesystem (AFS) due to it's case
   insensitivity.
