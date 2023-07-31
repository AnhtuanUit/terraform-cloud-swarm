# output "ssh_init_token" {
#   value = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${vultr_instance.manager1.main_ip} docker swarm init --force-new-cluster \nTOKEN=$(ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${vultr_instance.manager1.main_ip} docker swarm join-token manager -q)\nssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${vultr_instance.worker1.main_ip} docker swarm join --token $TOKEN ${vultr_instance.manager1.main_ip}:2377\nssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${vultr_instance.worker2.main_ip} docker swarm join --token $TOKEN ${vultr_instance.manager1.main_ip}:2377"
# }

# output "main_ips" {
#   value = "manager1: ${vultr_instance.manager1.main_ip}\n worker1: ${vultr_instance.worker1.main_ip}\n worker2: ${vultr_instance.worker2.main_ip}"
# }
