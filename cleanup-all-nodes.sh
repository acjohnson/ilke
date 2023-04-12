#!/bin/bash -x


# You can safely cleanup the entire cluster and re-bootstrap with the following node cleanup steps
# This will obviously take down the entire cluster temporarily...

cd /root/ilke

for i in $(kubectl -n kube-system get secrets | grep calico | awk '{print $1}'); do kubectl -n kube-system delete secret/$i; done
for i in $(kubectl -n kube-system get configmaps | grep calico | awk '{print $1}'); do kubectl -n kube-system delete configmap/$i; done
for i in $(kubectl -n kube-system get deployments | grep calico | awk '{print $1}'); do kubectl -n kube-system delete deployment/$i; done
for i in $(kubectl -n kube-system get daemonsets | grep calico | awk '{print $1}'); do kubectl -n kube-system delete daemonset/$i; done
ansible all -i hosts -m shell -a "systemctl stop kube-apiserver.service; systemctl stop kube-controller-manager.service; systemctl stop kubelet.service; systemctl stop kube-proxy.service; systemctl stop kube-scheduler.service; systemctl stop etcd.service"
ansible all -i hosts -m shell -a 'docker kill $(docker ps -qa)'
ansible all -i hosts -m shell -a 'docker rm $(docker ps -qa)'
ansible all -i hosts -m shell -a 'rm -rf /etc/kubernetes; rm -rf /var/ilke'

ansible-playbook ilke.yaml -e "rotate_private_keys=True"
