# TP DevOps - Automatisation UCAD
**M1 RETEL - Département Informatique - FST/UCAD 2025-2026**

---

## Structure du projet

```
tp-devops/
├── auto_deploy.sh              # Partie 1 : Script Bash d'automatisation
├── .github/
│   └── workflows/
│       └── ci.yml              # Partie 2 : Pipeline GitHub Actions
├── main.tf                     # Partie 3 : Infrastructure Terraform
├── app.js                      # Application Express (API simple)
├── test.js                     # Tests unitaires
├── package.json                # Configuration npm
├── Dockerfile                  # Image Docker
└── README.md                   # Ce fichier
```

---

## Partie 1 : Script Bash (`auto_deploy.sh`)

### Ce que fait le script
1. Vérifie que `git`, `node` et `npm` sont installés
2. Clone ou met à jour le dépôt GitHub
3. Installe les dépendances npm
4. Lance les tests unitaires
5. Démarre l'application **en arrière-plan** et sauvegarde le PID

### Comment l'exécuter

```bash
# Rendre le script exécutable (une seule fois)
chmod +x auto_deploy.sh

# Exécuter avec l'URL du dépôt en paramètre
./auto_deploy.sh https://github.com/votre-nom/votre-app.git

# Ou sans paramètre (utilise l'URL par défaut)
./auto_deploy.sh
```

### Arrêter l'application

```bash
# Lire le PID sauvegardé et arrêter le processus
kill $(cat app.pid)
```

### Consulter les logs

```bash
# Un fichier log horodaté est créé à chaque exécution
cat deploy_YYYYMMDD_HHMMSS.log
```

---

## Partie 2 : Pipeline GitHub Actions (`.github/workflows/ci.yml`)

### Ce que fait le pipeline
- **Job 1 - build-and-test** : S'exécute à chaque push/PR sur `main`
  - Installe Node.js 18
  - Installe les dépendances
  - Lance les tests (arrêt si échec)
  - Build l'application
- **Job 2 - docker-build-push** : S'exécute seulement si les tests passent
  - Construit l'image Docker
  - La pousse sur Docker Hub
- **Job 3 - deploy-ssh** : Déploiement automatique sur serveur distant

### Configuration requise dans GitHub

Aller dans **Settings → Secrets and variables → Actions** et ajouter :

| Secret | Description |
|--------|-------------|
| `DOCKER_USERNAME` | Votre identifiant Docker Hub |
| `DOCKER_PASSWORD` | Votre mot de passe / token Docker Hub |
| `SSH_HOST` | IP ou domaine du serveur de déploiement |
| `SSH_USER` | Utilisateur SSH (ex: `ubuntu`) |
| `SSH_PRIVATE_KEY` | Clé SSH privée (contenu du fichier `~/.ssh/id_rsa`) |

### Comment activer le pipeline

```bash
# 1. Créer un dépôt GitHub et y pousser le projet
git init
git add .
git commit -m "Initial commit - TP DevOps"
git remote add origin https://github.com/VOTRE-NOM/tp-devops.git
git push -u origin main

# Le pipeline se déclenche automatiquement !
```

---

## Partie 3 : Terraform (`main.tf`)

### Ce que fait le fichier Terraform
- Crée un groupe de sécurité AWS (ports 80 et 22 ouverts)
- Lance une instance EC2 `t2.micro` (gratuite)
- Installe automatiquement Nginx au démarrage
- Affiche l'IP publique du serveur

### Commandes Terraform

```bash
# 1. Initialiser Terraform (télécharge les plugins AWS)
terraform init

# 2. Voir ce qui va être créé (sans rien changer)
terraform plan

# 3. Créer l'infrastructure
terraform apply -auto-approve

# 4. Détruire l'infrastructure (éviter les coûts)
terraform destroy
```

### Précautions importantes avec `.tfstate`

> ⚠️ Le fichier `terraform.tfstate` contient l'état de votre infrastructure.
> - **Ne jamais le committer sur GitHub** (ajouter au `.gitignore`)
> - En équipe, utiliser un backend distant (S3, Terraform Cloud)
> - Ne jamais le modifier manuellement

---

## Réponses aux questions du TP

### Partie 1 - Questions

**Q1 : Script avec URL en paramètre**
→ Voir `auto_deploy.sh` lignes 60-68 : `REPO_URL="$1"` si un argument est passé.

**Q2 : Fonction de log avec horodatage**
→ Voir fonction `log_message()` lignes 35-53 : affiche `[DATE HEURE] [NIVEAU] message`.

**Q3 : Démarrage en arrière-plan avec PID**
→ Voir lignes 130-140 : `npm start &` + `APP_PID=$!` + `save_pid()`.

### Partie 3 - Questions de réflexion

**Avantages de l'IaC vs configuration manuelle :**
- Reproductibilité : même environnement à chaque fois
- Versionnement : l'infrastructure est du code dans Git
- Rapidité : créer 10 serveurs identiques en une commande
- Documentation : le code décrit l'infrastructure

**Intégrer Terraform dans CI/CD :**
- Ajouter un job `terraform apply` dans le pipeline
- Utiliser des environnements séparés (dev/staging/prod)
- Conditionner le déploiement infra à la validation manuelle

**Précautions avec `.tfstate` :**
- Ne pas committer dans Git (données sensibles)
- Utiliser un backend distant partagé (S3 + DynamoDB pour le lock)
- Sauvegarder régulièrement

---

## Tester l'application localement

```bash
# Installer les dépendances
npm install

# Lancer les tests
npm test

# Démarrer l'application
npm start

# Tester l'API
curl http://localhost:3000/ping
# Réponse attendue : {"message":"pong","timestamp":"..."}
```
