

resource "vultr_instance" "manager1" {
  label = "manager1"
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
    password = vultr_instance.manager1.default_password
    host     = vultr_instance.manager1.main_ip
  }

  provisioner "remote-exec" {
    inline = [
      "touch hello-mamager.txt",
    ]
  }

  provisioner "local-exec" {
    # The command to execute on the local machine to download the public key
    command = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null /Users/tuando/Documents/Workspace/demos/terrafrom-demo/local-data/vult_ssh_key root@${vultr_instance.manager1.main_ip}:/root/.ssh/id_rsa"
  }

  # provisioner "local-exec" {
  #   # The command to execute on the local machine to download the public key
  #   command = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${vultr_instance.manager1.main_ip} 'git clone git@github.com:AnhtuanUit/example-repo.git'"
  # }  
}

# resource "null_resource" "download_ssh_key" {
#   # Triggers the provisioner to run when the Vultr server has been created
#   triggers = {
#     id = vultr_instance.manager1.main_ip
#   }
#   # provisioner "local-exec" {
#   #   # The command to execute on the local machine to download the public key
#   #   command = "ssh root@${vultr_instance.manager1.main_ip}:/root/.ssh/id_rsa.pub local-data/vultr_ssh_key.pub"
#   # }

  
#   # provisioner "local-exec" {
#   #   # Download source
#   #   command = "ssh local-data/vult_ssh_key root@${vultr_instance.manager1.main_ip}:~/.ssh/id_rsa"
#   # }
# }

# resource "github_repository_deploy_key" "example" {
#   repository = "example-repo"
#   title      = "Vultr Deploy Key"
#   key        = file("local-data/vult_ssh_key.pub")
# }


resource "null_resource" "git_clone" {
  # depends_on = [github_repository_deploy_key.example]

  connection {
    type     = "ssh"
    user     = "root"
    password = vultr_instance.manager1.default_password
    host     = vultr_instance.manager1.main_ip
    agent = false
  }

  provisioner "remote-exec" {
    inline = [
      # Add the GitHub.com host key to the known_hosts file temporarily
      # "ssh-keyscan github.com >> /tmp/known_hosts",
      # "chmod 644 /tmp/known_hosts",
      # Use the temporary known_hosts file during the git clone command
      "GIT_SSH_COMMAND='ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/tmp/known_hosts' git clone git@github.com:AnhtuanUit/example-repo.git",
      # Remove the temporary known_hosts file after the git clone
      # "rm /tmp/known_hosts",
    ]
  }
}

# resource "null_resource" "git_clone1" {
#   # depends_on = [github_repository_deploy_key.example]

#   connection {
#     type     = "ssh"
#     user     = "root"
#     password = vultr_instance.manager1.default_password
#     host     = vultr_instance.manager1.main_ip
#     agent = false
#   }

#   provisioner "remote-exec" {
#     inline = [
#       # Use the temporary known_hosts file during the git clone command
#       "git clone git@github.com:AnhtuanUit/example-repo.git example-repo-test",
#       # Remove the temporary known_hosts file after the git clone
#       # "rm /tmp/known_hosts",
#     ]
#   }
# }

resource "null_resource" "git_clone3" {
  depends_on = [null_resource.git_clone]

  connection {
    type     = "ssh"
    user     = "root"
    password = vultr_instance.manager1.default_password
    host     = vultr_instance.manager1.main_ip
    agent = false
  }

  provisioner "remote-exec" {
    inline = [
      # Use the temporary known_hosts file during the git clone command
      "cd example-repo",
      "GIT_SSH_COMMAND='ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/tmp/known_hosts' git pull",
      # Remove the temporary known_hosts file after the git clone
      # "rm /tmp/known_hosts",
    ]
  }
}