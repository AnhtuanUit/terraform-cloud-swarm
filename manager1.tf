

resource "vultr_instance" "manager1" {
  label = "manager1"
  hostname = "manager1"
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
      - docker swarm init --force-new-cluster
    EOF
  connection {
    type     = "ssh"
    user     = "root"
    password = vultr_instance.manager1.default_password
    host     = vultr_instance.manager1.main_ip
  }

  // Verify vultr host setup done
  provisioner "remote-exec" {
    inline = [
      "echo Manager1 connected",
    ]
  }

  provisioner "local-exec" {
    # The command to execute on the local machine to download the public key
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null local-data/vult_ssh_key root@${vultr_instance.manager1.main_ip}:/root/.ssh/id_rsa"
  }
}


      
resource "null_resource" "install-registry" {
  depends_on = [vultr_instance.manager1]

  connection {
    type     = "ssh"
    user     = "root"
    password = vultr_instance.manager1.default_password
    host     = vultr_instance.manager1.main_ip
    agent = false
  }

  provisioner "remote-exec" {
    # Start Docker registry
    inline = [
      # Check if port not running then deploy docker resgister
      "docker service create --name registry --publish published=5000,target=5000 registry:2"
    ]
  }
}

resource "github_repository_deploy_key" "example" {
  depends_on = [ vultr_instance.manager1 ]
  
  repository = var.GITHUB_REPO
  title      = "Vultr Deploy Key Manager1"
  key        = file("local-data/vult_ssh_key.pub")
  read_only = true
}

# resource "null_resource" "git_clone" {
#   depends_on = [vultr_instance.manager1, github_repository_deploy_key.example]

#   connection {
#     type     = "ssh"
#     user     = "root"
#     password = vultr_instance.manager1.default_password
#     host     = vultr_instance.manager1.main_ip
#     agent = false
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "GIT_SSH_COMMAND='ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/tmp/known_hosts' git clone git@github.com:${var.GITHUB_USERNAME}/${var.GITHUB_REPO}.git",
#     ]
#   }
# }

resource "null_resource" "install-docker-compose" {
  depends_on = [vultr_instance.manager1]

  connection {
    type     = "ssh"
    user     = "root"
    password = vultr_instance.manager1.default_password
    host     = vultr_instance.manager1.main_ip
    agent = false
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      # Install docker-compose
      "sudo curl -L \"https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)\" -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "docker-compose --version",
    ]
  }
}

resource "null_resource" "stack-deploy" {
  depends_on = [vultr_instance.manager1, github_repository_deploy_key.example, null_resource.install-docker-compose, null_resource.install-registry]

  connection {
    type     = "ssh"
    user     = "root"
    password = vultr_instance.manager1.default_password
    host     = vultr_instance.manager1.main_ip
    agent = false
  }

  provisioner "remote-exec" {
    inline = [
      "set -e",
      "[ ! -d \"${var.GITHUB_REPO}\" ] &&  GIT_SSH_COMMAND='ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/tmp/known_hosts' git clone git@github.com:${var.GITHUB_USERNAME}/${var.GITHUB_REPO}.git",
      # Clone source code
      "cd ${var.GITHUB_REPO}",
      "cp .env.example .env",
      # Docker-compoe build or rebuild all images needed
      "docker-compose -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.swarm.yml build",
      # Publish source image
      "docker-compose -f docker-compose.yml -f docker-compose.dev.yml -f docker-compose.swarm.yml push",
      # Deploy
      "docker stack deploy -c docker-compose.yml -c docker-compose.dev.yml -c docker-compose.swarm.yml stack-name",
      "docker stack ps stack-name",
    ]
  }
}

resource "null_resource" "connect_hosts" {
  depends_on = [vultr_instance.manager1, vultr_instance.worker1, vultr_instance.worker2]

  provisioner "local-exec" {
    # The command to execute on the local machine to download the public key
    command = <<-EOT
      TOKEN=$(ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${vultr_instance.manager1.main_ip} docker swarm join-token manager -q);
      ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${vultr_instance.worker1.main_ip} docker swarm join --token $TOKEN ${vultr_instance.manager1.main_ip}:2377;
      ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${vultr_instance.worker2.main_ip} docker swarm join --token $TOKEN ${vultr_instance.manager1.main_ip}:2377;
    EOT
  }
}

resource "null_resource" "stack-scale" {
  depends_on = [null_resource.connect_hosts, null_resource.stack-deploy]

  connection {
    type     = "ssh"
    user     = "root"
    password = vultr_instance.manager1.default_password
    host     = vultr_instance.manager1.main_ip
    agent = false
  }

  provisioner "remote-exec" {
    inline = [
      # Scale service
      "docker service scale stack-name_mongodb=1 stack-name_node-app=2"
    ]
  }
}

resource "github_actions_secret" "HOST" {
  repository       = var.GITHUB_REPO
  secret_name      = "HOST"
  plaintext_value  = vultr_instance.manager1.main_ip

  depends_on = [vultr_instance.manager1]
}

resource "github_actions_secret" "USERNAME" {
  repository       = var.GITHUB_REPO
  secret_name      = "USERNAME"
  plaintext_value  = "root"

  depends_on = [vultr_instance.manager1]
}