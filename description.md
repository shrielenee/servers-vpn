This will bring up an openvpn server in the private subnet in an autoscale group behind an elb. The elb will forward tcp port 1199 to the vpn box so that the endpoint will remain static even in the event of a server failure and autoscale group relaunch.

There are a few things to know about this server.

The first time this comes up, it will find there are no keys generated for the system. When that discovery is made, it will generate all necessary keys and upload a zip file to the specified s3 bucket.

In addition to uploading the keys, there will be an initial user with which you may log in. The username is vpnadmin and the password is generated randomly and included in the zip file in the s3 bucket.

Backups will be performed every hour. The usernames allowed in the system are simply users on the linux OS. (useradd command generated)