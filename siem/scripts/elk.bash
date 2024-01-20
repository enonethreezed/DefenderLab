echo JAVA_HOME=\"/usr/lib/jvm/java-11-openjdk-amd64\" >> /etc/environment
echo ES_HOME=\"/opt/elasticsearch-8.11.4/\" >> /etc/environment
source /etc/environment

cd
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list

apt-get -yq update
apt install elasticsearch -yq -o Dpkg::Progress-Fancy="0" -o APT::Color="0" -o Dpkg::Use-Pty="0" 2> /dev/null > apt.log
ELASTIC_PASSWORD=$(grep "The generated password for the elastic built-in superuser is:" apt.log | awk -F": " '{print $2}')
export ELASTIC_PASSWORD

mkdir -r /opt/siem/data
mkdir -r /opt/siem/log

systemctl daemon-reload
systemctl start elasticsearch
systemctl enable elasticsearch

sed -i 's/#network.host: 192.168.0.1/network.host: 0.0.0.0/' /etc/elasticsearch/elasticsearch.yml
sed -i 's/path.data: /var/lib/elasticsearch/
sed -i 's/path.logs: /var/log/elasticsearch/

# sed -i 's/#discovery.seed_hosts: \["host1", "host2"\]/discovery.seed_hosts:[]/' /etc/elasticsearch/elasticsearch.yml
# sed -i 's/xpack.security.enabled: true/xpack.security.enabled: false/' /etc/elasticsearch/elasticsearch.yml
sudo systemctl restart elasticsearch



wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.11.4-linux-x86_64.tar.gz
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.11.4-linux-x86_64.tar.gz.sha512
shasum -a 512 -c elasticsearch-8.11.4-linux-x86_64.tar.gz.sha512 
tar -xzf elasticsearch-8.11.4-linux-x86_64.tar.gz
cd elasticsearch-8.11.4/ 
adduser --home /opt/elasticsearch-8.11.4 --no-create-home  --disabled-login --disabled-password --gecos "" elastic




wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg


sudo apt-get install apt-transport-https








