import firebase_admin
from firebase_admin import credentials, auth

# 🔐 Replace this path with your actual service account key
cred = credentials.Certificate('/var/www/api-prod/secrets/serviceAccountKey.json')
firebase_admin.initialize_app(cred)

email = 'tonyblum@me.com'  # Change this
try:
    user = auth.get_user_by_email(email)
    print(f"✅ Found user:\nUID: {user.uid}\nEmail: {user.email}\nDisabled: {user.disabled}")
except auth.UserNotFoundError:
    print("❌ User not found.")
