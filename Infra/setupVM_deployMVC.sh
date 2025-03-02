#!/bin/bash

# Variables
RESOURCE_GROUP="MyappRG"
LOCATION="northeurope"
VM_NAME="MyUbuntuVM"
VM_SIZE="Standard_B1s"
ADMIN_USER="azureuser"
IMAGE="Ubuntu2404"
PORT=1337
BASEDIR=Myapp
CURRDIR=$(pwd)

# Step 1: Create Resource Group
az group create \
    --name $RESOURCE_GROUP \
    --location $LOCATION
echo "Resource Group $RESOURCE_GROUP Created"

# Step 2: Create Virtual Machine
az vm create \
    --resource-group $RESOURCE_GROUP \
    --name $VM_NAME \
    --image $IMAGE \
    --admin-username $ADMIN_USER \
    --generate-ssh-keys \
    --size $VM_SIZE 
echo "VM $VM_NAME Created"

# Step 3: Open Port for Web Access
az vm open-port \
    --resource-group $RESOURCE_GROUP \
    --name $VM_NAME \
    --port $PORT
echo "Port $PORT Opened for ASP.NET App public access"

# Step 4: Get Public IP Address
VM_IP=$(az vm show -d -g $RESOURCE_GROUP -n $VM_NAME --query publicIps -o tsv)
echo "Your VM Public IP: $VM_IP"

# Step 5: SSH into VM and Run App
ssh -o StrictHostKeyChecking=no $ADMIN_USER@$VM_IP << 'ENDSSH'
    sudo add-apt-repository ppa:dotnet/backports -y
    sudo apt-get update
    sudo apt-get install -y dotnet-sdk-9.0
    echo "Dotnet Installed"
    sudo mkdir -p /opt/myapp
    sudo chown azureuser:azureuser /opt/myapp
    echo "App Directory Created"
ENDSSH

# Step 6: Copy ASP.NET MVC App to VM
cd ../$BASEDIR
dotnet publish -c Release
cd $CURRDIRcd 
scp -r ./ $ADMIN_USER@$VM_IP:/opt/myapp
echo "App Copied to VM"

#Step 6: Create .env file
ssh $ADMIN_USER@$VM_IP << 'ENDSSH'
    sudo tee /opt/myapp/myapp.env > /dev/null <<EOF
    ASPNETCORE_ENVIRONMENT=Production
    DOTNET_PRINT_TELEMETRY_MESSAGE=false
    ASPNETCORE_URLS=http://*:1337
    EOF
    echo ".env file created"
    sudo chown www-data:www-data /opt/myapp/myapp.env
    sudo chmod 600 /opt/myapp/myapp.env
    echo ".env file permissions set"
ENDSSH

# Step 7: systemd Service File
ssh $ADMIN_USER@$VM_IP << 'ENDSSH'
    sudo tee /etc/systemd/system/myapp.service > /dev/null <<EOF
    [Unit]
    Description=ASP.NET Web App running on Ubuntu
    After=network.target

    [Service]
    WorkingDirectory=/opt/myapp
    ExecStart=/usr/bin/dotnet /opt/myapp/Myapp.dll
    Restart=always
    RestartSec=10
    KillSignal=SIGINT
    SyslogIdentifier=myapp
    User=www-data
    EnvironmentFile=/opt/myapp/myapp.env

    [Install]
    WantedBy=multi-user.target
    EOF
ENDSSH
    echo "Systemd Unit File Created"

#activate the service
ssh $ADMIN_USER@$VM_IP << 'ENDSSH'
    sudo systemctl daemon-reload
    sudo systemctl enable myapp.service
    sudo systemctl start myapp.service
    echo "Systemd Service Started"
ENDSSH

echo "App Running on http://$VM_IP:$PORT"
echo "App Deplpoyed on VM done & Ready for Testing"