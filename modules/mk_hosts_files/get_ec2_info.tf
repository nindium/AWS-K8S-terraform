data "aws_instance" "master" {
    filter {
        name = "tag:Name"
        values = ["Master"]
    }
}

data "aws_instance" "node-1" {
    filter {
        name = "tag:Name"
        values = ["Node-1"]
    }
}

data "aws_instance" "node-2" {
    filter {
        name = "tag:Name"
        values = ["Node-2"]
    }
}

data "template_file" "ansible_local_hosts" {
  template = file("./local_ansible_hosts_template.tpl")
  vars = {
    master_public_ip = data.aws_instance.master.public_ip
  }
}

data "template_file" "ansible_master_hosts" {
  template = file("./master_ansible_hosts_template.tpl")
  vars = {
    master_private_ip = data.aws_instance.master.private_ip
    master_private_dns = data.aws_instance.master.private_dns
    node-1_private_ip = data.aws_instance.node-1.private_ip
    node-1_private_dns = data.aws_instance.node-1.private_dns
    node-2_private_ip = data.aws_instance.node-2.private_ip
    node-2_private_dns = data.aws_instance.node-2.private_dns
  }
}

resource "null_resource" "make_ansible_hosts_files" {
  triggers = {
    template_rendered = fileexists("./ansible/master-files/hosts")
  }
  provisioner "local-exec" {
    command = "cat > ./ansible/hosts<<EOL\n${data.template_file.ansible_local_hosts.rendered}\nEOL"
  }

  provisioner "local-exec" {
    command = "cat > ./ansible/master-files/hosts<<EOL\n${data.template_file.ansible_master_hosts.rendered}\nEOL"
  }
}



