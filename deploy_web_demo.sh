#!/bin/bash

# Mauritania Edu - Web Demo Build & Deploy Script
# This script builds Flutter web and deploys to Firebase Hosting

set -e  # Exit on error

echo "🚀 Mauritania Edu - Web Demo Deployment"
echo "========================================"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Step 1: Check Flutter
echo "${BLUE}📱 Checking Flutter installation...${NC}"
if ! command -v flutter &> /dev/null; then
    echo "${RED}❌ Flutter not found. Please install Flutter first.${NC}"
    exit 1
fi
flutter --version
echo ""

# Step 2: Check Firebase CLI
echo "${BLUE}🔥 Checking Firebase CLI...${NC}"
if ! command -v firebase &> /dev/null; then
    echo "${RED}❌ Firebase CLI not found.${NC}"
    echo "Install with: npm install -g firebase-tools"
    exit 1
fi
firebase --version
echo ""

# Step 3: Clean previous builds
echo "${BLUE}🧹 Cleaning previous builds...${NC}"
flutter clean
echo "${GREEN}✅ Cleaned${NC}"
echo ""

# Step 4: Get dependencies
echo "${BLUE}📦 Getting Flutter dependencies...${NC}"
flutter pub get
echo "${GREEN}✅ Dependencies installed${NC}"
echo ""

# Step 5: Build Flutter Web
echo "${BLUE}🔨 Building Flutter Web (Release mode)...${NC}"
flutter build web --release
echo "${GREEN}✅ Web build complete!${NC}"
echo ""

# Step 6: Check if Firebase is initialized
if [ ! -f ".firebaserc" ]; then
    echo "${RED}⚠️  Firebase not initialized${NC}"
    echo "Run: firebase init hosting"
    echo "Then run this script again."
    exit 1
fi

# Step 7: Deploy to Firebase Hosting
echo "${BLUE}🚀 Deploying to Firebase Hosting...${NC}"
firebase deploy --only hosting

echo ""
echo "${GREEN}✅ Deployment Complete!${NC}"
echo ""
echo "🎉 Your demo is live!"
echo ""
echo "📱 View your app at:"
echo "   https://mauritania-edu-demo.web.app"
echo "   or check your Firebase console for the URL"
echo ""
echo "📖 See WEB_DEMO_DEPLOY.md for testing guide"
echo ""
