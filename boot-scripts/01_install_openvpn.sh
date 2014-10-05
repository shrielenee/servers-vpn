#!/bin/bash

tmp_dir="$(mktemp -d)"
(
    cd "$tmp_dir"
    RC=0
    while $RC -ne 0; do
	wget http://swupdate.openvpn.org/community/releases/openvpn-2.3.4.tar.gz
	RC=!?
	if $RC -ne 0; then
	    sleep 1
	fi
    done

)
rm -rf "$tmp_dir"