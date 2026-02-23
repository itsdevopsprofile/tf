# create vpc
resource "aws_vpc" "v1" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = "vnet"
  }
}

# create subnet
resource "aws_subnet" "s1" {
  vpc_id                  = aws_vpc.v1.id
  cidr_block              = "192.168.0.0/22"
  availability_zone       = "ap-southeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}
# create internet gateway
resource "aws_internet_gateway" "int" {
  vpc_id = aws_vpc.v1.id
  tags = {
    Name = "igw-vnet"
  }
}

# create route table and add igw
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.v1.id
  tags = {
    Name = "RT-Public"
  }

  route {
    gateway_id = aws_internet_gateway.int.id
    cidr_block = "0.0.0.0/0"
  }
}

# associate subnet with rt
resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.s1.id
  route_table_id = aws_route_table.rt.id
}


# create security group
resource "aws_security_group" "firewall" {
  vpc_id = aws_vpc.v1.id
  name   = "firewall-vnet"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "vm" {
  ami                    = "ami-0ac0e4288aa341886"
  instance_type          = "t3.micro"
  key_name               = "ssh-key"
  subnet_id              = aws_subnet.s1.id
  vpc_security_group_ids = [aws_security_group.firewall.id]
  user_data              = <<-EOF
     #!/bin/bash
     sudo -i
     yum install httpd -y 
     systemctl start httpd 
     systemctl enable httpd 
     echo "Hello Terraform" > /var/www/html/index.html
    EOF

  tags = {
    Name = "webserver"
  }


}
