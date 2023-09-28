resource "aws_vpc" "piusVPC" {
  cidr_block       = "10.0.0.0/24"
  instance_tenancy = "default"

  tags = {
    Name = "piusVPC"
  }
}

resource "aws_internet_gateway" "piusGATEWAY" {
  vpc_id = aws_vpc.piusVPC.id

  tags = {
    Name = "piusGATEWAY"
  }
}

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
