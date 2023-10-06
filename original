# PIUS INFRASTRUCTURE WITH IAC USING TERRAFORM 

# VPC 

resource "aws_vpc" "piusVPC" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = var.VPCname
  }
}

# INTERNETGATEWAY

resource "aws_internet_gateway" "piusGATEWAY" {
  vpc_id = aws_vpc.piusVPC.id

  tags = {
    Name = var.IGWname
  }
}

# 2 PUBLIC SUBNETS AND 1 PRIVATE SUBNET

resource "aws_subnet" "pubsubnets" {
  count = length(var.public_subnets)
  vpc_id     = aws_vpc.piusVPC.id
  cidr_block = var.subnet_cidr_block[count.index]
  availability_zone = var.subnet_availability_zone[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = var.public_subnets[count.index]
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.piusVPC.id
  cidr_block = var.privatesub_cidr_block
  availability_zone = var.privatesub_availability_zone 

  tags = {
    Name = var.private_subnet
  }
}

# ROUTE TABLE AND ROUTE TABLE ASSOCIATION FOR THE PUBLIC SUBNETS


resource "aws_route_table" "piustable" {

  count = length(var.routetable)
  vpc_id = aws_vpc.piusVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.piusGATEWAY.id
  }

  tags = {
    Name = var.routetable[count.index]
  }
}
resource "aws_route_table_association" "piusroute" {
  count = length(var.public_subnets)
  subnet_id      = aws_subnet.pubsubnets[count.index].id
  route_table_id = aws_route_table.piustable[count.index].id
 # route_table_id = element(aws_route_table.piustable.*.id, count.index)
}

# SECURITY GROUP FOR HTTPS, HTTP AND SSH

resource "aws_security_group" "pius_secuirty" {
  name        = var.security_name
  description = var.security_description
  vpc_id      = aws_vpc.piusVPC.id

  
ingress {
    description      = "ALLOW HTTP from ANYWHERE"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTPS (TLS) from ANYWHERE"
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
    Name = var.security_tags
  }
}

# LAUNCH TEMPLATE

resource "aws_launch_template" "piustemplate" {
  name = var.template_name

  image_id = var.template_image_id

  instance_type = var.template_instance_type

  key_name = var.template_private_key

  vpc_security_group_ids = [aws_security_group.pius_secuirty.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = var.template_tags
    }
  }

  user_data = filebase64(var.template_userdata)
}

# AUTOSCALING GROUP ASG

resource "aws_autoscaling_group" "piusautoscaling" {
  vpc_zone_identifier       = [for subnet in aws_subnet.pubsubnets : subnet.id]  
  desired_capacity   = var.asg_desired_capacity
  max_size           = var.asg_max_size
  min_size           = var.asg_min_size

  launch_template {
    id      = aws_launch_template.piustemplate.id
    version = "1"
  }
}

# ACM CERTIFICATE AND VALIDATION WITH ROUTE53 

resource "aws_acm_certificate" "piuscert" {
  domain_name       = var.acm_domain_name
  validation_method = "DNS"

  tags = {
    Environment = var.acm_tags
  }
}

data "aws_route53_zone" "piustech" { # This sends aws route53 to retrieve information about the dns zoned named piustech.io 
  name         = var.data_name # to match the domain used in the ACM CERTIFICATE
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
  name               = var.alb_name
  internal           = false
  load_balancer_type = var.load_balancer_type
  security_groups    = [aws_security_group.pius_secuirty.id]
  subnets            =  [for subnet in aws_subnet.pubsubnets : subnet.id]

  enable_deletion_protection = false

  tags = {
    Environment = var.alb_tags
  }
}

resource "aws_lb_target_group" "piustargetgroup" {
  name     = var.targetgroup_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.piusVPC.id
}

resource "aws_lb_listener" "piuslistener" {
  load_balancer_arn = aws_lb.piusalb.arn
  port              = var.lb_listener_port
  protocol          = var.lb_listener_protocol
  ssl_policy        = var.lb_listener_sslpolicy
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
  zone_id = data.aws_route53_zone.piustech.zone_id
  name    = var.route_53dns_recordname 
  type    = "A"
  allow_overwrite = true

  alias {
    name                   = aws_lb.piusalb.dns_name
    zone_id                = aws_lb.piusalb.zone_id
    evaluate_target_health = true
  }
}

# ALB TARGET GROUP ATTACHMENT to autoscaling group
resource "aws_autoscaling_attachment" "piusattachment_ASG" {
  autoscaling_group_name = aws_autoscaling_group.piusautoscaling.id
  lb_target_group_arn    = aws_lb_target_group.piustargetgroup.arn
}
