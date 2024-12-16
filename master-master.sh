#!/bin/bash

TOKEN=$(openssl rand -hex 32)
curl -sfL https://get.rke2.io | INSTALL_RKE2_TYPE=server INSTALL_RKE2_CHANNEL=stable INSTALL_RKE2_TOKEN=${TOKEN}
