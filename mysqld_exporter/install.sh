#!/bin/sh

VERSION=1.11
OS=linux
ARCH=amd64

function chk_prep(){
        if [ -z "$(rpm -qa wget)" ] ; then
                echo "wget is not installed"
                yum install wget -y
        fi

        if [ -z "$(rpm -qa git)" ] ; then
                echo "git is not installed"
                yum install git  -y
        fi

}
function confirm(){
        while true; do
                read -p "$1 : [y/n]" answer
                case $answer in
                        [Yy]*) echo 0; break;;
                        [Nn]*) echo 1; break;;
                        *) echo "Please answer yes or no. ";;
                esac
        done
}

function make_service(){
        cp /root/go/bin/mysqld_exporter /usr/local/bin/

        if [ ! -z /etc/systemd/system/mysqld_exporter.service ]; then
                cat > /etc/systemd/system/mysqld_exporter.service <<EOF
[Unit]
Description=myslqd_exporter
After=network.target

[Service]
Type=simple
Environment=DATA_SOURCE_NAME='root:1234@(localhost:3306)/'
ExecStart=/usr/local/bin/mysqld_exporter

[Install]
WantedBy=multi-user.target
EOF
}

chk_prep

if ! [ -x "$(command -v go)" ]; then
        confirm "Need to install go package. Do you want to install go? "
        check=$?
        if [ $check -eq 1 ]; then
                echo "Program will be exit "
                exit 1;
        elif [ $check -eq 0 ]; then
                echo "Program will be installed !"
                if [ ! -f go$VERSION.$OS-$ARCH.tar.gz ];then
                        wget https://golang.org/dl/go$VERSION.$OS-$ARCH.tar.gz
                fi
                tar -C /usr/local -xzf go$VERSION.$OS-$ARCH.tar.gz
                if [ -d /usr/local/go/bin ];then
                        export PATH=$PATH:/usr/local/go/bin
                fi
                go get -v github.com/prometheus/mysqld_exporter
                go install github.com/prometheus/mysqld_exporter
                
                make_service
        fi
fi


systemctl daemon-reload
systemctl enable myslqd_exporter.service





