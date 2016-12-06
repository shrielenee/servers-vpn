#!/bin/bash

if python -mplatform | grep -qi Ubuntu; then
    apt-get install -y openvpn easy-rsa zip
else
    yum --enablerepo=* install -y openvpn easy-rsa zip
fi
