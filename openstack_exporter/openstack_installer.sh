#!/bin/bash


if [ ! -x "$(command -v pip)" ]; then
	echo "There is no pip."
	curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
	python get-pip.py
fi

pip install python-neutronclient python-novaclient python-keystoneclient python-cinderclient
pip install prometheus_client

if [ ! -x "$(command -v git)" ]; then
	echo "There is no git packages."
	yum install -y git
fi

git clone https://github.com/CanonicalLtd/prometheus-openstack-exporter.git

cd prometheus-openstack-exporter

sudo cp prometheus-openstack-exporter.yaml /etc/prometheus/
sudo cp prometheus-openstack-exporter /usr/local/bin/

mkdir -p /var/cache/prometheus-openstack-exporter/
touch /var/cache/prometheus-openstack-exporter/mycloud

if [ ! -f /etc/systmed/system/prometheus-openstack-exporter.service ]; then
	cat > /etc/systmed/system/prometheus-openstack-exporter.service<<EOF
[Unit]
Description=openstack_exporter
After=network.target

[Service]
Type=simple
ExecStart=source ~/root/admin.novarc && /usr/local/bin/prometheus-openstack-exporter \
/etc/prometheus-openstack-exporter/prometheus-openstack-exporter.yaml

[Install]
WantedBy=multi-user.target
EOF

