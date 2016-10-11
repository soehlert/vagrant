#!/bin/bash

VERSION=2.5

function die {
    echo $*
    exit 1
}

function pre_setup {
    yum update > /dev/null
}

function install_prereqs {
  yum -y install curl cmake make gperftools gcc gcc-c++ flex bison libpcap-devel openssl-devel python-devel swig zlib-devel
}

function install_geoIP {
  yum -y install GeoIP
  if [ -e /usr/share/GeoIP/GeoIPCity.dat ]; then
    echo "GeoIP data already installed"
    return
  fi
  if [ ! -e GeoLiteCity.dat.gz ]; then
    echo "downloading GeoIP data"
    wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz --progress=dot:mega
  fi
  if [ ! -e GeoLiteCity.dat.gz ]; then
    echo "unzipping the data"
    gunzip GeoLiteCity.dat.gz
  fi
  mv GeoLiteCity.dat /usr/share/GeoIP/GeoIPCity.dat
}

function install_bro {
  if [ -e /usr/local/bro/bin/bro ] ; then
      echo "bro already installed"
      return
  fi
  if [ ! -e bro-${VERSION}.tar.gz ] ; then
      echo "downloading bro"
      wget -c http://www.bro.org/downloads/release/bro-${VERSION}.tar.gz --progress=dot:mega
  fi
  if [ ! -e bro-${VERSION} ] ; then
      echo "untarring bro"
      tar xzf bro-${VERSION}.tar.gz
  fi
  cd bro-${VERSION}
  ./configure || die "configure failed"
  make || die "build failed"
  sudo make install || die "install failed"
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
install_geoIP
install_bro
configure_bro

exit 0
