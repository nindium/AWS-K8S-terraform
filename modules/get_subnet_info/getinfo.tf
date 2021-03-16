locals {
    my_vpc_id = tolist(data.aws_vpcs.default_vpc.ids)[0]
    subnet_id = tolist(data.aws_subnet_ids.subnet_id_list.ids)[0]
    sg_id = tolist(data.aws_security_groups.sg_list.ids)[0]
}

data "aws_vpcs" "default_vpc" {
  tags = {
    Name = var.vpc_name
  }
  
}

data "aws_vpc" "my_vpc" {
  id = local.my_vpc_id
}
 
data "aws_subnet_ids" "subnet_id_list" {
  vpc_id = local.my_vpc_id
}

data "aws_subnet" "my_subnet" {
    id = local.subnet_id
}

data "aws_security_groups" "sg_list" {
    filter {
        name = "group-name"
        values = [var.sg_name]
    }
    filter {
        name = "vpc-id"
        values = [local.my_vpc_id]
    }
}

output "subnet_id" {
  value = local.subnet_id
}

output "sg_id" {
  value = local.sg_id
}

output "subnet_cidr" {
  value = data.aws_subnet.my_subnet.cidr_block
}
