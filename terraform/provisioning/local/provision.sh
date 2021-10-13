echo "delete the key of this user:${HOST_USER} on that host IP:${K8S_IP} in local known_hosts"
# some command might fail "|| true" from https://stackoverflow.com/a/11231972
# delete key/fingerprint of the server in the local `known_hosts` mapped to the terraform docker container `/workspace/credentials/keys` -> https://askubuntu.com/a/20869 
ssh-keygen -R ${K8S_IP} -f ../credentials/keys/known_hosts || true
# grab the generated kubectl credentials from the cluster and store it locally based on the keys from the local maschine mapped into terraform-cluster
scp -o StrictHostKeyChecking=no -i ./../credentials/keys/id_rsa \
${HOST_USER}@${K8S_IP}:/home/terraformUser/.k3d/kubeconfig-dev.yaml ./../tmp/kubeconfig-dev.yaml && 
echo "access the cluster from localhost with -> 'KUBECONFIG={$PWD}/../tmp/kubeconfig-dev.yaml kubectl get node --insecure-skip-tls-verify'"
#KUBECONFIG={$PWD}/../tmp/kubeconfig-dev.yaml kubectl get nodes