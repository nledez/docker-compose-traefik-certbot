#!/bin/bash
while [ "`sudo lsof /var/lib/dpkg/lock /var/cache/apt/archives/lock /var/lib/dpkg/lock-frontend /var/lib/apt/lists/lock 2>&1 | wc -l`" != "0" ]; do
	sleep 5
done

touch -d '30 minutes ago' /tmp/30_minutes_ago
if [ ~/.script.apt-get -ot /tmp/30_minutes_ago ]; then
	sudo apt-get update && touch ~/.script.apt-get
fi

dpkg -l docker docker-compose | grep '^ii' | awk '{print $2}' > ~/.script.packages.txt
if [ "`grep -cE '^(docker|docker-compose)$' ~/.script.packages.txt`" -ne "2" ]; then
	sudo apt-get install -qy docker docker-compose
fi

grep -E '^docker:.*ubuntu' /etc/group || \
	sudo adduser ubuntu docker

mkdir -p letsencrypt/{etc,var}
mkdir -p letsencrypt/certificates/traefik
mkdir -p letsencrypt/etc/renewal-hooks/post
cp update_certificates.sh letsencrypt/etc/renewal-hooks/post/
sudo chown 0:0 letsencrypt/etc/renewal-hooks/post/update_certificates.sh
sudo chmod +x letsencrypt/etc/renewal-hooks/post/update_certificates.sh

. /home/ubuntu/certbot_config.sh
sed -i "s/%DOMAIN%/${DOMAIN}/g" docker-compose.yml
