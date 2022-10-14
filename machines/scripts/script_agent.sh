####################  Installation consul  ######################
apt-get update -y
apt-get install unzip gnupg2 curl wget -y dnsutils python-flask net-tools
cd /tmp
wget https://releases.hashicorp.com/consul/1.8.4/consul_1.8.4_linux_amd64.zip
unzip consul_1.8.4_linux_amd64.zip
mv consul /usr/local/bin/
groupadd --system consul
useradd -s /sbin/nologin --system -g consul consul
mkdir -p /var/lib/consul
chown -R consul:consul /var/lib/consul
chmod -R 775 /var/lib/consul
mkdir /etc/consul.d
chown -R consul:consul /etc/consul.d

####################  Installation consul  ######################
echo '{
    "advertise_addr": "192.168.0.22",
    "bind_addr": "192.168.0.22",
    "client_addr": "0.0.0.0",
    "datacenter":"FevillDc",
    "data_dir":"/var/lib/consul",
    "domain": "consul",
    "enable_script_checks": true,
    "dns_config": {
        "enable_truncate": true,
        "only_passing": true
    },
    "enable_syslog": true,
    "encrypt": "VoX1H6Fg3dYBzbd1G8cLGzSiEJk6wC7YAjmYXk+5axA=",
    "leave_on_terminate": true,
    "log_level": "INFO",
    "rejoin_after_leave": true,
    "retry_join":[
        "192.168.0.20"
    ]
}' > /etc/consul.d/config.json

####################  Installation consul  ######################
echo '
[Unit]
Description=Consul Service Discovery Agent
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=consul
Group=consul
ExecStart=/usr/local/bin/consul agent \
    -node=192.168.0.22 \
    -bind=192.168.0.22 \
    -advertise=192.168.0.22 \
    -data-dir=/var/lib/consul \
    -config-dir /etc/consul.d 

ExecReload=/bin/kill -HUP $MAiNPID
KillSignal=SIGINT
TimeoutStopSec=5
Restart=On-failure
SyslogIdentifier=consul

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/consul.service

####################### monservice.json ###########################

echo '
{"service":
        {
    "name": "monservice",
    "tags": ["python"],
    "port": 80,
    "check": {
      "http": "http://localhost:80/",
      "interval": "3s"
    }
  }
}' >/etc/consul.d/monservice.json
