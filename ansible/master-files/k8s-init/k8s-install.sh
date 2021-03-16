#!/bin/bash
# export addresses and other vars
set -a
source k8s-vars
OUTPUT_DIR=$(realpath -m ./clusters/${K8S_CLUSTER_NAME})
LOCAL_CERTS_DIR=${OUTPUT_DIR}/pki
KUBECONFIG=${OUTPUT_DIR}/kubeconfig
mkdir -p ${OUTPUT_DIR}

KUBEADM_TOKEN=$(kubeadm token generate)

set +a

envsubst < kubeadm-init-config.tmpl.yaml > ${OUTPUT_DIR}/kubeadm-init-config.yaml

kubeadm init phase certs all --config ${OUTPUT_DIR}/kubeadm-init-config.yaml 
export CA_CERT_HASH=$(openssl x509 -pubkey -in ${LOCAL_CERTS_DIR}/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* /sha256:/')
./generate-admin-client-certs.sh



set -a
CLIENT_CERT_B64=$(base64 -w0  < $LOCAL_CERTS_DIR/kubeadmin.crt)
CLIENT_KEY_B64=$(base64 -w0  < $LOCAL_CERTS_DIR/kubeadmin.key)
CA_DATA_B64=$(base64 -w0  < $LOCAL_CERTS_DIR/ca.crt)
set +a

envsubst < kubeconfig-template.yaml > ${OUTPUT_DIR}/kubeconfig
envsubst < kubeadm-join-config.tmpl.yaml > ${OUTPUT_DIR}/kubeadm-join-config.yaml

sudo mkdir -p /etc/kubernetes/pki
sudo cp -r $LOCAL_CERTS_DIR/* /etc/kubernetes/pki

sed -i '/certificatesDir:/d' $OUTPUT_DIR/kubeadm-init-config.yaml
sudo kubeadm init --skip-phases certs --config ${OUTPUT_DIR}/kubeadm-init-config.yaml

rm -rf $HOME/.kube

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

curl -O -L  https://github.com/projectcalico/calicoctl/releases/download/v3.17.2/calicoctl
sudo chmod +x calicoctl
sudo cp ./calicoctl /usr/local/sbin

for ip in ${K8S_NODE1_INTERNAL_IP} ${K8S_NODE2_INTERNAL_IP}; do
    scp ${OUTPUT_DIR}/kubeadm-join-config.yaml ${ip}:/home/ubuntu
    ssh ${ip} "sudo kubeadm join --config /home/ubuntu/kubeadm-join-config.yaml"
done

kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml


