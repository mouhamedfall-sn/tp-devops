## Structure du projet
## Partie 1 : Script Bash

```bash
chmod +x auto_deploy.sh
./auto_deploy.sh https://github.com/mouhamedfall-sn/tp-devops.git

Fonctionnalités :
- Vérifie git, node, npm
- Clone ou met à jour le dépôt
- Installe les dépendances
- Lance les tests (arrêt si échec)
- Démarre l'app en arrière-plan + sauvegarde le PID
- Génère un fichier log horodaté

Arrêter l'application :
```bash
kill $(cat app.pid)
```

## Partie 2 : Pipeline GitHub Actions

Le pipeline se déclenche automatiquement à chaque push sur main.
Il effectue : Checkout → Node.js 18 → npm install → npm test → build

Résultat : https://github.com/mouhamedfall-sn/tp-devops/actions
## Partie 3 : Terraform

```bash
terraform init
terraform plan
terraform apply -auto-approve
terraform destroy
```

Crée une instance EC2 t2.micro sur AWS avec Nginx installé automatiquement.

## Réponses aux questions

### Partie 1
Q1 - URL en paramètre : REPO_URL="$1" ligne 62
Q2 - Log horodaté : fonction log_message() avec $(date '+%Y-%m-%d %H:%M:%S')
Q3 - Arrière-plan + PID : npm start & puis APP_PID=$! sauvegardé dans app.pid

### Partie 3
Avantages IaC vs manuel :
- Reproductibilité, versionnement Git, rapidité, documentation vivante

Terraform dans CI/CD :
- Ajouter job terraform apply, environnements séparés, approbation manuelle

Précautions .tfstate :
- Ne jamais committer (données sensibles), backend distant S3, ne pas modifier manuellement
## Test local
```bash
npm install
npm test
npm start
# Tester : http://localhost:3000/ping
```
