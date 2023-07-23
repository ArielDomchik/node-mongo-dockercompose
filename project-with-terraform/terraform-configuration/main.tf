provider "aws" {
  region = "us-east-1"  # Replace with your desired region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "terraform-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]  # Specify at least two Availability Zones
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]  # Use the private subnet
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]  # Use at least two public subnets in different AZs
  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_security_group" "alb-sg" {
  name_prefix = "alb-sg-"

  vpc_id = module.vpc.vpc_id  # Associate the security group with the same VPC as the EC2 instance and ALB

  # Allow HTTP and HTTPS traffic from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "webserver" {
  ami                         = "ami-05bfc1ab11bfbf484"  # Replace with your desired AMI ID
  instance_type               = "t2.micro"  # Replace with your desired instance type
  key_name                    = "ariel"  # Replace with the name of your EC2 key pair
  vpc_security_group_ids      = [aws_security_group.web-sg.id]  # Use the imported security group
  subnet_id                   = module.vpc.public_subnets[0]  # Deploy EC2 in the private subnet
  associate_public_ip_address = true  # Assign a public IP address to the instance

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    delete_on_termination = true
  }

  tags = {
    Name = "WebServer"
  }

  user_data = <<-EOT
    #!/bin/bash

    # Remove existing Docker packages (optional)
    sudo apt-get remove docker docker-engine docker.io containerd runc

    # Install Docker dependencies
    sudo apt-get update
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    # Add Docker GPG key and repository
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    # Install Docker and Docker Compose
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose

    # Add the current user to the docker group (you might need to restart the shell)
    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker

    # Create the docker-compose.yml file
    cat <<EOF > docker-compose.yml
    version: '3'
    services:
      node:
        restart: always
        image: arieldomchik/nodeapp:latest
        ports:
          - 3000:3000
        volumes:
          - ./:/code
      mongo:
        image: mongo
        container_name: mongodb-container
        ports:
          - 27017:27017
        volumes:
          - mongodb:/data/db
    volumes:
      mongodb:
    EOF

    # Start the Docker containers
    docker-compose up --build -d
  EOT
}

resource "aws_lb" "example" {
  name               = "example-lb"
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets  # ALB in the public subnets
  security_groups    = [aws_security_group.alb-sg.id]  # Use the ALB security group

  tags = {
    Name = "ExampleLB"
  }
}

resource "aws_lb_target_group" "example" {
  name     = "example-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

    # Health check settings
  health_check {
    path                = "/"  # Replace with the path to your health check endpoint
    protocol            = "HTTP"
    port                = "traffic-port"  # Health check will use the same port as the target group
    matcher             = "200"  # HTTP codes indicating a healthy target
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "ExampleTargetGroup"
  }
}

resource "aws_lb_target_group_attachment" "example" {
  target_group_arn = aws_lb_target_group.example.arn
  target_id        = aws_instance.webserver.id
  port             = 3000
}

resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.example.arn
    type             = "forward"
  }
}

resource "aws_security_group" "web-sg" {
  name_prefix = "web-sg-"
  vpc_id      = module.vpc.vpc_id

  # Allow inbound HTTP, HTTPS, custom ports (3000 and 27017) from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

