systemctl disable systemd-resolved
systemctl stop systemd-resolved
rm /etc/resolv.conf
echo 'nameserver 8.8.8.8' >> /etc/resolv.conf
echo 'nameserver 8.8.4.4' >> /etc/resolv.conf
echo 'nameserver 192.168.56.20' >> /etc/resolv.conf

echo "apt-fast apt-fast/maxdownloads string 10" | debconf-set-selections
echo "apt-fast apt-fast/dlflag boolean true" | debconf-set-selections

# https://computingforgeeks.com/install-guacamole-remote-desktop-on-ubuntu-jammy-jellyfish/?utm_content=cmp-true
DEBIAN_FRONTEND=noninteractive apt update
DEBIAN_FRONTEND=noninteractive apt install -y gcc nano vim curl wget g++ libcairo2-dev libjpeg-turbo8-dev libpng-dev libtool-bin libossp-uuid-dev
DEBIAN_FRONTEND=noninteractive apt install -y libavcodec-dev  libavformat-dev libavutil-dev libswscale-dev build-essential libpango1.0-dev libssh2-1-dev libvncserver-dev libtelnet-dev libpulse-dev libvorbis-dev libwebp-dev

DEBIAN_FRONTEND=noninteractive add-apt-repository -y ppa:remmina-ppa-team/remmina-next-daily
DEBIAN_FRONTEND=noninteractive apt update
DEBIAN_FRONTEND=noninteractive apt install -y freerdp2-dev freerdp2-x11 -y

DEBIAN_FRONTEND=noninteractive apt install -y default-jdk
DEBIAN_FRONTEND=noninteractive apt install -y tomcat9 tomcat9-admin tomcat9-common tomcat9-user
systemctl enable --now tomcat9

mkdir src
cd src
VER=1.5.3
wget https://archive.apache.org/dist/guacamole/$VER/source/guacamole-server-$VER.tar.gz
tar xzf guacamole-server-*.tar.gz
cd guacamole-server-*/
./configure --disable-guacenc --with-init-dir=/etc/init.d
make
make install
ldconfig

mkdir  -p /etc/guacamole/{extensions,lib}
cat > /etc/guacamole/guacd.conf << EOF
[daemon]
pid_file = /var/run/guacd.pid
#log_level = debug

[server]
#bind_host = localhost
bind_host = 127.0.0.1
bind_port = 4822

#[ssl]
#server_certificate = /etc/ssl/certs/guacd.crt
#server_key = /etc/ssl/private/guacd.key
EOF

# https://guacamole.apache.org/doc/gug/configuring-guacamole.html
cp /vagrant/guacamole/guacamole.properties /etc/guacamole/
cp /vagrant/guacamole/user-mapping.xml /etc/guacamole/

systemctl daemon-reload
systemctl restart guacd
systemctl enable guacd

cd /root/src
VER=1.5.3
wget https://archive.apache.org/dist/guacamole/$VER/binary/guacamole-$VER.war
mv guacamole-$VER.war /var/lib/tomcat9/webapps/guacamole.war
echo "GUACAMOLE_HOME=/etc/guacamole" | tee -a /etc/default/tomcat
echo "export GUACAMOLE_HOME=/etc/guacamole" | tee -a /etc/profile