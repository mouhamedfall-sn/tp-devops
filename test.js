// =============================================================================
// test.js - Tests unitaires simples (sans librairie externe)
// TP DevOps UCAD
// =============================================================================

const http = require('http');

// Démarrer le serveur sur un port de test
const app = require('./app');
const server = app.listen(3001);

let passed = 0;
let failed = 0;

// Fonction utilitaire pour faire une requête HTTP
function request(path, callback) {
  http.get(`http://localhost:3001${path}`, (res) => {
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => callback(res.statusCode, JSON.parse(data)));
  });
}

// Fonction d'assertion
function assert(condition, testName) {
  if (condition) {
    console.log(`  ✅ PASS : ${testName}`);
    passed++;
  } else {
    console.log(`  ❌ FAIL : ${testName}`);
    failed++;
  }
}

console.log('\n=== Lancement des tests unitaires ===\n');

// Test 1 : Route /ping répond 200
request('/ping', (status, body) => {
  assert(status === 200, 'GET /ping retourne status 200');
  assert(body.message === 'pong', 'GET /ping retourne { message: "pong" }');
  assert(typeof body.timestamp === 'string', 'GET /ping retourne un timestamp');

  // Test 2 : Route / répond 200
  request('/', (status2, body2) => {
    assert(status2 === 200, 'GET / retourne status 200');
    assert(body2.status === 'running', 'GET / retourne { status: "running" }');

    // Résultats finaux
    console.log(`\n=== Résultats : ${passed} passés, ${failed} échoués ===\n`);
    server.close();

    if (failed > 0) {
      process.exit(1); // Code de sortie 1 = échec (arrête le pipeline CI)
    } else {
      process.exit(0); // Code de sortie 0 = succès
    }
  });
});
