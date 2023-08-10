
```markdown
## Quick Start

### Install Terraform

```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common wget -O- https://apt.releases.hashicorp.com/gpg |
gpg --dearmor |
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg gpg --no-default-keyring
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg
--fingerprint echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg]
https://apt.releases.hashicorp.com $(lsb_release -cs) main" |
sudo tee /etc/apt/sources.list.d/hashicorp.list sudo apt update sudo apt-get install terraform
```

### Clone Source Code

```bash
git clone https://github.com/AnhtuanUit/terraform-cloud-swarm.git
```

### Navigate to Source Code Folder

```bash
cd terraform-cloud-swarm
```

### Install Dependencies

```bash
terraform init
```

### Initialize SSH Key

```bash
chmod +x scripts/init-ssh-key.sh
./scripts/init-ssh-key.sh
```

### Deploy using Terraform

```bash
terraform apply
```
```