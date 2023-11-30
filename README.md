# aws-infrastructure-deployment-and-management-with-terraform

# Project Summary

This project details the creation of an end-to-end infrastructure on Amazon Web Services (AWS) using Terraform for Infrastructure as Code (IaC). The objective was to establish a scalable, secure, and automated architecture for the PIUS system.

## Steps and Explanations:

### 1. VPC Configuration:
- **Process:** 
  - Defined a Virtual Private Cloud (VPC) using Terraform's `aws_vpc` resource.
- **Details:** 
  - Utilized specific CIDR blocks and default tenancy for the VPC.

### 2. Internet Gateway:
- **Process:** 
  - Created an internet gateway using `aws_internet_gateway` resource and attached it to the VPC.
- **Details:** 
  - This facilitated internet access for resources within the VPC.

### 3. Subnets Setup:
- **Process:** 
  - Established public and private subnets through `aws_subnet` resources across multiple availability zones.
- **Details:** 
  - Enabled high availability and resource segregation within the VPC.

### 4. Routing Configuration:
- **Process:** 
  - Configured route tables for public subnets to direct traffic to the internet gateway via `aws_route_table`.
- **Details:** 
  - Facilitated proper network traffic routing within the VPC.

### 5. Security Groups:
- **Process:** 
  - Defined comprehensive security rules using `aws_security_group` for HTTP, HTTPS, and SSH traffic.
- **Details:** 
  - Allowed specific inbound and outbound traffic based on defined protocols and ports.

### 6. Launch Template:
- **Process:** 
  - Created a launch template via `aws_launch_template` specifying configurations for EC2 instances.
- **Details:** 
  - Included specifications for instance type, image ID, key pair, and user data.

### 7. Autoscaling Group (ASG):
- **Process:** 
  - Configured an autoscaling group using `aws_autoscaling_group` to dynamically adjust EC2 instance capacity based on load metrics.
- **Details:** 
  - Set minimum and maximum instance sizes to ensure scalability.

### 8. SSL Certificate and DNS Setup:
- **Process:** 
  - Obtained an SSL certificate through ACM (`aws_acm_certificate`) and validated it via Route 53.
- **Details:** 
  - Ensured secure connections and validated domain ownership for SSL/TLS.

### 9. Application Load Balancer (ALB) Configuration:
- **Process:** 
  - Set up an ALB via `aws_lb` to distribute incoming traffic across instances within the ASG.
- **Details:** 
  - Ensured efficient load distribution and high availability.

### 10. HTTP to HTTPS Redirection:
- **Process:** 
  - Configured a listener within ALB to redirect HTTP traffic to HTTPS for enhanced security.
- **Details:** 
  - Ensured secure communication channels for incoming requests.

### 11. Route 53 DNS Record:
- **Process:** 
  - Created a Route 53 record aliasing the ALB for domain name resolution.
- **Details:** 
  - Provided a user-friendly domain name resolution for the infrastructure.

This infrastructure setup aims to provide a scalable, secure, and automated solution for the PIUS system on AWS. The use of Terraform allows for consistent and efficient infrastructure deployment and management.