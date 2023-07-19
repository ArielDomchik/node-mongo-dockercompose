provider "aws" {

  region                  = var.aws_region
  shared_credentials_file = "/home/ariel/.aws/credentials"
  profile                 = "default"

}

resource "aws_lb" "example" {
  name               = "example-lb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.public.id]
  security_groups    = [aws_security_group.alb-sg.id]
}

resource "aws_lb_target_group" "example" {
  name     = "example-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "example" {
  target_group_arn = aws_lb_target_group.example.arn
  target_id        = aws_instance.webserver.id
  port             = 80
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


resource "aws_instance" "webserver" {

  ami                         = "ami-0778521d914d23bc1"
  instance_type               = var.instance_type
  key_name                    = "ariel"
  vpc_security_group_ids      = [aws_security_group.web-sg.id]
  associate_public_ip_address = true
  root_block_device {
    volume_type           = "gp2"
    volume_size           = "8"
    delete_on_termination = false

  }
  tags = {
    Name = var.instance_name
  }
 user_data = file("script.sh")
}

output "IPAddress" {
  value = aws_instance.webserver.public_ip
}
