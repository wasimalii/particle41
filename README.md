

# particle41
**====================== Task 1 Minimalist Application Developmen.==============================** 
Tiny App Development: 'SimpleTimeService'

###### Running the App from an Existing Image
# 1. Pull the Docker Image
docker pull docker007786/particle41:myapp

# 2. Run the Docker Container
docker run -itd --name=voo -p 5000:5000 docker007786/particle41:myapp

# 3. Access the App
curl http://localhost:5000<br>
Note: check ports 

![Example Image](images/docker.png)





**=========== Task 2 Terraform and Cloud: create the infrastructure to host your container.===================** 

### Prerequisites<br>
Before running the Terraform scripts, you need to set up your AWS Access and Secret Access Keys. Follow the steps below:<br>

Go to the AWS Management Console.<br>
Click on your profile name (located at the top-right corner). ---->  Select "My Security Credentials." ----> Navigate to the Access Keys section. ---> Click on "Create New Access Key" to generate a set of keys.<br>

Use these keys to authenticate Terraform with AWS by setting them in your environment variables or a credentials file<br>

# 1. Clone the repository and navigate to the Terraform directory:
git clone git@github.com:wasimalii/particle41.git<br>
cd particle41/terraform

# 2. Terraform commands to plan and apply the configuration:
terraform plan<br>
terraform apply

# 3.Expected Output: 

Accessing the Application Load Balancer (ALB) DNS will show an Nginx default page.

The following resources will be created:<br>
A VPC with 2 public subnets and 2 private subnets.<br>
An ECS cluster deployed in the private subnets of the VPC.<br>
An ECS Task running nginx container.<br>
A Load Balancer (ALB) in the public subnets to route traffic to the private subnets where tasks are running.

![Example Image](images/terraform1.png)
![Example Image](images/terraform2.png)




