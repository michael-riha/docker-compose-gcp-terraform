#!/bin/bash
echo "-- install docker ---"
sudo curl -sSL https://get.docker.com/ | sh &&
sudo usermod -aG docker `echo $USER` &&
echo "-- docker installed and group added --"