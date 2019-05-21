# Azure bastion host VM

Below are instructions for using the Azure CLI to provison an ubuntu virtual machine on Azure to use for the cluster, keptn, and application setup.

Recommended image is:
* Ubuntu 16.04 LTS

You can also make the VM from the console, and the continue with the steps to connect using ssh.

# Create instance

Run these commands to configure the Azure CLI [Azure docs](https://docs.microsoft.com/en-us/cli/azure/vm?view=azure-cli-latest#az-vm-create)
```
# login to your account.  This will ask you to open a browser with a code and then login.
az login

# verify you are on the right subscription.  Look for "isDefault": true
az account list --output table
```

Run these commands to provision the VM and a resource group
```
# optionally adjust these variables
export VM_GROUP_NAME=dt-kube-demo-bastion-group
export VM_NAME=dt-kube-demo-bastion
export VM_GROUP_LOCATION=eastus

# provision the host
az group create --name $VM_GROUP_NAME --location $VM_GROUP_LOCATION

# create the VM
az vm create \
  --name $VM_NAME \
  --resource-group $VM_GROUP_NAME \
  --size Standard_B1s \
  --image Canonical:UbuntuServer:16.04-LTS:latest \
  --generate-ssh-keys \
  --output json \
  --verbose
```

# SSH to VM using gcloud

Goto the Azure console and choose the "connect" menu on the VM row to copy the connection string. Run this command to SSH to the new VM.
```
ssh <your id>@<host ip>
```

# Clone the Orders setup repo

Within the VM, run these commands to clone the setup repo.
```
git clone https://github.com/dt-kube-demo/setup-infra.git
cd setup-infra
```
Finally, proceed to the [Provision Cluster, Install Keptn, and onboard the Orders application](README.md#bastion-host-setup) step.

# Delete the Bastion resource group and VM from the Azure console

On the resource group page, delete the resource group named 'kube-demo-group'. 
This will delete the bastion host resource group and the VM running in it.

# Delete the Bastion resource group and VM with the azure cli

from outside the VM, run this command to delete the resource group named 'kube-demo-group'. 
This will delete the bastion host resource group and the VM running in it.
```
export VM_GROUP_NAME=dt-kube-demo-bastion-group
az group delete --name $VM_GROUP_NAME --yes
```

# az command reference

```
# list of locations
az account list-locations -o table

# list vm VMs
az vm show --name dt-kube-demo-bastion

# list vm sizes
az vm list-sizes --location eastus -o table

# image types
az vm image list -o table
az vm image show --urn Canonical:UbuntuServer:16.04-LTS:latest

```