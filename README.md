# aws-infrastructure-deployment-and-management-with-terraform

# Project Summary

This project entails the creation of an end-to-end infrastructure on Amazon Web Services (AWS) using Terraform as an Infrastructure as Code (IaC) tool. The objective was to establish a scalable, secure, and automated architecture for the PIUS system. The infrastructure setup includes Virtual Private Cloud (VPC), subnets (public and private), internet gateway, routing tables, security groups, autoscaling groups, Application Load Balancer (ALB), DNS setup with Route 53, and automation through Terraform.

## Steps Taken:

1. **VPC Configuration:**
    - Defined the VPC with specific CIDR blocks and default tenancy.
  
2. **Internet Gateway:**
    - Created an internet gateway and attached it to the VPC for internet access.

3. **Subnets Setup:**
    - Established public and private subnets within the VPC across multiple availability zones for high availability and segregation of resources.

4. **Routing Configuration:**
    - Configured route tables for public subnets to direct traffic to the internet gateway.

5. **Security Groups:**
    - Defined comprehensive security rules allowing specific inbound and outbound traffic for HTTP, HTTPS, and SSH.

6. **Launch Template:**
    - Created a launch template specifying the configuration for EC2 instances.

7. **Autoscaling Group (ASG):**
    - Configured an autoscaling group to dynamically adjust EC2 instance capacity based on load.

8. **SSL Certificate and DNS Setup:**
    - Obtained an SSL certificate using ACM and validated it via Route 53 for secure connections.

9. **Application Load Balancer (ALB) Configuration:**
    - Set up an ALB to distribute incoming traffic across instances within the ASG.

10. **HTTP to HTTPS Redirection:**
    - Configured a listener to redirect HTTP traffic to HTTPS for enhanced security.

11. **Route 53 DNS Record:**
    - Created a Route 53 record aliasing the ALB for domain name resolution.

This infrastructure setup aims to provide a scalable, secure, and automated solution for the PIUS system on AWS. The use of Terraform allows for consistent and efficient infrastructure deployment and management.