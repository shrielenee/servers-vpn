#!/bin/bash
set -eux

restart=0
if ! grep -q -i '[^#]\s*push\s*\"redirect-gateway\s*def1\s*bypass-dhcp\"' /etc/openvpn/openvpn.conf; then
    perl -i -pe 's{(^push\s*\"redirect-gateway\s*def1\s*bypass-dhcp\")}{# \\1}g' /etc/openvpn/openvpn.conf
    restart=1
fi

if ! grep -q -i 'push\s*\"route 10.0.0.0 255.0.0.0\"' /etc/openvpn/openvpn.conf; then
    echo 'push "route 10.0.0.0 255.0.0.0"' >> /etc/openvpn/openvpn.conf
    restart=1
fi

if [ "$restart" == 1 ]; then
    /etc/init.d/openvpn restart
fi

