#!/bin/bash

set -e

function die() {
    local message=$1
    echo $message 1>&2
    exit 1
}

function run() {
    sudo -u $VAGRANT_USER $*
}

while [[ $# -ge 1 ]]; do
    case $1 in
        --user)      shift; VAGRANT_USER=$1;  shift;;
        --ostf-dir)  shift; OSTF_SOURCES=$1;  shift;;
        *)           die "Invalid option $1" ;;
    esac
done

[[ -z $VAGRANT_USER && $(id -u $VAGRANT_USER) ]] && die "There must be an existing user name supplied. Check your calling script"

if [[ -d $OSTF_SOURCES && -f $OSTF_SOURCES/requirements.txt ]]; then
    echo "Using existing $OSTF_SOURCES dir for OSTF sources"
else
    echo "$OSTF_SOURCES dir does not exist, creating and cloning sources there"

    run mkdir -p ${OSTF_SOURCES}
    pushd $OSTF_SOURCES
    run git init
    run git remote add github https://github.com/stackforge/fuel-ostf.git
    run git fetch github
    run git checkout -b master FETCH_HEAD
    popd
fi

sudo apt-get install git vim python-virtualenv python-pip postgresql postgresql-contrib libpq-dev python-dev libevent-dev -y

if [[ -f $OSTF_SOURCES/requirements.txt ]]; then
    pushd $OSTF_SOURCES
    run virtualenv ubuntu-venv
    run PATH=$OSTF_SOURCES/ubuntu-venv/bin:$PATH env pip install -r requirements.txt
    run PATH=$OSTF_SOURCES/ubuntu-venv/bin:$PATH env python setup.py develop
    popd
else
    die "Missing requirements.txt file, looks like $OSTF_SOURCES points to the wrong directory"
fi

echo "OSTF dev environment successfully set!"
