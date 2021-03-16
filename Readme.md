Scope:
    Create Kubernetes cluster (1 master, 2 nodes) in AWS cloud
Exit criteria:
    Working kubernetes cluster with 1 master and worker nodes

Solution:
    1. Create infrastructure in AWS (3 EC2 instances) with "terraform apply --auto-approve" command
    2. Install ansible to the Master host and copy necessary files using ansible
        ansible-playbook -i hosts basic-setup.yaml
    3. Login into the Master node.
    4. Install updates and python on worker nodes (this will be automated in the future [see TODO])
        ssh ubuntu@<worker-node-ip> "sudo apt-get update -y"
        ssh ubuntu@<worker-node-ip> "sudo apt-get install python -y"
    5. Install prerequsits with ansible (use files from "master-files" folder):
        ansible-playbook -i hosts k8s-deploy.yaml
    6. Run script k8s-install.sh from master-files/k8s-init
    7. Check cluster status from the master node:
        kubectl get nodes
    Should see output like this
    NAME                         STATUS   ROLES                  AGE     VERSION
        ip-10-0-1-145.ec2.internal   Ready    <none>                 107s    v1.20.4
        ip-10-0-1-167.ec2.internal   Ready    control-plane,master   2m19s   v1.20.4
        ip-10-0-1-171.ec2.internal   Ready    <none>                 114s    v1.20.4
TODO:
    add bootstrap script to install python on all hosts
