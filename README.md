Quick start
1. Install terraform
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt-get install terraform
2. Clone source code
git clone https://github.com/AnhtuanUit/terraform-cloud-swarm.git
3. CD to source code folder
cd terraform-cloud-swarm
4. Install dependencies
terraform init
5. Init ssh-key by .sh file
chmod +x scripts/init-ssh-key.sh
./scripts/init-ssh-key.sh
6. Deploy by terraform
terraform apply