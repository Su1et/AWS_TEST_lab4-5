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
              exec > >(tee /var/log/user-data.log)
              exec 2>&1

              echo "=== Starting user-data script at $(date) ==="

              echo "Updating system packages..."
              sudo yum update -y

              echo "Installing Docker..."
              sudo yum install docker -y
              sudo service docker start
              sudo systemctl enable docker

              echo "Waiting for Docker to be ready..."
              sleep 5

              # Перевірка статусу Docker
              sudo systemctl status docker

              echo "Attempting to pull Docker image su1et/hub_test_lab4-5:latest..."
              for i in {1..15}; do
                echo "Pull attempt $i/15..."
                if sudo docker pull su1et/hub_test_lab4-5:latest; then
                  echo "Successfully pulled image at $(date)"
                  break
                fi
                echo "Pull failed, retrying in 20 seconds..."
                sleep 20
              done

              echo "Starting application container..."
              sudo docker run -d --name lab6 -p 80:80 su1et/hub_test_lab4-5:latest

              if [ $? -eq 0 ]; then
                echo "Container 'lab6' started successfully at $(date)"
                sudo docker ps
              else
                echo "ERROR: Container failed to start at $(date)"
                sudo docker logs lab6
                exit 1
              fi

              echo "Waiting for container to stabilize..."
              sleep 10

              echo "Starting Watchtower for auto-updates..."
              sudo docker run -d \
                --name watchtower \
                -v /var/run/docker.sock:/var/run/docker.sock \
                containrrr/watchtower \
                --interval 300 \
                lab6

              if [ $? -eq 0 ]; then
                echo "Watchtower started successfully at $(date)"
              else
                echo "WARNING: Watchtower failed to start"
              fi

              echo "=== User-data script completed at $(date) ==="
              echo "=== Final container status ==="
              sudo docker ps -a
              EOF

  tags = {
    Name = "terraform-app-LAB6"
  }
}