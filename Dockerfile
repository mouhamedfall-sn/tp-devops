# =============================================================================
# Dockerfile - TP DevOps UCAD
# Crée une image Docker pour l'application Express
# =============================================================================

# Image de base : Node.js version 18 légère (Alpine Linux)
FROM node:18-alpine

# Répertoire de travail dans le conteneur
WORKDIR /app

# Copier package.json en premier (optimise le cache Docker)
COPY package*.json ./

# Installer uniquement les dépendances de production
RUN npm install --production

# Copier le reste du code source
COPY . .

# Exposer le port de l'application
EXPOSE 3000

# Variable d'environnement
ENV NODE_ENV=production

# Commande de démarrage
CMD ["node", "app.js"]
