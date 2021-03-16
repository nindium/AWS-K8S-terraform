[master]
${master_private_ip} hostname=${master_private_dns} ubuntu_release=bionic

[node1]
${node-1_private_ip} hostname=${node-1_private_dns} ubuntu_release=bionic

[node2]
${node-2_private_ip} hostname=${node-2_private_dns} ubuntu_release=bionic

[nodes:children]
node1
node2
