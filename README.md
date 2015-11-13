servers-vpn
======================================================================
This Stack will add a VPN server to your CloudCoreo deployment

## Description

This will bring up an openvpn server in the private subnet in an autoscale group behind an elb. The elb will forward tcp port 1199 to the vpn box so that the endpoint will remain static even in the event of a server failure and autoscale group relaunch.

There are a few things to know about this server.

The first time this comes up, it will find there are no keys generated for the system. When that discovery is made, it will generate all necessary keys and upload a zip file to the specified s3 bucket.

In addition to uploading the keys, there will be an initial user with which you may log in. The username is vpnadmin and the password is generated randomly and included in the zip file in the s3 bucket.

Backups will be performed every hour. The usernames allowed in the system are simply users on the linux OS. (useradd command generated)

## Variables Requiring Your Input

### `BACKUP_BUCKET`:
  * description: the name of the bucket in which we should back things up

### `BACKUP_BUCKET_REGION`:
  * description: the region where there vpn backups bucket was created

### `VPN_KEY_BUCKET`:
  * description: the name of the bucket in which we should retrieve and/or store vpn keys

### `VPN_KEY_BUCKET_REGION`:
  * description: the region where there vpn key bucket was created

### `VPN_SSH_KEY_NAME`:
  * description: What key should the vpn instance be launched with?

### `DNS_ZONE`:
  * description: the dns entry for the zone (i.e. example.com)

## Variables Required but Defaulted

### `PRIVATE_SUBNET_NAME`:
  * default: my-private-subnet

### `PRIVATE_ROUTE_NAME`:
  * description: the name to give to the private route
  * default: my-private-route

### `PUBLIC_ROUTE_NAME`:
  * description: the name to give to the public route
  * default: my-public-route

### `PUBLIC_SUBNET_NAME`:
  * default: my-public-subnet

### `VPC_NAME`:
  * default: my-vpc

### `VPN_BACKUP_CRON`:
  * description: the cron schedule for backups
  * default: 0 * * * *

### `ENV`:
  * default: test

### `VPC_OCTETS`:
  * default: 10.0.0.0

### `VPN_ACCESS_CIDRS`:
  * default: 0.0.0.0/0

### `REGION`:
  * description: the region we are launching in
  * default: INSTANCE::region

### `VPN_DNS_PREFIX`:
  * description: the dns entry to create for the VPN server (<prefix>.<zone>)
  * default: vpn

### `VPN_INSTANCE_TYPE`:
  * default: t2.micro

### `VPN_NAME`:
  * description: the name of the vpn server to launch
  * default: vpn

### `BACKUP_BUCKET`:
  * description: the name of the bucket in which we should back things up

### `BACKUP_BUCKET_REGION`:
  * description: the region where there vpn backups bucket was created

### `VPN_KEY_BUCKET`:
  * description: the name of the bucket in which we should retrieve and/or store vpn keys

### `VPN_KEY_BUCKET_REGION`:
  * description: the region where there vpn key bucket was created

### `VPN_SSH_ACCESS_CIDRS`:
  * description: The cidrs from where you should be able to ssh in
  * default: 10.0.0.0/8

### `VPN_SSH_KEY_NAME`:
  * description: What key should the vpn instance be launched with?

### `DNS_ZONE`:
  * description: the dns entry for the zone (i.e. example.com)

## Variables Not Required

**None**

## Tags

1. Self-Healing
1. Networking
1. VPN


## Diagram

## Icon

