# =============================================================================
# main.tf - Infrastructure as Code avec Terraform
# TP DevOps UCAD - Partie 3
# Description : Crée automatiquement une instance EC2 sur AWS avec Nginx
# =============================================================================

# --- Fournisseur cloud : AWS, région US East ---
provider "aws" {
  region = "us-east-1"
}

# --- Groupe de sécurité : autorise HTTP (80) et SSH (22) ---
resource "aws_security_group" "web_sg" {
  name        = "devops-web-sg"
  description = "Autorise HTTP et SSH"

  # Autoriser le trafic HTTP entrant (port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Autoriser SSH (port 22) pour la gestion
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Autoriser tout le trafic sortant
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DevOps-SG"
  }
}

# --- Instance EC2 : serveur web avec Nginx ---
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"  # Ubuntu 20.04 LTS (us-east-1)
  instance_type = "t2.micro"               # Éligible au free tier AWS

  # Associer le groupe de sécurité
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # Script exécuté au premier démarrage de la VM
  user_data = <<-EOF
    #!/bin/bash
    apt-get update -y
    apt-get install -y nginx nodejs npm
    systemctl start nginx
    systemctl enable nginx
    echo "<h1>Déploiement DevOps UCAD - TP Terraform</h1>" > /var/www/html/index.html
  EOF

  tags = {
    Name        = "DevOps-Server"
    Environment = "TP"
    Cours       = "UCAD-M1-RETEL"
  }
}

# --- Outputs : affiche l'IP publique après création ---
output "public_ip" {
  description = "Adresse IP publique du serveur"
  value       = aws_instance.web.public_ip
}

output "public_dns" {
  description = "DNS public du serveur"
  value       = aws_instance.web.public_dns
}
