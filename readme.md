# demoConsul

## Install consul

- wget https://releases.hashicorp.com/consul/1.4.0/consul_1.4.0 linux_amd64.zip

## Start server

- consul agent -node server1  -data-dir=/var/lib/consul/ -config-dir /etc/consul.d -ui -client 0.0.0.0 -server -bootstrap -bind '{{ GetInterfaceIP "eth0" }}'
