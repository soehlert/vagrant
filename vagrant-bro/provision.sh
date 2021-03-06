#!/bin/bash

VERSION=2.5
DEV_VERSION="yes"

function die {
    echo $*
    exit 1
}

function pre_setup {
    yum update > /dev/null
}

function install_prereqs {
  yum -y install curl cmake make gperftools gcc gcc-c++ flex bison libpcap-devel openssl-devel python-devel swig wget zlib-devel
  if [ DEV_VERSION="yes" ]; then
    yum -y install git
  fi
}

function download_bro {
  if [ -e /usr/local/bro/bin/bro ] ; then
      echo "bro already installed"
      return
  fi
  if  DEV_VERSION="yes" ; then
    git clone --recursive git://git.bro.org/bro
  else:
    if [ ! -e bro-${VERSION}.tar.gz ] ; then
      echo "downloading bro"
      wget -c http://www.bro.org/downloads/release/bro-${VERSION}.tar.gz --progress=dot:mega
    fi
    if [ ! -e bro-${VERSION} ] ; then
      echo "untarring bro"
      tar xzf bro-${VERSION}.tar.gz
    fi
  fi
}

function install_bro {
  if DEV_VERSION="yes"; then
    cd bro
    ./configure || die "configure failed"
    make || die "build failed"
    sudo make install || die "install failed"
  else:
    cd bro-${VERSION}
    ./configure || die "configure failed"
    make || die "build failed"
    sudo make install || die "install failed"
  fi
}

function configure_bro {
    if [ ! -e /bro ]; then
        ln -s /usr/local/bro /bro
    fi
    if [ ! -e /bro/site ]; then
        (cd /bro ; ln -s share/bro/site . )
    fi
}

pre_setup
install_prereqs
download_bro
install_bro
configure_bro

exit 0
