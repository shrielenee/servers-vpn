#!/bin/bash

if python -mplatform | grep -qi Ubuntu; then
    systemctl start openvpn@openvpn.service
else
    /etc/init.d/openvpn restart
fi

