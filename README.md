

# particle41
**====================== Task 1 Minimalist Application Developmen.==============================** 
Tiny App Development: 'SimpleTimeService'

###### Running the App from an Existing Image
# 1. Pull the Docker Image
docker pull docker007786/particle41:myapp

# 2. Run the Docker Container
docker run -itd --name=voo -p 5000:5000 docker007786/particle41:myapp

# 3. Access the App
curl http://localhost:5000


##### Running the App through repo
# 1. Clone the Repository
git clone git@github.com:wasimalii/particle41.git

# 2. Build the Docker Image
cd particle41/app<br>
docker build -t myapp -f Dockerfile .

# 3. Run the Docker Container
docker run -itd --name=app -p 5000:5000 myapp

# 5. View Logs
docker logs myapp

# 6. Access the App
curl http://localhost:5000/



**=========== Task 2 Terraform and Cloud: create the infrastructure to host your container.===================** 

# 1. Clone the repository and navigate to the Terraform directory:
git clone git@github.com:wasimalii/particle41.git<br>
cd particle41/terraform

# 2. Terraform commands to plan and apply the configuration:
terraform plan<br>
terraform apply

# 3.Expected Output: 

Accessing the Application Load Balancer (ALB) DNS will show an Nginx default page.

The following resources will be created:
A VPC with 2 public subnets and 2 private subnets.
An ECS cluster deployed in the private subnets of the VPC.
An ECS Task running nginx container.
A Load Balancer (ALB) in the public subnets to route traffic to the private subnets where tasks are running.



