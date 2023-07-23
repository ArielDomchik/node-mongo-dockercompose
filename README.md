
# Node.js, MongoDB, and Docker Compose App with Terraform and Application Load Balancer

This project is a simple web application built with Node.js and MongoDB using Docker containers. It displays the number of apples stored in a MongoDB database and provides a basic "hello world" page. Additionally, the application is deployed using Terraform, and an Application Load Balancer (ALB) for accessibility and distribution.

## Architecture

The updated application architecture now includes:

1.  **Node.js Container:** This container runs the Node.js server and serves the web application. It connects to the MongoDB container to retrieve the number of apples.
    
2.  **MongoDB Container:** This container runs the MongoDB database server. It stores the data for the application, including the number of apples.
    
3.  **AWS Infrastructure with Terraform:** The project now uses Terraform to provision the required AWS resources, including a Virtual Private Cloud (VPC), subnets, security groups, EC2 instance for the web application, an Application Load Balancer, and target groups.
    
4.  **Application Load Balancer (ALB):** The ALB is used to distribute incoming traffic. This adds high availability and load balancing to the application.
    

The containers in the AWS infrastructure share the same Docker network, allowing them to communicate with each other.

## Prerequisites

Before running the updated application, make sure you have the following installed:

-   Docker: [Installation Guide](https://docs.docker.com/get-docker/)
-   Docker Compose: [Installation Guide](https://docs.docker.com/compose/install/)
-   Terraform: [Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
-   AWS CLI: [Installation Guide](https://aws.amazon.com/cli/)
-  Jenkins: [Installation Guide](https://www.jenkins.io/doc/book/installing/linux/)

** note: Jenkins can be run as a docker container
Additionally, ensure you have valid AWS credentials set up to allow Terraform to interact with your AWS account.

## Setup

1.  Clone the repository:

`git clone https://github.com/ArielDomchik/node-mongo-dockercompose-terraform
cd node-mongo-dockercompose-terraform` 

2.  Install the application dependencies by running the following command:

`npm install` 

This command will install the required Node.js packages specified in the `package.json` file.

## Terraform Cloud Workspace

This Terraform configuration utilizes Terraform Cloud workspaces for isolation and easier management. The workspace name is set to `"<your-backend-here>"` at `terraform.tf`. If you are running this configuration in Terraform Cloud, ensure you have created the workspace with the correct name.

* Also validate that env variable `TF_CLOUD_ORGANIZATION` is set correctly to your terraform cloud organization name with export `TF_CLOUD_ORGANIZATION=<your-cloud-name>`.

```terraform {
  cloud {
    workspaces {
      name = "<your-backend-here>"
    }
  }
```


## Terraform Deployment

The project now includes Terraform configuration files to provision the AWS infrastructure.

1.  Initialize Terraform in the `terraform/` directory:

`cd terraform/
terraform init` 

2.  Review the Terraform plan to see the resources that will be created:

`terraform plan` 

3.  Apply the Terraform configuration to provision the AWS infrastructure:

`terraform apply` 

After applying the configuration, Terraform will create the VPC, subnets, security groups, EC2 instance, Application Load Balancer, and target groups and the application itself, Terraform will output the Application Load Balancer url:  `load_balancer_url = "<URL OF ALB OUTPUT>"` after `terraform apply` will finish.

## Jenkins Pipeline (Optional)

The project still includes a Jenkinsfile that defines a pipeline for building, testing, and deploying the application using Jenkins. The pipeline stages are as follows:

1.  Build: This stage installs the application dependencies and builds the Docker containers using the `docker compose` command.
    
2.  Test: This stage runs the tests for the application. You can customize this stage by adding your own test scripts.
    
3.  Clean: This stage stops and removes the Docker containers using the `docker compose down` command.
    
4.  Push: This stage logs in to the Docker registry, builds the Docker image, tags it with a version number, and pushes it to the repository specified in the `REPO` environment variable.
    
5.  Deploy: This stage uses SSH to deploy the new docker image to the EC2 Instance by pulling and deploying.
    

Note: The Jenkins pipeline is optional, and you can use other CI/CD tools or manually deploy the application using Terraform.

## Usage

To start the application locally with Docker Compose, run the following command:

`docker compose up` 

This command will build the Docker containers, install the dependencies, and start the application. You should see the logs indicating that the containers are running.

To access the application, open a web browser and navigate to `http://localhost:3000`. You should see the "hello world" page along with the number of apples displayed.

## Cleaning Up

To stop the application and remove the Docker containers, run the following command:

`docker-compose down` 

To destroy the AWS infrastructure provisioned by Terraform, go to the `terraform/` directory and run:

`terraform destroy` 

This will remove all the resources created in your AWS account.

----------

Feel free to further customize this README file according to your specific project requirements and add any additional information that you think is relevant. With the updated configuration using Terraform and the Application Load Balancer, your application is now highly available and can scale to handle increased traffic efficiently.
