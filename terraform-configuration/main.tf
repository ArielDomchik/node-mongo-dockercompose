provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = "10.0.0.0/16"

  azs                  = ["us-east-1a", "us-east-1b"]       # Specify at least two Availability Zones
  private_subnets      = ["10.0.1.0/24"]     # Use the private subnet
  public_subnets       = ["10.0.101.0/24", "10.0.102.0/24"] # Use at least two public subnets in different AZs
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_security_group" "alb-sg" {
  name_prefix = "alb-sg-"

  vpc_id = module.vpc.vpc_id # Associate the security group with the same VPC as the EC2 instance and ALB

  # Allow HTTP and HTTPS traffic from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
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
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.web-sg.id] # Use the imported security group
  subnet_id                   = module.vpc.public_subnets[0]   # Deploy EC2 in the private subnet
  associate_public_ip_address = true                           # Assign a public IP address to the instance

  root_block_device {
    volume_type           = var.volume_type
    volume_size           = var.volume_size
    delete_on_termination = true
  }

  tags = {
    Name = var.instance_name
  }

  user_data = file("script.sh")
}

resource "aws_lb" "example" {
  name               = var.lb_name
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets      # ALB in the public subnets
  security_groups    = [aws_security_group.alb-sg.id] # Use the ALB security group

  tags = {
    Name = "ExampleLB"
  }
}

resource "aws_lb_target_group" "example" {
  name     = var.target_group_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  # Health check settings
  health_check {
    path                = "/" # Replace with the path to your health check endpoint
    protocol            = "HTTP"
    port                = "traffic-port" # Health check will use the same port as the target group
    matcher             = "200"          # HTTP codes indicating a healthy target
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = {
    Name = "OctopusTargetGroup"
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

  # Allow inbound HTTP, HTTPS, custom ports (3000) from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
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

