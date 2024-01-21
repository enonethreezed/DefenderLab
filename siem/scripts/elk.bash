# https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elastic-stack-on-ubuntu-22-04

# TODO: change paths to dedicated disk
# path.data: /var/lib/elasticsearch -> /opt/elasticsearch/data
# path.logs: /var/log/elasticsearch -> /opt/elasticsearch/log

curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor -o /usr/share/keyrings/elastic.gpg
echo "deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-8.x.list

export DEBIAN_FRONTEND=noninteractive

apt -yq update
apt -yq upgrade
apt install elasticsearch -yq -o Dpkg::Progress-Fancy="0" -o APT::Color="0" -o Dpkg::Use-Pty="0" 2> /dev/null > apt.log
PASSWORD=$(grep "The generated password for the elastic built-in superuser is"| awk -F": " '{print $2}' apt.log)
TOKEN="elastic:"$PASSWORD
TOKENB64=$(echo $TOKEN|base64)
echo $TOKEN > /root/elastic.token
echo $TOKENB64 > /root/elastic.token.b64

sed -i 's/#network.host: 192.168.0.1/network.host: 0.0.0.0/' /etc/elasticsearch/elasticsearch.yml
sed -i 's/xpack.security.enabled: true/xpack.security.enabled: false'  /etc/elasticsearch/elasticsearch.yml
sed -i 's/xpack.security.enrollment.enabled: true/xpack.security.enabled: false' /etc/elasticsearch/elasticsearch.yml
sed -i 's/path.data: \/var\/lib\/elasticsearch\/path.data: \/opt\/elasticsearch\/data' /etc/elasticsearch/elasticsearch.yml
sed -i 's/path.logs: \/var\/log\/elasticsearch/path.data: \/opt\/elasticsearch\/log' /etc/elasticsearch/elasticsearch.yml

systemctl enable elasticsearch
systemctl stop elasticsearch
sleep 60
mv /var/lib/elasticsearch /opt
ln -s /opt/elasticsearch /var/lib
mv /var/log/elasticsearch/* /opt/elasticsearch/log/
