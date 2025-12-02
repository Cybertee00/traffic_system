# 🔧 Quick Fix: Connect to Supabase Instead of Localhost

## The Problem
The script was connecting to `localhost:5432` (your local PostgreSQL) instead of Supabase.

## The Solution

You have two options:

### Option 1: Use config.env file (Recommended)

I've already updated `config.env` with your Supabase connection string. Just verify it's correct:

1. **Open `config.env` file** in the FastApi folder
2. **Check the DATABASE_URL line** - it should have your Supabase connection string
3. **If it's correct, you're done!** The script will automatically read it

### Option 2: Set Environment Variable in PowerShell

If you prefer to set it manually in PowerShell:

```powershell
# Set the Supabase connection string
$env:DATABASE_URL="postgresql://postgres.zivpoauevhefeeugdolq:0000@aws-1-eu-west-1.pooler.supabase.com:5432/postgres"
```

**⚠️ Important:** Keep the PowerShell window open! If you close it, you'll need to set it again.

## Verify Connection

Run the diagnostic script to verify you're connected to Supabase:

```powershell
python check_database.py
```

**You should see:**
- Connection String showing `aws-1-eu-west-1.pooler.supabase.com` (NOT localhost)
- Connected to PostgreSQL with Supabase details

## Run Setup Script

Once verified, run the setup:

```powershell
python setup_database_complete.py
```

## Get Your Supabase Connection String

If you need to get it again:

1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Select your project
3. Go to **Settings** → **Database**
4. Scroll to **"Connection string"**
5. Select **"Session"** mode (for setup script)
6. Copy the connection string
7. Replace the one in `config.env`

## Password URL-Encoding

If your password has special characters, encode them:
- `@` → `%40`
- `#` → `%23`
- `%` → `%25`

Example: Password `MyP@ss#123` becomes `MyP%40ss%23123`

