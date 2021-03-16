
resource "aws_key_pair" "learner" {
  key_name   = "learner"
  public_key = file(var.key_path)

}

module "subnet_info" {
    source = "./modules/get_subnet_info"
    vpc_name = var.curr_vpc_name
    sg_name = var.security_grp_name
}

data "aws_iam_role" "master" {
  name = "K8S-Master"
}

data "aws_iam_role" "node" {
  name = "K8s-worker"
}

resource "aws_instance" "k8s-node" {
  ami           = var.aws_ec2_image
  count = 2
  instance_type = var.aws_instance_type
  subnet_id     = module.subnet_info.subnet_id
  iam_instance_profile        = data.aws_iam_role.node.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.learner.key_name
  vpc_security_group_ids      = [module.subnet_info.sg_id]
  tags = {
    Name = "Node-${count.index + 1}",
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_instance" "k8s-master" {
  ami           = var.aws_ec2_image
  instance_type = var.aws_instance_type
  subnet_id     = module.subnet_info.subnet_id
  iam_instance_profile        = data.aws_iam_role.master.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.learner.key_name
  vpc_security_group_ids      = [module.subnet_info.sg_id]
  tags = {
    Name = "Master",
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}


data "template_file" "ansible_local_hosts" {
  template = file("./local_ansible_hosts_template.tpl")
  vars = {
    master_public_ip = aws_instance.k8s-master.public_ip
  }
}

data "template_file" "ansible_master_hosts" {
  template = file("./master_ansible_hosts_template.tpl")
  vars = {
    master_private_ip = aws_instance.k8s-master.private_ip
    master_private_dns = aws_instance.k8s-master.private_dns
    node-1_private_ip = aws_instance.k8s-node[0].private_ip
    node-1_private_dns = aws_instance.k8s-node[0].private_dns
    node-2_private_ip = aws_instance.k8s-node[1].private_ip
    node-2_private_dns = aws_instance.k8s-node[1].private_dns
  }
}

data "template_file" "k8s-vars-file" {
  template = file("./k8s-vars-template.tpl")
  vars = {
    cluster-name = var.cluster_name
    master_public_ip = aws_instance.k8s-master.public_ip
    master_private_ip = aws_instance.k8s-master.private_ip
    node-1_private_ip = aws_instance.k8s-node[0].private_ip
    node-2_private_ip = aws_instance.k8s-node[1].private_ip
  }
}

resource "null_resource" "make_ansible_hosts_files" {
  
  provisioner "local-exec" {
    command = "cat > ./ansible/hosts<<EOL\n${data.template_file.ansible_local_hosts.rendered}\nEOL"
  }

  provisioner "local-exec" {
    command = "cat > ./ansible/master-files/hosts<<EOL\n${data.template_file.ansible_master_hosts.rendered}\nEOL"
  }
  
  provisioner "local-exec" {
    command = "cat > ./ansible/master-files/k8s-init/k8s-vars<<EOL\n${data.template_file.k8s-vars-file.rendered}\nEOL"
  }

}



