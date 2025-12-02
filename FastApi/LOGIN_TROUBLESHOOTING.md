# 🔐 Login Troubleshooting Guide

## Current Status

✅ **User exists**: pauln (ID: 1)
✅ **Password hash is correct**: Verified
✅ **Role is correct**: instructor
✅ **User is active**: True
❌ **Login still fails**: "Invalid credentials"

## What We've Done

1. ✅ Verified user exists in database
2. ✅ Reset password hash in Supabase
3. ✅ Verified password hash matches "pauln123"
4. ✅ Confirmed role and active status are correct

## Next Steps to Debug

### Step 1: Check Render Logs

1. Go to [Render Dashboard](https://dashboard.render.com/)
2. Click on `smart-license-api` service
3. Click **"Logs"** tab
4. Try logging in from Flutter app
5. Look for error messages in the logs

**What to look for:**
- "Login Error:" messages
- Password verification errors
- Database connection issues

### Step 2: Test Login Directly

Test the login endpoint with curl:

```bash
curl -X POST https://smart-license-api-9otw.onrender.com/login \
  -H "Content-Type: application/json" \
  -d '{"username": "pauln", "password": "pauln123", "role": "instructor"}'
```

### Step 3: Check for Whitespace Issues

The password might have hidden whitespace. Try:

```python
# In Flutter app, make sure to trim:
username = username.trim();
password = password.trim();
```

### Step 4: Verify Database Connection

The Render server might be connecting to a different database. Check:
- Render environment variable `DATABASE_URL` matches your Supabase connection string
- Supabase project is active (not paused)

### Step 5: Check Password Hash in Supabase

1. Go to Supabase Dashboard → Table Editor
2. Open `users` table
3. Find user with username `pauln`
4. Check the `password` column
5. It should start with `$2b$12$...`

## Quick Fix: Reset Password via Supabase SQL

1. **Go to Supabase SQL Editor**
2. **Run this query:**

```sql
-- Generate a fresh password hash for pauln123
UPDATE users 
SET password = '$2b$12$sxZ27gvs5LkSe8ORZynpZudn5FH0dfgqOEC/vzYmKzXilM1T2wB/2'
WHERE username = 'pauln';

-- Verify
SELECT id, username, email, role, is_active, 
       SUBSTRING(password, 1, 30) as password_hash_preview
FROM users 
WHERE username = 'pauln';
```

3. **Wait 10 seconds** for changes to propagate
4. **Try logging in again**

## Alternative: Create New User

If the issue persists, create a fresh user:

```sql
-- Delete old user (if needed)
DELETE FROM user_profiles WHERE user_id = (SELECT id FROM users WHERE username = 'pauln');
DELETE FROM instructor_profile WHERE user_id = (SELECT id FROM users WHERE username = 'pauln');
DELETE FROM users WHERE username = 'pauln';

-- Then run setup_database_complete.py again
```

## Most Common Issues

1. **Password hash mismatch** - Fixed by resetting password
2. **Database connection issue** - Check DATABASE_URL in Render
3. **User inactive** - Check is_active field
4. **Wrong role** - Must be instructor, admin, or super_admin
5. **Whitespace in password** - Make sure to trim in Flutter app

## Test Credentials

- **Username**: `pauln`
- **Password**: `pauln123`
- **Role**: `instructor`

## Still Not Working?

1. Check Render logs for detailed error messages
2. Verify DATABASE_URL in Render matches Supabase
3. Try creating a completely new user with different username
4. Check if there are multiple users with same username

