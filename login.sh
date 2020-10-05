#!/bin/sh

read -p "Github Username: " username
stty -echo
read -p "Github Personal Token: " token
stty echo
echo ""

echo $token | docker login https://docker.pkg.github.com -u "$username" --password-stdin
