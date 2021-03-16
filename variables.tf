variable "cluster_name" {
  description = "Define Kubernetes cluster name"
  type        = string
  default     = "my-cluster"
}


variable "aws_region" {
  description = "Define AWS region"
  type        = string
  default     = "us-east-1"
}

variable "az" {
  description = "Define availability zone"
  type        = string
  default     = "us-east-1a"
}

variable "aws_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.large"
}

variable "aws_ec2_image" {
  description = "EC2 amazon image ID"
  type        = string
  default     = "ami-02fe94dee086c0c37"
}

variable "key_path" {
    description = "Path to the public key"
    type = string
    default = "/home/just/.ssh/id_rsa.pub"
}

variable "curr_vpc_name" {
    description = "Name of VPC we want to use"
    type = string
    default = "VPC (Default)"
}

variable "security_grp_name" {
    description = "Security group name"
    type = string
    default = "Jenkins-SG"
}