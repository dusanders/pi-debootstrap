#!/bin/sh

echo "Installing additional packages..."
apt-get -y --allow-unauthenticated update
apt-get -y --allow-unauthenticated dist-upgrade
apt-get -y --allow-unauthenticated install curl gettext
apt-get -y --allow-unauthenticated install libunwind8
apt-get -y --allow-unauthenticated install hostapd
apt-get -y --allow-unauthenticated install dnsmasq
apt-get -y --allow-unauthenticated install wpasupplicant
apt-get -y --allow-unauthenticated install g++
apt-get -y --allow-unauthenticated install openssh-server
echo "Setting up .NET core..."
curl -sSL -o dotnet.tar.gz https://dotnetcli.blob.core.windows.net/dotnet/Runtime/release/2.0.0/dotnet-runtime-latest-linux-arm.tar.gz
mkdir -p /opt/dotnet && tar zxf dotnet.tar.gz -C /opt/dotnet
ln -s /opt/dotnet/dotnet /usr/bin/

passwd << EOF
owner
owner
EOF
echo "Done"
