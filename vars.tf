# Pius VPC

variable "VPCname" {
  type        = string
  default     = "piusVPC"
}


variable "vpc_cidr_block" {
  type        = string
  default     = "10.0.0.0/24"
}

# Internetgateway

variable "IGWname" {
  type        = string
  default     = "piusGATEWAY"
}

# Subnets
variable "public_subnets" {
  type        = list(string)
  default     = ["pub1", "pub2"]
}
 variable "subnet_cidr_block" {
   type        = list(string)
   default     = ["10.0.0.0/28", "10.0.0.16/28"]
 }
variable "subnet_availability_zone" {
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
}

#privatesubnet 
variable "private_subnet" {
  type        = string
  default     = "privatesubnet"
}

variable "privatesub_cidr_block" {
  type        = string
  default     = "10.0.0.32/28"
}
variable "privatesub_availability_zone" {
  type        = string
  default     = "eu-west-1c"
}

# route table
variable "routetable" {
  type        = list(string)
  default     = ["piustable", "piustable2"]
}

variable "cidr_block" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

## Security group 
variable "security_name" {
  type        = string
  default     = "Pius_security"
}
 variable "security_description" {
   type        = string
   default     = "Allow TLS, SSH, HTTP inbound traffic"
 }

variable "security_tags" {
  type        = string
  default     = "allow_tls_ssh_http"
}

## LAUNCH TEMPLATE

variable "template_name" {
  type        = string
  default     = "piustemplate"
}
 variable "template_image_id" {
   type        = string
   default     = "ami-01dd271720c1ba44f"
 }
 variable "template_instance_type" {
   type        = string
   default     = "t2.micro"
   description = "description"
 }
 variable "template_private_key" {
   type        = string
   default     = "yes"
}
variable "template_tags" {
  type        = string
  default     = "pius application"
}

variable "template_userdata" {
  type        = string
  default     = "userdata.sh"
}

##AUTOSCALING GROP ASG

variable "asg_desired_capacity" {
  type        = number
  default     = 2
}
variable "asg_max_size" {
  type        = number
  default     = 4
}
variable "asg_min_size" {
  type        = number
  default     = 2
}

## ACM CERTIFICATE AND VALIDATION WITH ROUTE53 

variable "acm_domain_name" {
  type        = string
  default     = "femi.piustech.io"
}
variable "acm_tags" {
  type        = string
  default     = "piusacmcert"
}
# retrieveing data from route53zone piustech.io
variable data_name {
  type        = string
  default     = "piustech.io"
}

## APPLICATION LOADBALANCER (ALB), TAGRET GROUP AND LISTENER 
variable "alb_name" {
  type        = string
  default     = "piusloadbalancer"
}
variable "load_balancer_type" {
  type        = string
  default     = "application"
}
variable "alb_tags" {
  type        = string
  default     = "production"
}
#target group for lb
variable "targetgroup_name" {
  type        = string
  default     = "pius-lb-targetgroup"
}
# alb listener to route https to targetgroup
variable "lb_listener_port" {
  type        = string
  default     = 443
}
variable "lb_listener_protocol" {
  type        = string
  default     = "HTTPS"
}
variable "lb_listener_sslpolicy" {
  type        = string
  default     = "ELBSecurityPolicy-2016-08"
}

## CREATING A ROUTE 53 RECORD FOR THE DNS AND ALIASING IT WITH THE LOADBALANCER
variable "route_53dns_recordname" {
  type        = string
  default     = "femi.piustech.io"
}