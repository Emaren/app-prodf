#!/bin/bash

### === CONFIG ===
VPS_USER=root
VPS_HOST=157.180.114.124
VPS_API_DIR=/var/www/api-prodf
VPS_PWA_DIR=/var/www/app_prodf/build/web

### === 1. Push local changes to Git ===
echo "📤 Pushing backend to Git..."
cd ~/projects/api-prodf || exit
git add .
git commit -m "🚀 Deploy wallet link + API_BASE fix" || true
git push origin main

### === 2. Build Flutter Web ===
echo "🛠️ Building Flutter frontend..."
cd ~/projects/app_prodf || exit
flutter build web --dart-define=API_BASE=https://aoe2hdbets.com/api

### === 3. Deploy to VPS ===
echo "🔐 SSH into VPS and restart backend..."
ssh $VPS_USER@$VPS_HOST << EOF
cd $VPS_API_DIR
git pull origin main
export ENV=production
export \$(cat .env.prod | xargs)
pm2 delete api-prodf || true
pm2 start ecosystem.config.js
pm2 save
EOF

### === 4. SCP Flutter frontend ===
echo "📦 Copying frontend to VPS..."
scp -r ~/projects/app_prodf/build/web/* $VPS_USER@$VPS_HOST:$VPS_PWA_DIR

echo "✅ Deployment complete!"

