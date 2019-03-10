#!/bin/bash

#hostnamectl set-hostname 'k8s-master'
setenforce 0
sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
swapoff -a

# Open firewall ports
firewall-cmd --permanent --add-port=6443/tcp
firewall-cmd --permanent --add-port=2379-2380/tcp
firewall-cmd --permanent --add-port=10250/tcp
firewall-cmd --permanent --add-port=10251/tcp
firewall-cmd --permanent --add-port=10252/tcp
firewall-cmd --permanent --add-port=10255/tcp
firewall-cmd --reload
modprobe br_netfilter
echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables

# Add repo

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# Install and enable service
yum update -y; yum install kubeadm docker -y
# change container driver to cgroup instead of systemd
sed -i "s|systemd|cgroupfs|g" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf  /usr/lib/systemd/system/docker.service
systemctl daemon-reload
systemctl enable kubelet
for act in enable restart status
do
  systemctl $act docker
done

# ensure that old configs are purged

rm -rf /var/lib/etcd/ /$USER/.kube/config
rm -rf /etc/kubernetes/manifests/kube-apiserver.yaml  /etc/kubernetes/manifests/kube-controller-manager.yaml  /etc/kubernetes/manifests/kube-scheduler.yaml  /etc/kubernetes/manifests/etcd.yaml

# init config of master
kubeadm init
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config


# Add pod
export kubever=$(kubectl version | base64 | tr -d '\n')
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"
kubectl get nodes
kubectl  get pods  --all-namespaces

