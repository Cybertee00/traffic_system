# 🔐 Reset Instructor Password - Quick Fix

The login is failing because the password hash might not match. Here's how to fix it:

## Option 1: Use Supabase SQL Editor (Easiest)

1. **Go to Supabase Dashboard**
   - Visit [https://app.supabase.com](https://app.supabase.com)
   - Select your project
   - Click **"SQL Editor"** in the left sidebar

2. **Run this SQL query:**
   ```sql
   UPDATE users 
   SET password = '$2b$12$cbMJlaBHZOHeRnsWsbnquOsEv0Rh9d7K0jvKLhc9GaKkPoqd1Wu.u'
   WHERE username = 'pauln';
   ```

   This sets the password to `pauln123` (bcrypt hash).

3. **Verify:**
   ```sql
   SELECT id, username, email, role, is_active FROM users WHERE username = 'pauln';
   ```

4. **Try logging in again** with:
   - Username: `pauln`
   - Password: `pauln123`

## Option 2: Delete and Recreate User via API

Run this Python script:

```python
import requests

BASE_URL = "https://smart-license-api-9otw.onrender.com"

# First, try to get user ID
response = requests.get(f"{BASE_URL}/users/pauln")
if response.status_code == 200:
    user_id = response.json()['id']
    
    # Delete user profile first (if exists)
    requests.delete(f"{BASE_URL}/user-profiles/{user_id}")
    requests.delete(f"{BASE_URL}/instructor-profiles/{user_id}")
    
    # Delete user
    requests.delete(f"{BASE_URL}/users/id/{user_id}")

# Create new user
user_data = {
    "username": "pauln",
    "password": "pauln123",
    "email": "paul.ntsinyi@example.com",
    "role": "instructor",
    "is_active": True
}
response = requests.post(f"{BASE_URL}/users/", json=user_data)
print(response.json())
```

## Option 3: Check Render Logs

1. Go to [Render Dashboard](https://dashboard.render.com/)
2. Click on your `smart-license-api` service
3. Click **"Logs"** tab
4. Try logging in from Flutter app
5. Check the logs for error messages

## Quick Test

Test the login directly:

```bash
curl -X POST https://smart-license-api-9otw.onrender.com/login \
  -H "Content-Type: application/json" \
  -d '{"username": "pauln", "password": "pauln123", "role": "instructor"}'
```

## Most Likely Issue

The password hash in Supabase might be different from what we expect. The SQL update in Option 1 will fix it immediately.

