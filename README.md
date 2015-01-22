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
 - Vagrant >=1.6.0
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
 7. You can start OSTF server with:

    ```
    host $ vagrant ssh ostf-dev
    guest $ cd ~/Documents/fuel-ostf
    guest $ source ubuntu-venv/bin/activate
    guest $ ostf-server --debug --config-file ./etc/ostf/ostf.conf
    ```

## Known issues
 - This was only tested on OS X 10.9 so far.
 - Windows is **not** supported due to NFS dependency.
 - There might be issues with OSX filesystem (AFS) due to it's case
   insensitivity.
 - Other people may find fabric scripts more convenient for setting up dev
   enviroment
