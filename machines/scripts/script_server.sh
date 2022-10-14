####################  Installation consul  ######################
apt-get update -y
apt-get install unzip gnupg2 curl wget -y dnsutils haproxy
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
    "advertise_addr": "192.168.0.20",
    "bind_addr": "192.168.0.20",
    "bootstrap_expect": 1,
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
    ],
    "server": true,
    "start_join": [
        "192.168.0.20"
    ],
    "ui": true
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
    -node=192.168.0.20 \
    -bind=192.168.0.20 \
    -advertise=192.168.0.20 \
    -data-dir=/var/lib/consul \
    -config-dir /etc/consul.d 

ExecReload=/bin/kill -HUP $MAiNPID
KillSignal=SIGINT
TimeoutStopSec=5
Restart=On-failure
SyslogIdentifier=consul

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/consul.service

######################## CONSUL TEMPLATE #######################################################

apt-get update
apt-get install -y wget unzip net-tools
wget https://releases.hashicorp.com/consul-template/0.19.5/consul-template_0.19.5_linux_amd64.zip
unzip consul-template_0.19.5_linux_amd64.zip
mv consul-template /usr/local/bin
chown consul:consul /usr/local/bin/consul-template
chmod 755 /usr/local/bin/consul-template
mkdir /etc/consul-template
chown consul:consul /etc/consul-template
chmod 775 /etc/consul-template

###################### systemd consul-template ##################

echo '
[Unit]
Description=Consul Template adon to consul
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
Group=consul
ExecStart=/usr/local/bin/consul-template \
  -consul-addr 127.0.0.1:8500 \
  -template "/etc/consul-template/haproxy.tmpl:/etc/haproxy/haproxy.cfg:service haproxy reload"

ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT
TimeoutStopSec=5
Restart=on-failure
SyslogIdentifier=consul

[Install]
WantedBy=multi-user.target
' >/etc/systemd/system/consul-template.service


############################# TEMPLATE #########################################################

echo '
# template consul template pour haproxy

global
        daemon
        maxconn 256

    defaults
        mode http
        timeout connect 5000ms
        timeout client 50000ms
        timeout server 50000ms

frontend monservice
        bind :80
        mode http
        default_backend monservice

backend monservice
        mode http
        cookie LBN insert indirect nocache
        option httpclose
        option forwardfor
        balance roundrobin {{ range service monservice }}
        server {{ .Node }} {{.Address }}:{{ .Port }} {{ end }}
' >/etc/consul-template/haproxy.tmpl

