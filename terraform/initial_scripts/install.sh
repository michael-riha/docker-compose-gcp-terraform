#!/bin/bash
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash &&
k3d cluster create dev --api-port 0.0.0.0:6550