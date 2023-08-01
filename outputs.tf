output "manager1" {
  value = "API: http://${vultr_instance.manager1.main_ip}:3000\nMongoDB: http://${vultr_instance.manager1.main_ip}:27017"
}
output "worker1" {
  value = "API: http://${vultr_instance.worker1.main_ip}:3000\nMongoDB: http://${vultr_instance.worker1.main_ip}:27017"
}

output "worker2" {
  value = "API: http://${vultr_instance.worker2.main_ip}:3000\nMongoDB: http://${vultr_instance.worker2.main_ip}:27017"
}

output "ssh" {
  value = "manager1: ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${vultr_instance.manager1.main_ip}\nworker1: ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${vultr_instance.worker1.main_ip}\nworker2: ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${vultr_instance.worker2.main_ip}"
}