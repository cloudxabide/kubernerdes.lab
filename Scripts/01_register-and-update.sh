#!/bin/bash

register_node() {
SUSEConnect -e <reg_email> -r <reg_code>
SUSEConnect --product sle-module-basesystem/15.7/x86_64
SUSEConnect --product sle-module-server-applications/15.7/x86_64
SUSEConnect --product PackageHub/15.7/x86_64
zypper refresh
}

# Install git-core
zypper -n in git-core

# Install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
