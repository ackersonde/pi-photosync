#!/bin/bash
TRAEFIK_HOME=/home/ubuntu/traefik

# Setup Syncthing config
mkdir -p /home/ubuntu/syncthing/config /home/ubuntu/syncthing/Camera
chown -Rf ubuntu:ubuntu /home/ubuntu/syncthing
echo ".trashed-*" > /home/ubuntu/syncthing/Camera/.stignore
chmod 600 /home/ubuntu/syncthing/Camera/.stignore
echo -n "$SYNCTHING_CONFIG" | base64 -d | tee -a /home/ubuntu/syncthing/config/config.xml
chmod 600 /home/ubuntu/syncthing/config/config.xml
cat <<EOF > /home/ubuntu/syncthing/config/key.pem
$SYNCTHING_KEY
EOF
chmod 600 /home/ubuntu/syncthing/config/key.pem
cat <<EOF > /home/ubuntu/syncthing/config/cert.pem
$SYNCTHING_CERT
EOF
chmod 644 /home/ubuntu/syncthing/config/cert.pem
#chown -R 1000:1000 /home/ubuntu/syncthing

# prepare iptables persistence and unattended-upgrades install settings
debconf-set-selections <<EOF
iptables-persistent iptables-persistent/autosave_v4 boolean true
iptables-persistent iptables-persistent/autosave_v6 boolean true
unattended-upgrades unattended-upgrades/enable_auto_updates boolean true
EOF

iptables -A INPUT -s 192.168.178.0/24 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
#ip6tables -A INPUT -p tcp -s 2a02:810d:80:3650::/62  --dport 22 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
# allow docker containers to talk to the internet
ip6tables -t nat -A POSTROUTING -s fd00::/80 ! -o docker0 -j MASQUERADE

dpkg-reconfigure -f noninteractive unattended-upgrades

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io iptables-persistent

systemctl start docker
systemctl enable docker

# setup ipv6 capability in docker
cat > /etc/docker/daemon.json <<EOF
{
  "ipv6": true,
  "fixed-cidr-v6": "fd00::/80"
}
EOF
systemctl restart docker

cat > /etc/apt/apt.conf.d/50unattended-upgrades << EOF
Unattended-Upgrade::Allowed-Origins {
    "\${distro_id} stable";
    "\${distro_id} \${distro_codename}-security";
    "\${distro_id} \${distro_codename}-updates";
};

// Do automatic removal of new unused dependencies after the upgrade
// (equivalent to apt-get autoremove)
Unattended-Upgrade::Remove-Unused-Dependencies "true";

// Automatically reboot *WITHOUT CONFIRMATION* if
// file /var/run/reboot-required is found after
Unattended-Upgrade::Automatic-Reboot "true";
EOF
