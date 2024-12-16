#!/bin/bash

# --- Install RKE2 HA Cluster without SSH ---

# --- Variables ---
# Set the number of control plane nodes
CONTROL_PLANE_NODES=3
# Set the IP addresses of the control plane nodes
CONTROL_PLANE_IPS=("192.168.1.10" "192.168.1.11" "192.168.1.12")
# Set the token for cluster authentication
TOKEN=$(openssl rand -hex 32)

# --- Functions ---

# Generate the server command to install RKE2 on a control plane node
generate_server_command() {
  IP=$1
  echo "curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE=server \\
    INSTALL_RKE2_CHANNEL=stable \\
    INSTALL_RKE2_TOKEN=${TOKEN} \\
    INSTALL_RKE2_CONTROLPLANE_IP=${IP} sh -"
}

# --- Main ---

# Generate the command for the first control plane node
SERVER_COMMAND=$(generate_server_command ${CONTROL_PLANE_IPS[0]})

# Install RKE2 on the first control plane node
echo "Installing RKE2 control plane node on ${CONTROL_PLANE_IPS[0]}"
${SERVER_COMMAND}

# Get the node token from the first control plane node
NODE_TOKEN=$(sudo cat /var/lib/rancher/rke2/server/node-token)

# Generate the commands for the remaining control plane nodes
for i in $(seq 2 ${CONTROL_PLANE_NODES}); do
  IP=${CONTROL_PLANE_IPS[$i-1]}
  echo "Installing RKE2 control plane node on ${IP}"
  echo "curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE=server \\
    INSTALL_RKE2_CHANNEL=stable \\
    INSTALL_RKE2_TOKEN=${NODE_TOKEN} \\
    INSTALL_RKE2_CONTROLPLANE_IP=${IP} \\
    INSTALL_RKE2_SERVER=\"https://${CONTROL_PLANE_IPS[0]}:9345\" sh -"
done

# --- End of script ---
