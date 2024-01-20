echo JAVA_HOME=\"/usr/lib/jvm/java-11-openjdk-amd64\" >> /etc/environment
source /etc/environment

cd
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list

apt-get -yq update
apt-get install -yq elasticsearch

systemctl daemon-reload
systemctl start elasticsearch
systemctl enable elasticsearch

sed -i 's/#network.host: 192.168.0.1/network.host: 0.0.0.0/' /etc/elasticsearch/elasticsearch.yml
sed -i 's/#discovery.seed_hosts: \["host1", "host2"\]/discovery.seed_hosts:[]/' /etc/elasticsearch/elasticsearch.yml
sed -i 's/xpack.security.enabled: true/xpack.security.enabled: false/' /etc/elasticsearch/elasticsearch.yml
sudo systemctl restart elasticsearch
