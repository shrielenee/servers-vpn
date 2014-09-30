This Stack will add a VPN server to your CloudCoreo deployment

This will bring up an openvpn server in the private subnet in an autoscale group behind an elb. The elb will forward tcp port 1199 to the vpn box so that the endpoint will remain static even in the event of a server failure and autoscale group relaunch.