// =============================================================================
// app.js - Application Express simple
// TP DevOps UCAD - Application de test pour le pipeline CI/CD
// =============================================================================

const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

// Route principale - répond "pong" comme demandé dans le TP
app.get('/ping', (req, res) => {
  res.json({ message: 'pong', timestamp: new Date().toISOString() });
});

// Route d'accueil
app.get('/', (req, res) => {
  res.json({
    app: 'TP DevOps UCAD',
    status: 'running',
    version: '1.0.0'
  });
});

// Démarrer le serveur seulement si ce fichier est exécuté directement
// (pas lors des tests)
if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Serveur démarré sur le port ${PORT}`);
    console.log(`Testez : http://localhost:${PORT}/ping`);
  });
}

module.exports = app; // Exporter pour les tests
