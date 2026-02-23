
resource "aws_security_group" "firewall" {
    name = "test-sg"
    vpc_id = "vpc-079cb5d4718c9e695"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
        ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

        egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}


resource "aws_instance" "vm" {
    ami = "ami-0ac0e4288aa341886"
    instance_type = "t3.micro"
    key_name = "ssh-key"
    vpc_security_group_ids = [aws_security_group.firewall.id]
    user_data = <<-EOF
     #!/bin/bash
     sudo -i
     yum update -y
     yum install httpd -y
     systemctl start httpd 
     systemctl enable httpd 
     echo "Hello Terraform" > /var/www/html/index.html
    EOF

    tags = {
        Name = "server-01"
    }
}
