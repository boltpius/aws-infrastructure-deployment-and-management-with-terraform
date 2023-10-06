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

# ACM CERTIFICATE AND VALIDATION WITH ROUTE53 

resource "aws_acm_certificate" "piuscert" {
  domain_name       = "satar.piustech.io"
  validation_method = "DNS"

  tags = {
    Environment = "piusacmcert"
  }
}

data "aws_route53_zone" "piustech" { # This sends aws route53 to retrieve information about the dns zoned named piustech.io 
  name         = "piustech.io" # to match the domain used in the ACM CERTIFICATE
  private_zone = false # it is set to false because my dns zone is public 
 }

resource "aws_route53_record" "piusrecord" { # this creates a record for the purpose of acm certificate validation 
  for_each = {
    for dvo in aws_acm_certificate.piuscert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60 # ttl (time to live)
  type            = each.value.type
  zone_id         = data.aws_route53_zone.piustech.zone_id
}

resource "aws_acm_certificate_validation" "piusvalidation" {  # this block uses the amazon resource block to specify which certificate to validate.
  certificate_arn         = aws_acm_certificate.piuscert.arn
  validation_record_fqdns = [for record in aws_route53_record.piusrecord : record.fqdn]
}


# APPLICATION LOADBALANCER (ALB), TAGRET GROUP AND LISTENER 
resource "aws_lb" "piusalb" {
  name               = "piusloadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.pius_secuirty.id]
  subnets            = [aws_subnet.pub1.id, aws_subnet.pub2.id]
  # this was the previous one subnets            = [for subnet in aws_subnet.public : subnet.id]

  enable_deletion_protection = true

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "piustargetgroup" {
  name     = "pius-lb-targetgroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.piusVPC.id
}

resource "aws_lb_listener" "piuslistener" {
  load_balancer_arn = aws_lb.piusalb.arn
  port              = "443"
  protocol          = "HTTPS" 
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.piuscert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.piustargetgroup.arn
  }
}

# REDIRECT HTTP TRAFFIC TO HTTPS AND THEN FORWARD THE TRAFFIC TO LB TARGET GROUP
resource "aws_lb_listener" "piusredirect" {
  load_balancer_arn = aws_lb.piusalb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
} 

# CREATING A ROUTE 53 RECORD FOR THE DNS AND ALIASING IT WITH THE LOADBALANCER

resource "aws_route53_record" "satar_piustech" {
  # zone_id = aws_route53_zone.piustech.zone_id
  zone_id = data.aws_route53_zone.piustech.zone_id
  name    = "satar.piustech.io"
  type    = "A"

  alias {
    name                   = aws_lb.piusalb.dns_name
    zone_id                = aws_lb.piusalb.zone_id
    evaluate_target_health = true
  }
}

# ALB TARGET GROUP ATTACHMENT 
resource "aws_autoscaling_attachment" "piusattachment_ASG" {
  autoscaling_group_name = aws_autoscaling_group.piusautoscaling.id
  lb_target_group_arn    = aws_lb_target_group.piustargetgroup.arn
}
