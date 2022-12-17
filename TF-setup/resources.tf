resource "aws_vpc" "test_vpc" {
  cidr_block           = "192.168.0.0/24"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "test_subnet" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "192.168.0.0/28"
  availability_zone = "eu-central-1c"
}

resource "aws_internet_gateway" "test_internet_gw" {
  vpc_id = aws_vpc.test_vpc.id
}

resource "aws_route_table" "test_route_table" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_internet_gw.id
  }
}

resource "aws_route_table_association" "test_route_table_assoc" {
  subnet_id      = aws_subnet.test_subnet.id
  route_table_id = aws_route_table.test_route_table.id
}

resource "aws_security_group" "test_security_group" {
  vpc_id      = aws_vpc.test_vpc.id
  name        = "test-sg-01"
  description = "Security group for testing"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.home_ip
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "test_vm_key" {
  # To create a key run:
  #   ssh-keygen -t <type> 
  # and save it to file
  key_name   = "deployer-key"
  public_key = file(var.public_key_path)
}

resource "aws_instance" "test_ubuntu_vm" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.test_vm_key.id
  vpc_security_group_ids      = [aws_security_group.test_security_group.id]
  subnet_id                   = aws_subnet.test_subnet.id
  associate_public_ip_address = true

  tags = {
    Name = "Test-Ubuntu-VM"
  }

  provisioner "local-exec" {
    command = templatefile("config-ssh-to-testVM.tpl", {
      hostname     = self.public_ip,
      user         = "ubuntu",
      identityfile = var.public_key_path
    })
    interpreter = ["bash", "-c"]
    # To apply provisioner after instance was set
    # you need to run command:
    #   terraform apply -replace aws_instance.test_ubuntu_vm
    # Resource will be destroyed and redeployed
  }

  provisioner "local-exec" {
    command = templatefile("config-ansible-hosts.tpl", {
      hostname   = self.public_ip,
      user       = "ubuntu",
      privateKey = var.public_key_path
    })
    interpreter = ["bash", "-c"]
  }

  provisioner "local-exec" {
    command = templatefile("create-ssl-cert-config.tpl", {
      hostname = self.public_ip
    })
    interpreter = ["bash", "-c"]
  }
}