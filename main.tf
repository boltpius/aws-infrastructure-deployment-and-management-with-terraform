# PIUS INFRASTRUCTURE WITH IAC USING TERRAFORM 

# VPC 

resource "aws_vpc" "piusVPC" {
  cidr_block       = "10.0.0.0/24"
  instance_tenancy = "default"

  tags = {
    Name = "piusVPC"
  }
}

# INTERNETGATEWAY

resource "aws_internet_gateway" "piusGATEWAY" {
  vpc_id = aws_vpc.piusVPC.id

  tags = {
    Name = "piusGATEWAY"
  }
}

# 2 PUBLIC SUBNETS AND 1 PRIVATE SUBNET

resource "aws_subnet" "pub1" {
  vpc_id     = aws_vpc.piusVPC.id
  cidr_block = "10.0.0.0/28"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "pub1"
  }
}

resource "aws_subnet" "pub2" {
  vpc_id     = aws_vpc.piusVPC.id
  cidr_block = "10.0.0.16/28"
  availability_zone = "eu-west-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "pub2"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.piusVPC.id
  cidr_block = "10.0.0.32/28"
  availability_zone = "eu-west-1c"

  tags = {
    Name = "private"
  }
}

# ROUTE TABLE AND ROUTE TABLE ASSOCIATION FOR THE PUBLIC SUBNETS


resource "aws_route_table" "piustable" {
  vpc_id = aws_vpc.piusVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.piusGATEWAY.id
  }

  tags = {
    Name = "piustable"
  }
}
resource "aws_route_table_association" "piusroute" {
  subnet_id      = aws_subnet.pub1.id
  route_table_id = aws_route_table.piustable.id
}

resource "aws_route_table" "piustable2" {
  vpc_id = aws_vpc.piusVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.piusGATEWAY.id
  }

  tags = {
    Name = "piustable2"
  }
}
resource "aws_route_table_association" "piusroute2" {
  subnet_id      = aws_subnet.pub2.id
  route_table_id = aws_route_table.piustable2.id
}

# SECURITY GROUP FOR HTTPS, HTTP AND SSH

resource "aws_security_group" "pius_secuirty" {
  name        = "Pius Security"
  description = "Allow TLS, SSH, HTTP inbound traffic"
  vpc_id      = aws_vpc.piusVPC.id


ingress {
    description      = "ALLOW HTTP from ANYWHERE"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "TLS from ANYWHERE"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH from ANYWHERE"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls_ssh_http"
  }
}

# LAUNCH TEMPLATE

resource "aws_launch_template" "piustemplate" {
  name = "piustemplate"

  image_id = "ami-01dd271720c1ba44f"

  instance_type = "t2.micro"

  key_name = "yes"

  vpc_security_group_ids = [aws_security_group.pius_secuirty.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "pius application"
    }
  }

  user_data = filebase64("userdata.sh")
}

# AUTOSCALING GROUP ASG

resource "aws_autoscaling_group" "piusautoscaling" {
  vpc_zone_identifier       = [aws_subnet.pub1.id, aws_subnet.pub2.id]
  desired_capacity   = 0
  max_size           = 0
  min_size           = 0

  launch_template {
    id      = aws_launch_template.piustemplate.id
    version = "1"
  }
}



