#!/bin/bash
######################################################################
##
## Variables in the script:
##   REQUIRED
##     - VPN_KEY_BUCKET
##     - VPN_KEY_BUCKET_REGION
##     - VPN_NAME
##   - VPN_PORT
##   - VPN_PROTO
##   - VPN_CIDR
##
######################################################################

set -eux

restart=0
OPENVPN="/etc/openvpn"
EASY_RSA="${OPENVPN}/easy-rsa"

if [ ! -d "${EASY_RSA}" ]; then
    mkdir -p "${EASY_RSA}"
    cp /usr/share/easy-rsa/2.0/* "${EASY_RSA}/"
fi

files_dir="$(pwd)/../files"

if [ -z "${VPN_PORT:-}" ]; then
    VPN_PORT=1199
fi
if [ -z "${VPN_CIDR:-}" ]; then
    VPN_CIDR="10.8.0.0"
fi
if [ -z "${VPN_PROTO:-}" ]; then
    VPN_PROTO="tcp"
fi
## make sure there are no - or _ in the name, but do NOT overwrite the VPN_NAME
MY_VPN_NAME="$(echo ${VPN_NAME} | perl -pe 's{[-_]}{}g')"
VPN_KEY_ZIP_PATH="vpn/${VPN_NAME}/${VPN_NAME}.zip"

cp "$files_dir/template-server-config" "$OPENVPN/openvpn.conf"
sed -i -e "s/VPN_PROTO/$VPN_PROTO/" -e "s/VPN_PORT/$VPN_PORT/" -e "s/VPN_CIDR/$VPN_CIDR/" $OPENVPN/openvpn.conf

if grep -q "cat <<EOL >> /etc/ssh/sshd_config" /etc/rc.d/rc.local
then
  echo "Note: working around a bug in Amazon EC2 RHEL 6.4 image"
  sed -i.bak 19,21d /etc/rc.d/rc.local 
fi

#ubuntu has exit 0 at the end of the file.
sed -i '/^exit 0/d' /etc/rc.local

echo 1 > /proc/sys/net/ipv4/ip_forward

if ! echo "$(iptables -t nat -L -n)" | grep MASQUERADE | grep -q "$VPN_CIDR/16"; then
    iptables -I INPUT -p $VPN_PROTO --dport $VPN_PORT -j ACCEPT

    iptables -t nat -A POSTROUTING -s "${VPN_CIDR}/16" -d 0.0.0.0/0 -o eth0 -j MASQUERADE
    #default firewall in centos forbids these
    iptables -I FORWARD -i eth0 -o tun0 -j ACCEPT
    iptables -I FORWARD -i tun0 -o eth0 -j ACCEPT

    #not sure if these are really necessary, they probably are the default.
    iptables -t nat -P POSTROUTING ACCEPT
    iptables -t nat -P PREROUTING ACCEPT
    iptables -t nat -P OUTPUT ACCEPT
    iptables-save
fi

## lets just go get the file so we dont have to keep checking s3
aws --region ${VPN_KEY_BUCKET_REGION} s3 cp s3://${VPN_KEY_BUCKET}/${VPN_KEY_ZIP_PATH} /tmp/ || true

## if the file is there, we are good to go, if not we need to generate keys
#setup keys if they dont exist
if [ -f "/tmp/$(basename ${VPN_KEY_ZIP_PATH})" ]; then
    ## just extract the zipped keys to the correct path
    mkdir -p "$EASY_RSA/keys/"
    unzip -d "$EASY_RSA/keys/" "/tmp/$(basename ${VPN_KEY_ZIP_PATH})"
    rm -f "/tmp/$(basename ${VPN_KEY_ZIP_PATH})"
else
    ( 
	cd $EASY_RSA || { echo "Cannot cd into $EASY_RSA, aborting!"; exit 1; }
	if [ ! -d keys ]; then
	    cp "$files_dir/vars" myvars
	    sed -i -e 's/Fort-Funston/$MY_VPN_NAME/' -e 's/SanFrancisco/Simple OpenVPN server/' myvars
	    . ./myvars
	    ./clean-all
	    ./build-dh
	    ./pkitool --initca
	    ./pkitool --server myserver
	    openvpn --genkey --secret keys/ta.key
	    cd "$EASY_RSA/keys"
	    zip "$VPN_NAME.zip" *
	    aws --region ${VPN_KEY_BUCKET_REGION} s3 cp "$VPN_NAME.zip" "s3://${VPN_KEY_BUCKET}/${VPN_KEY_ZIP_PATH}"
	fi
    )
fi

if ! grep -q -i 'username-as-common-name' /etc/openvpn/openvpn.conf; then
    cat <<EOF >> /etc/openvpn/openvpn.conf

## User authentication settings. Usernames must be able to authenticate with PAM
## To use radius or another auth mechanism create /etc/pam.d/openvpn
## by default it is doing common-auth (a user must have a local accout and password)
plugin /usr/lib64/openvpn/plugin/lib/openvpn-auth-pam.so login
username-as-common-name

EOF
fi

if grep -q -i '^push\s*\"redirect-gateway\s*def1\s*bypass-dhcp\"' /etc/openvpn/openvpn.conf; then
    perl -i -pe 's{(push\s*\"redirect-gateway\s*def1\s*bypass-dhcp\")}{# \1}g' /etc/openvpn/openvpn.conf
    restart=1
fi

if ! grep -q -i "push\s*\"route ${VPN_CIDR} 255.0.0.0\"" /etc/openvpn/openvpn.conf; then
    echo "push \"route ${VPN_CIDR} 255.0.0.0\"" >> /etc/openvpn/openvpn.conf
    restart=1
fi

if ! grep -q "^user " /etc/openvpn/openvpn.conf; then
    cat <<EOF >> /etc/openvpn/openvpn.conf

user nobody
group nobody

EOF
    restart=1
fi

if [ "$restart" == 1 ]; then    
    cat <<EOF | bash
/etc/init.d/openvpn restart
EOF
    
fi

echo "done"
exit 0
