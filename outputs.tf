output "ssh_manager1" {
  value = "TOKEN=$(ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${vultr_instance.manager1.main_ip} docker swarm join-token manager -q)"
}
output "ssh_worker1" {
  value = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${vultr_instance.worker1.main_ip} docker swarm join --token $TOKEN ${vultr_instance.manager1.main_ip}:2377"
}

output "ssh_worker2" {
  value = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${vultr_instance.worker2.main_ip} docker swarm join --token $TOKEN ${vultr_instance.manager1.main_ip}:2377"
}

output "ssh_all" {
  value = "manager1: ${vultr_instance.manager1.main_ip}\n worker1: ${vultr_instance.worker1.main_ip}\n worker2: ${vultr_instance.worker2.main_ip}"
}
