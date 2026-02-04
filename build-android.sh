#!/bin/bash

# 🚀 Script de Build APK Android - Sakinah App
# Ce script compile l'application en APK pour distribution test

echo "📱 =========================================="
echo "   Build APK Android - Sakinah App"
echo "=========================================="
echo ""

# Vérifier que Flutter est installé
if ! command -v flutter &> /dev/null
then
    echo "❌ Flutter n'est pas installé ou pas dans le PATH"
    echo "   Installe Flutter depuis: https://flutter.dev"
    exit 1
fi

echo "✅ Flutter détecté: $(flutter --version | head -n 1)"
echo ""

# Aller dans le dossier frontend
cd frontend

echo "📦 Étape 1/4 : Nettoyage du projet..."
flutter clean
echo "✅ Nettoyage terminé"
echo ""

echo "📥 Étape 2/4 : Téléchargement des dépendances..."
flutter pub get
echo "✅ Dépendances installées"
echo ""

echo "🔨 Étape 3/4 : Compilation de l'APK (Release Mode)..."
echo "   ⏳ Cela peut prendre 3-5 minutes..."
flutter build apk --release --target-platform android-arm64

if [ $? -eq 0 ]; then
    echo "✅ Compilation réussie !"
    echo ""
    
    echo "📲 Étape 4/4 : Copie de l'APK..."
    
    # Créer dossier releases si n'existe pas
    mkdir -p ../releases
    
    # Copier l'APK avec un nom clair
    DATE=$(date +"%Y%m%d_%H%M")
    cp build/app/outputs/flutter-apk/app-release.apk "../releases/Sakinah_v1.0_${DATE}.apk"
    
    echo "✅ APK copié !"
    echo ""
    echo "🎉 =========================================="
    echo "   BUILD TERMINÉ AVEC SUCCÈS !"
    echo "=========================================="
    echo ""
    echo "📂 Fichier créé :"
    echo "   releases/Sakinah_v1.0_${DATE}.apk"
    echo ""
    echo "📤 Tu peux maintenant partager ce fichier avec tes testeurs !"
    echo ""
    echo "📝 Taille du fichier :"
    ls -lh "../releases/Sakinah_v1.0_${DATE}.apk" | awk '{print "   " $5}'
    echo ""
else
    echo "❌ Erreur lors de la compilation"
    echo "   Vérifie les erreurs ci-dessus"
    exit 1
fi
