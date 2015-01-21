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

sudo apt-get install git vim python-virtualenv python-pip postgresql postgresql-contrib libpq-dev python-dev libevent-dev libffi-dev -y

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

if [[ -f $OSTF_SOURCES/requirements.txt ]]; then
    pushd $OSTF_SOURCES
    VENV_NAME=ubuntu-venv
    run virtualenv $VENV_NAME
    run PATH=$OSTF_SOURCES/$VENV_NAME/bin:$PATH env pip install -r requirements.txt
    run PATH=$OSTF_SOURCES/$VENV_NAME/bin:$PATH env python setup.py develop

    SQLALCHEMY_URL=$(grep '^sqlalchemy\.url.*=.*' $(find $OSTF_SOURCES -name 'alembic.ini'))
    DB_USER=$(echo $SQLALCHEMY_URL | sed -r 's?.*//(\w+):(\w+)@(\w+)/.*?\1?')
    DB_PASS=$(echo $SQLALCHEMY_URL | sed -r 's?.*//(\w+):(\w+)@(\w+)/.*?\2?')
    OSTF_DB_NAME=$(echo $SQLALCHEMY_URL | sed -r 's?.*//(\w+):(\w+)@(\w+)/(\w+).*?\4?')
    sudo -u postgres psql -c "CREATE DATABASE $OSTF_DB_NAME;"
    sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASS';"
    echo "local $OSTF_DB_NAME $DB_USER trust" >> $(find /etc -name 'pg_hba.conf')
    /etc/init.d/postgresql restart
    run PATH=$OSTF_SOURCES/$VENV_NAME/bin:$PATH env alembic -c $(find $OSTF_SOURCES -name 'alembic.ini') upgrade head
    popd
else
    die "Missing requirements.txt file, make sure $OSTF_SOURCES contains fuel-ostf sources"
fi

echo "OSTF dev environment successfully set!"
