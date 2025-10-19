# Отримати дефолтну VPC
data "aws_vpc" "default" {
  default = true
}

# Отримати всі підмережі дефолтної VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-sg"
  }
}

resource "aws_instance" "app_instance" {
  ami                    = "ami-0aadcf405dcb7d041"
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = element(data.aws_subnets.default.ids, 0)
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install docker -y
              sudo service docker start
              sudo usermod -aG docker ec2-user

              docker run -d --name lab6 -p 80:80 su1et/hub_test_lab4-5:latest

              docker run -d \
                --name watchtower \
                -v /var/run/docker.sock:/var/run/docker.sock \
                containrrr/watchtower \
                --interval 300 \
                lab6
              EOF

  tags = {
    Name = "terraform-app-LAB6"
  }
}
