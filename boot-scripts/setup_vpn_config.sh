#!/bin/bash

push "route 10.0.0.0 255.0.0.0"

restart=0
if ! "$(cat /etc/openvpn/openvpn.conf)" | grep -q -i '[^#]\s*push\s*\"redirect-gateway\s*def1\s*bypass-dhcp\"'; then
    perl -i -pe 's{(^push\s*\"redirect-gateway\s*def1\s*bypass-dhcp\")}{# \\1}g' /etc/openvpn/openvpn.conf
    restart=1
fi
if ! "$(cat /etc/openvpn/openvpn.conf)" | grep -q -i 'push\s*\"route 10.0.0.0 255.0.0.0\"'; then
    echo 'push "route 10.0.0.0 255.0.0.0"' >> /etc/openvpn/openvpn.conf
    restart=1
fi

if [ "$restart" == 1 ]; then
    /etc/init.d/openvpn restart
fi

