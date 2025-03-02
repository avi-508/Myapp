# Avinash Chowdary Bodduluri - Simple ASP.NET MVC Web Application
---
## Part 1 : Web Application 
A have used default ASP.NET MVC template in Visual Studio Code & Added webform, where user can send in a message or request to App admin.

### Features
- Responsive design using Bootstrap
- Contact Us page with form validation
- Thank you page after successful form submission
- Clean architecture following MVC pattern

### Prerequisites
- [.NET 9.0 SDK](https://dotnet.microsoft.com/en-us/download)
- [Visual Studio Code](https://code.visualstudio.com/)

### Link to the repository
- [Myapp Git Repo](https://github.com/avi-508/Myapp)

### Run the application
- Clone the Git Repo in VS code on any Windows computer
- Open Terminal & run the following command.
```bash
dotnet run
```
### Port 1337 is set as default
- The application will start at `https://localhost:1337` and `http://localhost:1337`.

### Project Structure
- `Controllers/`: Contains all controller classes
  - `HomeController.cs`: Handles home page requests
  - `ContactController.cs`: Handles contact form submissions
- `Models/`: Contains data models
  - `ContactViewModel.cs`: Model for contact form data
  - `ErrorViewModel.cs`: Model for Errors - from MVC Template
- `Views/`: Contains all view templates
  - `Home/`: Views for the home controller
  - `Contact/`: Views for the contact controller
  - `Shared/`: Shared layout views

### Contact Form Implementation & Form Processing
- The Contact Us page contains: Form with validation for required fields and email format
```code
  public class ContactViewModel
    {
        [Required(ErrorMessage = "Name is required")]
        [StringLength(20, ErrorMessage = "Name cannot exceed 20 characters")]
        public string? Name { get; set; }
        
        [Required(ErrorMessage = "Email is required")]
        [EmailAddress(ErrorMessage = "Invalid email address")]
        [RegularExpression("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", ErrorMessage = "Missing top level domain")]
        public string? Email { get; set; }
        
        [Required(ErrorMessage = "Subject is required")]
        [StringLength(20, ErrorMessage = "Name cannot exceed 20 characters")]
        public string? Subject { get; set; }
        
        [Required(ErrorMessage = "Message is required")]
        [StringLength(500, ErrorMessage = "Message cannot exceed 500 characters")]
        public string? Message { get; set; }
    }
```
- Redirect to a thank you page after successful submission
```code
        [HttpPost]
        public IActionResult Submit(ContactViewModel model)
        {
            if (ModelState.IsValid)
            {
                // Process the form submission here
                // E.g., send an email, save to database, etc.
                
                // Redirect to a thank you page or show success message
                return RedirectToAction("ThankYou");
            }
            
            return View("Index", model);
        }
```
- To further implement actual email sending or database storage, we can modify the `Submit` action in `ContactController.cs`.
### Screenshots 
![Screenshot 2025-03-02 215054](https://github.com/user-attachments/assets/56298c83-f3d6-4afa-9757-bdf500390264)
![Screenshot 2025-03-02 215110](https://github.com/user-attachments/assets/1804843e-438c-440e-9104-15a736e6a29a)
![Screenshot 2025-03-02 215126](https://github.com/user-attachments/assets/1d698c2b-1d21-4cf0-85b0-20bb21fb160e)
![Screenshot 2025-03-02 215151](https://github.com/user-attachments/assets/08e7cf6e-8399-4bf3-8191-6d12bdc8156b)


---
## Part 2: Provision Virtual Infrastructure
### Prerequisites
- Have an Azure account created.
- Azure CLI installed in computer.
```bash
#!/bin/bash

# Variables
RESOURCE_GROUP="MyappRG"
LOCATION="northeurope"
VM_NAME="MyUbuntuVM"
VM_SIZE="Standard_B1s"
ADMIN_USER="azureuser"
IMAGE="Ubuntu2404"
PORT=1337

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
```
---
## Part 3: Configure Vitual Infrastructure by Installing dotnet and preparing a folder structure for App deployment
```bash
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
```
---
## Part 4: Deploy Application
```bash
# Step 6: Copy ASP.NET MVC App to VM
cd ../
dotnet publish -c Release --output ./publish
cd publish
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
```
---
## Part 5: Verify Application On virtual Machine
### Screenshots
![Screenshot 2025-03-02 223327](https://github.com/user-attachments/assets/8800a73e-7ec0-4eb7-8021-8ff834fdb0f8)
![Screenshot 2025-03-02 223244](https://github.com/user-attachments/assets/ae7a6224-2b78-4669-871b-158a1a78b6c7)
![Screenshot 2025-03-02 223217](https://github.com/user-attachments/assets/35ef224f-741c-463a-897b-07d96cfdd759)
![Screenshot 2025-03-02 223158](https://github.com/user-attachments/assets/bed4b8e7-79a0-4401-b647-a897e9cef2f0)

## ONE CLICK SOLUTION FOR SETUP VM & DEPLOY WEBAPP
- After Cloning the webapp Git repo into computer, navigate to Infra and run an integrated terminal from there in VSCODE. Make sure logged in to Azure CLI using following command.
```code
az login 
```
- ONce login done successfully, run the script using following command
```code
./setupVM_deployMVC.sh
```
- [Script for Setup VM & Deploy Webapp](https://github.com/avi-508/Myapp/blob/master/Infra/setupVM_deployMVC.sh)

### Acknowledgments

- [ASP.NET Core Documentation](https://docs.microsoft.com/en-us/aspnet/core/)
- [Bootstrap Documentation](https://getbootstrap.com/docs/)

