# 🚀 Complete Deployment Guide: FastAPI to Render with Supabase Database

This comprehensive guide will walk you through deploying your FastAPI application to Render and setting up a Supabase database.

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Step 1: Create Supabase Database](#step-1-create-supabase-database)
3. [Step 2: Prepare FastAPI Project for GitHub](#step-2-prepare-fastapi-project-for-github)
4. [Step 3: Push to GitHub Repository](#step-3-push-to-github-repository)
5. [Step 4: Deploy to Render](#step-4-deploy-to-render)
6. [Step 5: Initialize Database](#step-5-initialize-database)
7. [Step 6: Verify Deployment](#step-6-verify-deployment)
8. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before starting, ensure you have:

- ✅ A GitHub account
- ✅ A Render account (sign up at [render.com](https://render.com))
- ✅ A Supabase account (sign up at [supabase.com](https://supabase.com))
- ✅ Git installed on your local machine
- ✅ Python 3.11+ installed locally (for testing)

---

## Step 1: Create Supabase Database

### 1.1 Create a Supabase Project

1. **Go to [Supabase Dashboard](https://app.supabase.com/)**
2. **Click "New Project"**
3. **Fill in the project details:**
   - **Name**: `traffic-system-db` (or your preferred name)
   - **Database Password**: Create a strong password (save this!)
   - **Region**: Choose the closest region to your users
   - **Pricing Plan**: Free tier is sufficient for development

4. **Click "Create new project"**
5. **Wait 2-3 minutes** for the project to be provisioned

### 1.2 Get Database Connection String

1. **In your Supabase project dashboard, go to:**
   - **Settings** → **Database**

2. **Find the "Connection string" section**
3. **Select "Connection pooling" mode** (recommended for production)
4. **Copy the connection string** - it will look like:
   ```
   postgresql://postgres.[PROJECT_REF]:[YOUR_PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres
   ```

5. **Important**: If your password contains special characters (like `@`, `#`, `%`), you need to URL-encode them:
   - `@` becomes `%40`
   - `#` becomes `%23`
   - `%` becomes `%25`
   - `/` becomes `%2F`
   - `:` becomes `%3A`

   **Example:**
   - Original password: `MyP@ss#123`
   - URL-encoded: `MyP%40ss%23123`
   - Full connection string: `postgresql://postgres.xxx:MyP%40ss%23123@aws-0-us-east-1.pooler.supabase.com:6543/postgres`

6. **Save this connection string** - you'll need it for Render deployment

### 1.3 Test Database Connection (Optional)

You can test the connection using a PostgreSQL client or Python:

```python
import psycopg
conn_string = "your_connection_string_here"
conn = psycopg.connect(conn_string)
print("✅ Connection successful!")
conn.close()
```

---

## Step 2: Prepare FastAPI Project for GitHub

### 2.1 Create .gitignore File

Create a `.gitignore` file in the `FastApi` folder to exclude sensitive files:

```gitignore
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg

# Environment variables
.env
config.env
*.env

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Logs
*.log
```

### 2.2 Create README.md for Repository

Create a `README.md` file in the `FastApi` folder:

```markdown
# Smart License API - FastAPI Backend

A FastAPI-based backend for the Smart License Traffic System.

## Features

- User authentication and authorization
- Instructor and learner profile management
- Test booking system
- Station management
- Security questions for password recovery

## Tech Stack

- FastAPI
- SQLAlchemy
- PostgreSQL (Supabase)
- Python 3.11+

## Local Development

1. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

2. Set up environment variables:
   - Copy `config.env.example` to `config.env`
   - Add your database connection string

3. Initialize database:
   ```bash
   python init_db.py
   ```

4. Run the server:
   ```bash
   uvicorn main:app --reload
   ```

## API Documentation

Once running, visit:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## Deployment

See [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) for detailed deployment instructions.
```

### 2.3 Verify Required Files

Ensure your `FastApi` folder contains these files:

- ✅ `main.py` - FastAPI application
- ✅ `db.py` - Database configuration
- ✅ `requirements.txt` - Python dependencies
- ✅ `render.yaml` - Render configuration
- ✅ `init_db.py` - Database initialization script
- ✅ `runtime.txt` - Python version (optional but recommended)
- ✅ `.gitignore` - Git ignore file
- ✅ `README.md` - Project documentation

---

## Step 3: Push to GitHub Repository

### 3.1 Initialize Git Repository (if not already done)

Open terminal/PowerShell in the `FastApi` folder:

```bash
cd FastApi
git init
```

### 3.2 Add Remote Repository

```bash
git remote add origin https://github.com/Cybertee00/traffic_system.git
```

### 3.3 Stage and Commit Files

```bash
# Add all files
git add .

# Commit
git commit -m "Initial commit: FastAPI backend for traffic system"

# Push to main branch
git branch -M main
git push -u origin main
```

**Note**: If the repository already has content, you may need to:
- Pull first: `git pull origin main --allow-unrelated-histories`
- Resolve any conflicts
- Then push: `git push -u origin main`

### 3.4 Verify on GitHub

1. Go to [https://github.com/Cybertee00/traffic_system](https://github.com/Cybertee00/traffic_system)
2. Verify all files are present
3. Check that sensitive files (like `config.env`) are NOT included

---

## Step 4: Deploy to Render

### 4.1 Connect Repository to Render

1. **Go to [Render Dashboard](https://dashboard.render.com/)**
2. **Click "New +" → "Web Service"**
3. **Connect GitHub:**
   - Click "Connect account" if not already connected
   - Authorize Render to access your GitHub repositories
   - Select the repository: `Cybertee00/traffic_system`

### 4.2 Configure Web Service

Fill in the configuration:

- **Name**: `smart-license-api` (or your preferred name)
- **Region**: Choose closest to your users
- **Branch**: `main`
- **Root Directory**: `FastApi` (important!)
- **Environment**: `Python 3`
- **Build Command**: 
  ```bash
  pip install -r requirements.txt
  ```
- **Start Command**: 
  ```bash
  uvicorn main:app --host 0.0.0.0 --port $PORT
  ```
- **Plan**: Free (or choose paid plan for better performance)

### 4.3 Add Environment Variables

Click on "Advanced" → "Add Environment Variable":

1. **DATABASE_URL**:
   - Key: `DATABASE_URL`
   - Value: Your Supabase connection string (from Step 1.2)
   - Example: `postgresql://postgres.xxx:password%40encoded@aws-0-us-east-1.pooler.supabase.com:6543/postgres`

2. **PYTHON_VERSION** (optional):
   - Key: `PYTHON_VERSION`
   - Value: `3.11.0` (or match your `runtime.txt`)

### 4.4 Deploy

1. **Click "Create Web Service"**
2. **Wait for deployment** (usually 2-5 minutes)
3. **Monitor the build logs** for any errors

### 4.5 Alternative: Using render.yaml (Infrastructure as Code)

If you prefer using `render.yaml`:

1. **Update `render.yaml`** with your Supabase connection string:
   ```yaml
   services:
     - type: web
       name: smart-license-api
       env: python
       plan: free
       buildCommand: pip install -r requirements.txt
       startCommand: uvicorn main:app --host 0.0.0.0 --port $PORT
       envVars:
         - key: DATABASE_URL
           value: your_supabase_connection_string_here
         - key: PYTHON_VERSION
           value: 3.11.0
   ```

2. **In Render Dashboard:**
   - Click "New +" → "Blueprint"
   - Connect your GitHub repository
   - Render will automatically detect and use `render.yaml`

---

## Step 5: Initialize Database

After deployment, you need to initialize the database tables and default data.

### 5.1 Using Render Shell

1. **Go to your web service dashboard in Render**
2. **Click on "Shell" tab**
3. **Run the initialization script:**
   ```bash
   cd FastApi
   python init_db.py
   ```
4. **Verify output** - you should see:
   ```
   ✅ Database tables created successfully!
   ✅ Added station: Main Station
   ✅ Database initialization completed successfully!
   ```

### 5.2 Alternative: Using Local Machine

If Render Shell doesn't work, you can run initialization locally:

1. **Set environment variable:**
   ```bash
   # Windows PowerShell
   $env:DATABASE_URL="your_supabase_connection_string"
   
   # Linux/Mac
   export DATABASE_URL="your_supabase_connection_string"
   ```

2. **Run initialization:**
   ```bash
   cd FastApi
   python init_db.py
   ```

### 5.3 Verify Database Tables

1. **Go to Supabase Dashboard** → **Table Editor**
2. **Verify these tables exist:**
   - `users`
   - `user_profiles`
   - `instructor_profile`
   - `learner_profiles`
   - `learner_test_bookings`
   - `security_questions`
   - `user_security_answers`
   - `station`

3. **Check default data:**
   - `security_questions` should have 6 questions
   - `station` should have 5 default stations (if init_db.py ran successfully)

---

## Step 6: Verify Deployment

### 6.1 Test API Endpoints

1. **Get your Render service URL** (e.g., `https://smart-license-api.onrender.com`)

2. **Test root endpoint:**
   ```bash
   curl https://your-service-url.onrender.com/
   ```
   Expected response:
   ```json
   {"message": "FastAPI backend is running!"}
   ```

3. **Test API documentation:**
   - Visit: `https://your-service-url.onrender.com/docs`
   - You should see Swagger UI with all API endpoints

4. **Test a GET endpoint:**
   ```bash
   curl https://your-service-url.onrender.com/stations/
   ```
   Should return an array of stations (may be empty if not initialized)

### 6.2 Update CORS Settings (if needed)

If your Flutter app needs to connect to the API:

1. **Update `main.py`** CORS settings:
   ```python
   app.add_middleware(
       CORSMiddleware,
       allow_origins=[
           "https://your-flutter-app-domain.com",
           "http://localhost:3000",  # for local development
       ],
       allow_credentials=True,
       allow_methods=["*"],
       allow_headers=["*"],
   )
   ```

2. **Commit and push changes:**
   ```bash
   git add main.py
   git commit -m "Update CORS settings"
   git push
   ```

3. **Render will automatically redeploy**

---

## Troubleshooting

### Issue: Build Fails

**Symptoms**: Build logs show errors

**Solutions**:
- Check `requirements.txt` for correct package versions
- Verify Python version in `runtime.txt` matches Render's supported versions
- Check build logs for specific error messages

### Issue: Database Connection Fails

**Symptoms**: Application starts but database queries fail

**Solutions**:
- Verify `DATABASE_URL` environment variable is set correctly in Render
- Check that password is URL-encoded (especially `@` → `%40`)
- Ensure Supabase project is active (not paused)
- Check Supabase connection pooling settings
- Verify network access in Supabase (Settings → Database → Connection pooling)

### Issue: Tables Not Created

**Symptoms**: API returns errors about missing tables

**Solutions**:
- Run `init_db.py` via Render Shell
- Check database connection string is correct
- Verify SQLAlchemy models are correct
- Check Supabase logs for errors

### Issue: Application Crashes on Startup

**Symptoms**: Service shows "Unhealthy" status

**Solutions**:
- Check Render logs for error messages
- Verify `startCommand` is correct
- Ensure `main.py` has proper error handling
- Check that all dependencies are in `requirements.txt`

### Issue: Slow Response Times

**Symptoms**: API responses are slow

**Solutions**:
- Upgrade to paid Render plan (free tier spins down after inactivity)
- Use connection pooling (already configured in Supabase)
- Optimize database queries
- Add caching if needed

### Issue: Environment Variables Not Working

**Symptoms**: Application uses wrong database or configuration

**Solutions**:
- Verify environment variables in Render dashboard
- Check that variables are set at service level, not environment level
- Restart the service after adding variables
- Use Render Shell to verify: `echo $DATABASE_URL`

---

## 🎉 Success Checklist

- [ ] Supabase database created and connection string obtained
- [ ] FastAPI project pushed to GitHub repository
- [ ] Render web service created and connected to GitHub
- [ ] Environment variables configured in Render
- [ ] Application deployed successfully
- [ ] Database initialized with tables and default data
- [ ] API endpoints responding correctly
- [ ] API documentation accessible at `/docs`

---

## 📚 Additional Resources

- [Render Documentation](https://render.com/docs)
- [Supabase Documentation](https://supabase.com/docs)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [SQLAlchemy Documentation](https://docs.sqlalchemy.org/)

---

## 🔒 Security Best Practices

1. **Never commit sensitive data**:
   - Use `.gitignore` to exclude `config.env`
   - Use environment variables in Render

2. **Use strong database passwords**:
   - Generate complex passwords
   - Store them securely

3. **Enable Supabase Row Level Security (RLS)**:
   - Configure RLS policies in Supabase
   - Protect sensitive data

4. **Use HTTPS**:
   - Render provides HTTPS by default
   - Always use HTTPS in production

5. **Regular backups**:
   - Supabase provides automatic backups
   - Consider additional backup strategies

---

## 📞 Support

If you encounter issues:

1. Check Render logs: Dashboard → Your Service → Logs
2. Check Supabase logs: Dashboard → Logs
3. Review error messages carefully
4. Consult documentation links above

---

**Last Updated**: 2025-01-27
**Version**: 1.0

