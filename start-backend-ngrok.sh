#!/bin/bash

# 🌐 Script de démarrage Backend + Ngrok
# Démarre le backend Node.js et l'expose sur internet via Ngrok

echo "🌐 =========================================="
echo "   Démarrage Backend + Ngrok"
echo "=========================================="
echo ""

# Vérifier que Node.js est installé
if ! command -v node &> /dev/null
then
    echo "❌ Node.js n'est pas installé"
    echo "   Installe Node.js depuis: https://nodejs.org"
    exit 1
fi

# Vérifier que Ngrok est installé
if ! command -v ngrok &> /dev/null
then
    echo "❌ Ngrok n'est pas installé"
    echo ""
    echo "📥 Installation de Ngrok :"
    echo "   1. Va sur: https://ngrok.com/download"
    echo "   2. Télécharge et installe pour ton OS"
    echo "   3. Crée un compte gratuit sur ngrok.com"
    echo "   4. Copie ton authtoken depuis: https://dashboard.ngrok.com/get-started/your-authtoken"
    echo "   5. Exécute: ngrok config add-authtoken TON_TOKEN"
    echo ""
    exit 1
fi

echo "✅ Node.js détecté: $(node --version)"
echo "✅ Ngrok détecté"
echo ""

# Aller dans le dossier backend
cd backend

echo "📦 Vérification des dépendances..."
if [ ! -d "node_modules" ]; then
    echo "📥 Installation des dépendances npm..."
    npm install
fi
echo "✅ Dépendances OK"
echo ""

# Vérifier que Docker est démarré (pour PostgreSQL)
echo "🐳 Vérification Docker..."
if ! docker ps &> /dev/null
then
    echo "❌ Docker n'est pas démarré"
    echo "   Lance Docker Desktop puis réexécute ce script"
    exit 1
fi
echo "✅ Docker actif"
echo ""

# Démarrer les containers Docker si pas démarrés
echo "🚀 Démarrage des services Docker (PostgreSQL + MongoDB)..."
docker-compose up -d
echo "✅ Services Docker démarrés"
echo ""

# Attendre que PostgreSQL soit prêt
echo "⏳ Attente démarrage PostgreSQL (5 secondes)..."
sleep 5
echo ""

# Démarrer le backend en arrière-plan
echo "🚀 Démarrage du backend Node.js..."
npm start &
BACKEND_PID=$!
echo "✅ Backend démarré (PID: $BACKEND_PID)"
echo ""

# Attendre que le backend soit prêt
echo "⏳ Attente démarrage backend (3 secondes)..."
sleep 3
echo ""

# Démarrer Ngrok
echo "🌐 Démarrage Ngrok..."
echo ""
echo "⚡ ATTENTION: Garde cette fenêtre OUVERTE pendant les tests !"
echo ""
ngrok http 3000

# Quand Ngrok est fermé, arrêter le backend
echo ""
echo "🛑 Arrêt du backend..."
kill $BACKEND_PID
echo "✅ Backend arrêté"
