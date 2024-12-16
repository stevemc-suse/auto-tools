#!/bin/bash

# --- Install RKE2 HA Cluster ---

# --- Variables ---
# Set the number of control plane nodes
CONTROL_PLANE_NODES=3
# Set the IP addresses of the control plane nodes
CONTROL_PLANE_IPS=("10.144.117.23" "10.144.117.246" "10.144.116.63")
# Set the token for cluster authentication
TOKEN=$(openssl rand -hex 32)

# --- Functions ---

# Install RKE2 on a control plane node
install_control_plane_node() {
  IP=$1
  echo "Installing RKE2 control plane node on ${IP}"
  ssh -o StrictHostKeyChecking=no ${IP} "curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE=server \
    INSTALL_RKE2_CHANNEL=stable \
    INSTALL_RKE2_TOKEN=${TOKEN} \
    INSTALL_RKE2_CONTROLPLANE_IP=${IP} sh -"
}

# --- Main ---

# Install RKE2 on each control plane node
for i in $(seq 1 ${CONTROL_PLANE_NODES}); do
  IP=${CONTROL_PLANE_IPS[$i-1]}
  install_control_plane_node ${IP} &
done

# Wait for all background processes to finish
wait

# Get the kubeconfig from the first control plane node
scp -o StrictHostKeyChecking=no ${CONTROL_PLANE_IPS[0]}:/etc/rancher/rke2/rke2.yaml kube_config_rke2

# --- End of script ---
