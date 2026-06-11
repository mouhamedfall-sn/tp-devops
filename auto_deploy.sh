#!/bin/bash

# =============================================================================
# auto_deploy.sh - Script d'automatisation du déploiement
# Auteur : Étudiant M1 RETEL - UCAD/DMI/FST
# Description : Automatise la vérification, le clonage, l'installation,
#               les tests et le démarrage d'une application Node.js
# =============================================================================

# --- Couleurs pour l'affichage ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color (reset)

# --- Fichier de log ---
LOG_FILE="deploy_$(date +%Y%m%d_%H%M%S).log"

# =============================================================================
# FONCTION : log_message
# Description : Affiche un message avec horodatage et l'écrit dans le fichier log
# Paramètres : $1 = niveau (INFO/SUCCESS/WARNING/ERROR), $2 = message
# =============================================================================
log_message() {
    local LEVEL="$1"
    local MESSAGE="$2"
    local TIMESTAMP
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    # Formater le message avec timestamp
    local LOG_ENTRY="[$TIMESTAMP] [$LEVEL] $MESSAGE"

    # Écrire dans le fichier log
    echo "$LOG_ENTRY" >> "$LOG_FILE"

    # Afficher en couleur selon le niveau
    case "$LEVEL" in
        "INFO")    echo -e "${BLUE}${LOG_ENTRY}${NC}" ;;
        "SUCCESS") echo -e "${GREEN}${LOG_ENTRY}${NC}" ;;
        "WARNING") echo -e "${YELLOW}${LOG_ENTRY}${NC}" ;;
        "ERROR")   echo -e "${RED}${LOG_ENTRY}${NC}" ;;
        *)         echo "$LOG_ENTRY" ;;
    esac
}

# =============================================================================
# FONCTION : check_command
# Description : Vérifie qu'une commande est disponible sur le système
# Paramètres : $1 = nom de la commande
# =============================================================================
check_command() {
    local CMD="$1"
    if command -v "$CMD" > /dev/null 2>&1; then
        log_message "SUCCESS" "$CMD est installé : $(command -v $CMD)"
    else
        log_message "ERROR" "$CMD est requis mais non installé. Abandon."
        exit 1
    fi
}

# =============================================================================
# FONCTION : save_pid
# Description : Sauvegarde le PID d'un processus en arrière-plan dans un fichier
# Paramètres : $1 = PID, $2 = nom du fichier PID
# =============================================================================
save_pid() {
    local PID="$1"
    local PID_FILE="$2"
    echo "$PID" > "$PID_FILE"
    log_message "INFO" "Application démarrée en arrière-plan. PID=$PID sauvegardé dans $PID_FILE"
    log_message "INFO" "Pour arrêter l'application : kill \$(cat $PID_FILE)"
}

# =============================================================================
# DÉBUT DU SCRIPT PRINCIPAL
# =============================================================================

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}=   DÉPLOIEMENT AUTOMATIQUE - DEVOPS TP   =${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""

log_message "INFO" "Démarrage du script de déploiement automatique"
log_message "INFO" "Fichier de log : $LOG_FILE"
echo ""

# --- Récupération de l'URL du dépôt en paramètre (Question 1) ---
# L'URL peut être passée en argument : ./auto_deploy.sh https://github.com/...
if [ -n "$1" ]; then
    REPO_URL="$1"
    log_message "INFO" "URL du dépôt fournie en paramètre : $REPO_URL"
else
    # URL par défaut si aucun paramètre fourni
    REPO_URL="https://github.com/expressjs/express.git"
    log_message "WARNING" "Aucune URL fournie en paramètre. Utilisation de l'URL par défaut : $REPO_URL"
    log_message "INFO" "Usage : $0 <url_du_depot>"
fi

PROJECT_DIR="mon_app"

echo ""
log_message "INFO" "--- ÉTAPE 1 : Vérification des dépendances ---"

# Vérification de git, node et npm
check_command "git"
check_command "node"
check_command "npm"

log_message "SUCCESS" "Toutes les dépendances sont présentes."
echo ""

# --- ÉTAPE 2 : Clonage ou mise à jour du dépôt ---
log_message "INFO" "--- ÉTAPE 2 : Clonage / Mise à jour du dépôt ---"

if [ -d "$PROJECT_DIR" ]; then
    log_message "WARNING" "Le répertoire '$PROJECT_DIR' existe déjà. Mise à jour en cours..."
    cd "$PROJECT_DIR" || { log_message "ERROR" "Impossible d'accéder à $PROJECT_DIR"; exit 1; }
    git pull
    if [ $? -eq 0 ]; then
        log_message "SUCCESS" "Mise à jour git réussie."
    else
        log_message "ERROR" "Échec de la mise à jour git."
        exit 1
    fi
else
    log_message "INFO" "Clonage du dépôt : $REPO_URL"
    git clone "$REPO_URL" "$PROJECT_DIR"
    if [ $? -eq 0 ]; then
        log_message "SUCCESS" "Clonage réussi dans le dossier '$PROJECT_DIR'."
        cd "$PROJECT_DIR" || { log_message "ERROR" "Impossible d'accéder à $PROJECT_DIR"; exit 1; }
    else
        log_message "ERROR" "Échec du clonage du dépôt."
        exit 1
    fi
fi
echo ""

# --- ÉTAPE 3 : Installation des dépendances ---
log_message "INFO" "--- ÉTAPE 3 : Installation des dépendances npm ---"
npm install
if [ $? -eq 0 ]; then
    log_message "SUCCESS" "Installation des dépendances réussie."
else
    log_message "ERROR" "Échec de l'installation des dépendances."
    exit 1
fi
echo ""

# --- ÉTAPE 4 : Lancement des tests ---
log_message "INFO" "--- ÉTAPE 4 : Lancement des tests unitaires ---"
npm test
TEST_RESULT=$?

if [ $TEST_RESULT -eq 0 ]; then
    log_message "SUCCESS" "Tous les tests sont passés avec succès !"
    echo ""

    # --- ÉTAPE 5 : Démarrage de l'application en arrière-plan (Question 3) ---
    log_message "INFO" "--- ÉTAPE 5 : Démarrage de l'application en arrière-plan ---"
    PID_FILE="../app.pid"

    # Démarrer npm start en arrière-plan et capturer le PID
    npm start &
    APP_PID=$!

    # Petite pause pour vérifier que l'app démarre bien
    sleep 2

    if kill -0 "$APP_PID" 2>/dev/null; then
        save_pid "$APP_PID" "$PID_FILE"
        log_message "SUCCESS" "Application démarrée avec succès !"
        log_message "INFO" "Pour vérifier : ps aux | grep node"
        log_message "INFO" "Pour arrêter : kill \$(cat $PID_FILE)"
    else
        log_message "ERROR" "L'application a échoué à démarrer."
        exit 1
    fi

else
    log_message "ERROR" "Échec des tests. Déploiement interrompu."
    log_message "ERROR" "Corrigez les tests avant de redéployer."
    exit 1
fi

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}=       DÉPLOIEMENT TERMINÉ AVEC SUCCÈS   =${NC}"
echo -e "${GREEN}============================================${NC}"
log_message "SUCCESS" "Script de déploiement terminé. Consultez $LOG_FILE pour les détails."
