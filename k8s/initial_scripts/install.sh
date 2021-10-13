#!/bin/bash
echo "-- reload the user credentials by a new shell --"
# https://man7.org/linux/man-pages/man1/sg.1.html
sleep 2
echo "-- install k3d ---"
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash &&
sleep 4
# added groups are not available directly -> https://superuser.com/questions/272061/reload-a-linux-users-group-assignments-without-logging-out
# exec newgrp docker && # exec used to replace this shell without a new one, or here -> https://docs.docker.com/engine/install/linux-postinstall/
echo "-- create cluster ---"
# sg is needed to change the group to make docker available
#sg docker -c 'k3d cluster create dev --api-port 0.0.0.0:6550 -p 8080:80@loadbalancer -p 8443:443@loadbalancer' &&
#sg docker -c 'k3d --verbose cluster create dev --api-port 0.0.0.0:6550 -p 80:80@loadbalancer -p 443:443@loadbalancer' &&

#added a config file finally for server-args, copied to the host via terraform file-provisioner
sg docker -c 'k3d --verbose cluster create --config /tmp/k3d-config.yaml' &&

# added logging -> https://k3d.io/usage/commands/

#write the config file to the filesystem
sg docker -c 'k3d kubeconfig write dev'