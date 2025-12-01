# 🖥️ Complete Local Setup Guide - Database Initialization

This guide will walk you through running `setup_database_complete.py` on your local machine step by step.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Step 1: Verify Python Installation](#step-1-verify-python-installation)
3. [Step 2: Get Supabase Connection String](#step-2-get-supabase-connection-string)
4. [Step 3: Navigate to FastApi Folder](#step-3-navigate-to-fastapi-folder)
5. [Step 4: Install Python Dependencies](#step-4-install-python-dependencies)
6. [Step 5: Set Environment Variable](#step-5-set-environment-variable)
7. [Step 6: Run the Setup Script](#step-6-run-the-setup-script)
8. [Step 7: Verify Results](#step-7-verify-results)
9. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before starting, ensure you have:

- ✅ **Python 3.11 or higher** installed
- ✅ **Supabase account** created
- ✅ **Supabase project** created with database
- ✅ **Connection string** from Supabase
- ✅ **Git** (to clone/pull the latest code)

---

## Step 1: Verify Python Installation

### Check Python Version

**Windows PowerShell:**
```powershell
python --version
```

**Windows CMD:**
```cmd
python --version
```

**Expected output:** `Python 3.11.x` or higher

### If Python is not installed:

1. Download from [python.org](https://www.python.org/downloads/)
2. During installation, check **"Add Python to PATH"**
3. Restart your terminal after installation

### Verify pip is available:

```powershell
pip --version
```

**Expected output:** `pip 23.x.x` or similar

---

## Step 2: Get Supabase Connection String

### 2.1 Access Supabase Dashboard

1. Go to [https://app.supabase.com](https://app.supabase.com)
2. Sign in to your account
3. Select your project (or create a new one if needed)

### 2.2 Get Connection String

1. In your Supabase project dashboard, click **"Settings"** (gear icon in left sidebar)
2. Click **"Database"** in the settings menu
3. Scroll down to **"Connection string"** section
4. Select **"Connection pooling"** mode (recommended for production)
5. Select **"Session"** mode (for this setup script)
6. Copy the connection string - it will look like:
   ```
   postgresql://postgres.[PROJECT_REF]:[YOUR_PASSWORD]@aws-0-[REGION].pooler.supabase.com:5432/postgres
   ```

### 2.3 URL-Encode Password (if needed)

If your password contains special characters, you need to URL-encode them:

| Character | Encoded |
|-----------|---------|
| `@` | `%40` |
| `#` | `%23` |
| `%` | `%25` |
| `/` | `%2F` |
| `:` | `%3A` |
| ` ` (space) | `%20` |

**Example:**
- Original password: `MyP@ss#123`
- URL-encoded: `MyP%40ss%23123`
- Full connection string: `postgresql://postgres.xxx:MyP%40ss%23123@aws-0-us-east-1.pooler.supabase.com:5432/postgres`

**💡 Tip:** Save your connection string in a text file temporarily for easy copy-paste.

---

## Step 3: Navigate to FastApi Folder

### Open Terminal/PowerShell

**Windows:**
- Press `Win + X` and select "Windows PowerShell" or "Terminal"
- Or search for "PowerShell" in Start menu

### Navigate to Project

```powershell
# Change to your project directory
cd "D:\Traffic Project\SMART_APP\FastApi"
```

**Verify you're in the right folder:**
```powershell
# List files to confirm
dir
# or
ls
```

**You should see:**
- `main.py`
- `db.py`
- `setup_database_complete.py`
- `requirements.txt`
- etc.

---

## Step 4: Install Python Dependencies

### 4.1 Create Virtual Environment (Recommended)

**Why?** Keeps your project dependencies isolated from other Python projects.

**Windows PowerShell:**
```powershell
# Create virtual environment
python -m venv venv

# Activate virtual environment
.\venv\Scripts\Activate.ps1
```

**If you get an execution policy error:**
```powershell
# Run this first, then try activating again
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\venv\Scripts\Activate.ps1
```

**Windows CMD:**
```cmd
python -m venv venv
venv\Scripts\activate.bat
```

**You should see `(venv)` in your prompt:**
```
(venv) PS D:\Traffic Project\SMART_APP\FastApi>
```

### 4.2 Install Dependencies

```powershell
pip install -r requirements.txt
```

**This will install:**
- fastapi
- uvicorn
- sqlalchemy
- psycopg (PostgreSQL driver)
- passlib (password hashing)
- python-dotenv
- etc.

**Expected output:**
```
Collecting fastapi==0.104.1
Collecting uvicorn[standard]==0.24.0
...
Successfully installed fastapi-0.104.1 uvicorn-0.24.0 ...
```

**Verify installation:**
```powershell
pip list
```

You should see all packages from `requirements.txt` listed.

---

## Step 5: Set Environment Variable

You need to set the `DATABASE_URL` environment variable so the script can connect to Supabase.

### Option A: Set for Current Session (Temporary)

**Windows PowerShell:**
```powershell
$env:DATABASE_URL="postgresql://postgres.YOUR_PROJECT_REF:YOUR_PASSWORD@aws-0-YOUR_REGION.pooler.supabase.com:5432/postgres"
```

**Windows CMD:**
```cmd
set DATABASE_URL=postgresql://postgres.YOUR_PROJECT_REF:YOUR_PASSWORD@aws-0-YOUR_REGION.pooler.supabase.com:5432/postgres
```

**Replace with your actual connection string from Step 2.**

**Example:**
```powershell
$env:DATABASE_URL="postgresql://postgres.zivpoauevhefeeugdolq:0000@aws-1-eu-west-1.pooler.supabase.com:5432/postgres"
```

**⚠️ Important:** 
- Keep the terminal window open (don't close it)
- The variable only lasts for this session
- If you open a new terminal, you'll need to set it again

### Option B: Create config.env File (Permanent)

1. **Create a file named `config.env` in the FastApi folder:**

   ```powershell
   # Create the file
   New-Item -Path "config.env" -ItemType File
   ```

2. **Open `config.env` in a text editor** (Notepad, VS Code, etc.)

3. **Add your connection string:**
   ```
   DATABASE_URL=postgresql://postgres.YOUR_PROJECT_REF:YOUR_PASSWORD@aws-0-YOUR_REGION.pooler.supabase.com:5432/postgres
   ```

4. **Save the file**

5. **The script will automatically read from `config.env`** (no need to set environment variable)

**⚠️ Security Note:** 
- `config.env` is in `.gitignore`, so it won't be committed to Git
- Don't share this file or commit it to GitHub
- Keep your password secure

---

## Step 6: Run the Setup Script

### 6.1 Verify Everything is Ready

**Check you're in the right directory:**
```powershell
pwd
# Should show: D:\Traffic Project\SMART_APP\FastApi
```

**Check the script exists:**
```powershell
dir setup_database_complete.py
# or
ls setup_database_complete.py
```

**Verify DATABASE_URL is set (if using environment variable):**
```powershell
echo $env:DATABASE_URL
# Should show your connection string
```

### 6.2 Run the Script

```powershell
python setup_database_complete.py
```

### 6.3 What to Expect

The script will show progress output:

```
============================================================
🚀 SMART LICENSE SYSTEM - COMPLETE DATABASE SETUP
============================================================
This script will:
  1. Initialize database tables and default data
  2. Create instructor: Paul Ntsinyi (username: pauln)
  3. Create learners with test bookings (3 per day until end of Feb)
============================================================

============================================================
📊 STEP 1: Initializing Database Tables
============================================================
Creating database tables...
✅ Database tables created successfully!

Inserting default stations...
  ✅ Added station: Main Station
  ✅ Added station: North Station
  ...

Inserting default security questions...
  ✅ Added question: What is the name of your first pet?
  ...

✅ Database initialization completed!

============================================================
👨‍🏫 STEP 2: Creating Instructor
============================================================
📝 Creating instructor user: pauln
✅ Created instructor user (ID: 2)
📝 Creating user profile...
✅ Created user profile
📝 Creating instructor profile (Station ID: 1)...
✅ Created instructor profile

============================================================
✅ INSTRUCTOR CREATED SUCCESSFULLY!
============================================================
   Username: pauln
   Password: pauln123
   Name: Paul Ntsinyi
   Email: paul.ntsinyi@smart.test
   Instructor Number: INF-001
   User ID: 2
============================================================

============================================================
👥 STEP 3: Creating Learners and Test Bookings
============================================================
📅 Date range: 2025-01-28 to 2025-02-28
📊 Total days: 32
👥 Total learners to create: 96
👨‍🏫 Instructor ID: 2
============================================================

📅 Creating learners for 2025-01-28...
✅ Created learner: John Smith (ID: 3) for 2025-01-28
✅ Created learner: Sarah Johnson (ID: 4) for 2025-01-28
✅ Created learner: Michael Williams (ID: 5) for 2025-01-28
✅ Completed 2025-01-28 - 3 learners created

📅 Creating learners for 2025-01-29...
...

============================================================
✅ SUCCESS! Created 96 learners across 32 days
📝 All learners have password: 'password123'
📧 Username format: learner.YYYYMMDD.N (e.g., learner.20250128.1)
============================================================

============================================================
🎉 DATABASE SETUP COMPLETE!
============================================================
✅ Instructor created: pauln
✅ Learners created: 96

📋 Login Credentials:
   Instructor Username: pauln
   Instructor Password: pauln123
   Learner Password (all): password123
============================================================
```

**⏱️ Expected time:** 1-3 minutes depending on your internet connection

---

## Step 7: Verify Results

### 7.1 Check Supabase Dashboard

1. **Go to Supabase Dashboard** → Your Project
2. **Click "Table Editor"** in the left sidebar
3. **Verify tables exist:**
   - `users` - Should have ~97 rows (1 instructor + 96 learners)
   - `user_profiles` - Should have ~97 rows
   - `instructor_profile` - Should have 1 row (Paul Ntsinyi)
   - `learner_profiles` - Should have 96 rows
   - `learner_test_bookings` - Should have 96 rows
   - `station` - Should have 5 rows
   - `security_questions` - Should have 6 rows

4. **Check instructor:**
   - Go to `users` table
   - Filter by username = `pauln`
   - Verify role = `instructor`

5. **Check learners:**
   - Go to `learner_test_bookings` table
   - Verify bookings are from Jan 28 to Feb 28
   - Verify 3 bookings per day

### 7.2 Test API Endpoints (Optional)

If your Render service is running, test the API:

**Get instructor:**
```powershell
curl https://your-render-url.onrender.com/instructor-profiles/
```

**Get learners for a date:**
```powershell
curl https://your-render-url.onrender.com/learner-test-bookings/pending/2025-01-28
```

**Get all stations:**
```powershell
curl https://your-render-url.onrender.com/stations/
```

---

## Troubleshooting

### Error: "ModuleNotFoundError: No module named 'xxx'"

**Solution:** Install dependencies
```powershell
pip install -r requirements.txt
```

### Error: "Failed to connect to database"

**Possible causes:**
1. **DATABASE_URL not set:**
   ```powershell
   # Check if it's set
   echo $env:DATABASE_URL
   
   # If empty, set it again
   $env:DATABASE_URL="your_connection_string"
   ```

2. **Wrong connection string:**
   - Verify you copied the entire string
   - Check password is URL-encoded if needed
   - Ensure you're using "Session" mode, not "Connection pooling" for this script

3. **Supabase project paused:**
   - Free tier projects pause after inactivity
   - Go to Supabase dashboard and wake up the project

4. **Network/firewall issues:**
   - Check your internet connection
   - Try pinging Supabase: `ping aws-0-us-east-1.pooler.supabase.com`

### Error: "password authentication failed"

**Solution:**
- Verify password is correct
- Check if password needs URL-encoding
- Try resetting database password in Supabase

### Error: "relation 'users' already exists"

**This is normal!** It means tables already exist. The script will:
- Skip creating existing tables
- Only add new data
- Safe to run multiple times

### Error: "Instructor already exists"

**This is normal!** The script checks for existing instructor and uses it. Safe to run again.

### Script runs but no data appears

**Check:**
1. Look for error messages in the output
2. Verify DATABASE_URL is correct
3. Check Supabase Table Editor (refresh the page)
4. Check script output for "✅" success messages

### Virtual Environment Issues

**If activation fails:**
```powershell
# Try this instead
python -m venv venv --clear
.\venv\Scripts\Activate.ps1
```

**If pip install fails in venv:**
```powershell
# Make sure venv is activated (you should see (venv) in prompt)
# Then upgrade pip
python -m pip install --upgrade pip
pip install -r requirements.txt
```

---

## Quick Reference Commands

**Complete setup in one go (copy-paste these):**

```powershell
# 1. Navigate to folder
cd "D:\Traffic Project\SMART_APP\FastApi"

# 2. Create and activate virtual environment
python -m venv venv
.\venv\Scripts\Activate.ps1

# 3. Install dependencies
pip install -r requirements.txt

# 4. Set database URL (replace with your actual connection string)
$env:DATABASE_URL="postgresql://postgres.YOUR_PROJECT_REF:YOUR_PASSWORD@aws-0-YOUR_REGION.pooler.supabase.com:5432/postgres"

# 5. Run setup script
python setup_database_complete.py
```

---

## What Gets Created

### Database Tables (8 tables)
- ✅ `users`
- ✅ `user_profiles`
- ✅ `instructor_profile`
- ✅ `learner_profiles`
- ✅ `learner_test_bookings`
- ✅ `station`
- ✅ `security_questions`
- ✅ `user_security_answers`

### Default Data
- ✅ 5 stations (Main, North, South, East, West)
- ✅ 6 security questions

### Instructor
- ✅ Username: `pauln`
- ✅ Password: `pauln123`
- ✅ Name: Paul Ntsinyi
- ✅ Instructor Number: INF-001

### Learners
- ✅ ~96 learners (3 per day × 32 days)
- ✅ Date range: Tomorrow to Feb 28, 2025
- ✅ All passwords: `password123`
- ✅ Username format: `learner.YYYYMMDD.N`

### Test Bookings
- ✅ 96 bookings (one per learner)
- ✅ All assigned to instructor Paul Ntsinyi
- ✅ All at Main Station
- ✅ All in "pending" status

---

## Next Steps

After successful setup:

1. ✅ **Verify in Supabase** - Check Table Editor
2. ✅ **Test API** - Visit your Render URL + `/docs`
3. ✅ **Update Flutter apps** - Point to Render API URL
4. ✅ **Test login** - Use instructor credentials

---

## Need Help?

- Check error messages carefully
- Verify each step was completed
- Check Supabase dashboard for connection issues
- Review the script output for specific error details

**Last Updated:** 2025-01-27

