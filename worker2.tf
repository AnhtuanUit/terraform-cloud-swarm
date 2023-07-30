resource "vultr_instance" "worker2" {
  label = "worker2"
  plan             = "vc2-1c-1gb"   # Using 1GB of RAM
  region           = "sgp"         # Region is Singapore
  image_id         = "docker"        # Using the Docker OS (OS ID for Docker) 
  enable_ipv6      = false         # Disabling IPv6
  ssh_key_ids       = ["f2efd2fd-d4c4-490a-881e-0ec6f5c2a918"]       # Replace 12345 with the actual ID of the "Macbook pro" SSH key in Vultr
  user_data = <<-EOF
    #cloud-config
    runcmd:
      - sudo iptables -A INPUT -p tcp --dport 2377 -j ACCEPT
      - sudo iptables -A INPUT -p tcp --dport 7946 -j ACCEPT
      - sudo iptables -A INPUT -p udp --dport 7946 -j ACCEPT
      - sudo iptables -A INPUT -p udp --dport 4789 -j ACCEPT
    EOF

  connection {
    type     = "ssh"
    user     = "root"
    password = vultr_instance.worker2.default_password
    host     = vultr_instance.worker2.main_ip
  }

  provisioner "remote-exec" {
    inline = [
      "docker swarm join --token ${data.external.manager1_token.result.manager} ${vultr_instance.manager1.main_ip}:2377",
    ]
  }
}