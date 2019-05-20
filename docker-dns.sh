#!/bin/bash
echo "Loading, please wait..."
service squid stop
sleep 15
clear
echo "Starting to install..."
while [[ ! $sqx =~ Y|y|N|n ]]; do
	read -p "Allow anyone to use your Squid? : [Y/y] [N/n] " sqx;done
if [[ ! `which docker` ]]; then
apt install apt-transport-https ca-certificates curl gnupg2 software-properties-common -y
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
apt update
apt-cache policy docker-ce
apt install docker-ce -y; fi
[ -d /etc/_configs ] || mkdir /etc/_configs
IP=$(wget -qO- ipv4.icanhazip.com)
DNUL="/dev/null"
CONFDIR="/etc/_configs"
GITMINE="https://raw.githubusercontent.com/Hira20/VPSauto/master"
docker service ls 2> $DNUL || docker swarm init --advertise-addr $IP
docker stack rm dnsx 2> $DNUL
wget \
https://raw.githubusercontent.com/Hira20/VPSauto/master/sniproxy.conf.template \
-qO $CONFDIR/sniproxy.conf
wget $GITMINE/sni-dns.conf -qO $CONFDIR/sni-dns.conf
wget $GITMINE/dnsmasq.conf -qO $CONFDIR/dnsmasq.conf
wget $GITMINE/squid.conf -qO $CONFDIR/squid.conf
wget $GITMINE/docker.yaml -qO- | docker stack up -c - dnsx
docker service update $(docker service ls | grep squid | cut -d ' ' -f 1) --args $sqx

#finalizing
sed -i 's/\/var\/www\/html;/\/home\/vps\/public_html\/;/g' /etc/nginx/sites-enabled/default
vnstat -u -i eth0
apt-get -y autoremove
chown -R www-data:www-data /home/vps/public_html
service nginx start
service php7.0-fpm start
service vnstat restart
service openvpn restart
service dropbear restart
service fail2ban restart
service squid restart
clear
history -c
echo "Smart Squid Installed successfully"
echo "Rebooting your server..."
sleep 5
sudo reboot
