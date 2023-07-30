output "swarm_manager_public_ip" {
  value = "${vultr_instance.manager1.main_ip}"
}


output "data_external" {
  value = "${data.external.manager1_token.result.manager}"
}
