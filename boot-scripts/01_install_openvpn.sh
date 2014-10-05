#!/bin/bash

openvpn_version=2.3.4

yum -y groupinstall "Development Tools"
yum -y install openssl-devel lzo-devel pam-devel

tmp_dir="$(mktemp -d)"
(
    cd "$tmp_dir"
    RC="1"
    while test "$RC" != "0"; do
	wget "http://swupdate.openvpn.org/community/releases/openvpn-${openvpn_version}.tar.gz"
	RC="$?"
	if test "$RC" != "0"; then
	    sleep 1
	fi
    done
    tar xfz "openvpn-${openvpn_version}.tar.gz"
    (
	cd openvpn-${openvpn_version}
	./configure
	make
	make install
    )
)
rm -rf "$tmp_dir"
