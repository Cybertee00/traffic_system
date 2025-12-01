# ✅ Deployment Checklist

Use this checklist to ensure you complete all steps for deploying your FastAPI application to Render with Supabase.

## 📋 Pre-Deployment Checklist

### Supabase Setup
- [ ] Created Supabase account
- [ ] Created new Supabase project
- [ ] Saved project password securely
- [ ] Obtained connection string from Settings → Database
- [ ] URL-encoded special characters in password (if any)
- [ ] Tested connection string (optional but recommended)

### Code Preparation
- [ ] Verified all required files are in `FastApi` folder:
  - [ ] `main.py`
  - [ ] `db.py`
  - [ ] `requirements.txt`
  - [ ] `init_db.py`
  - [ ] `render.yaml`
  - [ ] `.gitignore`
  - [ ] `README.md`
- [ ] Verified `.gitignore` excludes sensitive files (`config.env`)
- [ ] Updated `render.yaml` with placeholder for DATABASE_URL (or will set via UI)
- [ ] Reviewed code for any hardcoded values that should be environment variables

### GitHub Setup
- [ ] Created/verified GitHub repository: `https://github.com/Cybertee00/traffic_system.git`
- [ ] Initialized git in `FastApi` folder (if not already done)
- [ ] Added remote origin
- [ ] Committed all files
- [ ] Pushed to GitHub main branch
- [ ] Verified files on GitHub (no sensitive data exposed)

## 🚀 Deployment Checklist

### Render Setup
- [ ] Created Render account
- [ ] Connected GitHub account to Render
- [ ] Created new Web Service
- [ ] Selected correct repository: `traffic_system`
- [ ] Set Root Directory: `FastApi`
- [ ] Configured build command: `pip install -r requirements.txt`
- [ ] Configured start command: `uvicorn main:app --host 0.0.0.0 --port $PORT`
- [ ] Added environment variable: `DATABASE_URL` with Supabase connection string
- [ ] Added environment variable: `PYTHON_VERSION` (optional)
- [ ] Selected appropriate plan (Free or Paid)
- [ ] Clicked "Create Web Service"
- [ ] Waited for initial deployment to complete

### Database Initialization
- [ ] Opened Render Shell (Dashboard → Service → Shell)
- [ ] Navigated to FastApi directory: `cd FastApi`
- [ ] Ran initialization: `python init_db.py`
- [ ] Verified successful output (tables created, default data inserted)
- [ ] Checked Supabase Table Editor to verify tables exist

### Verification
- [ ] Service shows "Live" status in Render dashboard
- [ ] Tested root endpoint: `https://your-service.onrender.com/`
- [ ] Verified response: `{"message": "FastAPI backend is running!"}`
- [ ] Accessed Swagger UI: `https://your-service.onrender.com/docs`
- [ ] Tested GET endpoint (e.g., `/stations/`)
- [ ] Verified database connection works (no errors in logs)
- [ ] Checked Render logs for any warnings or errors

## 🔧 Post-Deployment Checklist

### Configuration
- [ ] Updated CORS settings in `main.py` if needed (for Flutter app)
- [ ] Committed and pushed CORS changes (if made)
- [ ] Verified automatic redeployment on Render
- [ ] Tested API endpoints from Flutter app (if applicable)

### Documentation
- [ ] Saved Render service URL
- [ ] Documented environment variables
- [ ] Saved Supabase connection details securely
- [ ] Updated team documentation (if applicable)

### Monitoring
- [ ] Set up Render monitoring/alerts (optional)
- [ ] Bookmarked Render dashboard
- [ ] Bookmarked Supabase dashboard
- [ ] Verified logs are accessible

## 🐛 Troubleshooting Checklist

If something goes wrong:

- [ ] Checked Render build logs for errors
- [ ] Checked Render runtime logs for errors
- [ ] Verified DATABASE_URL is set correctly in Render
- [ ] Verified DATABASE_URL password is URL-encoded
- [ ] Checked Supabase project is active (not paused)
- [ ] Verified Supabase connection pooling is enabled
- [ ] Tested database connection string locally
- [ ] Verified all dependencies in requirements.txt
- [ ] Checked Python version compatibility
- [ ] Reviewed error messages carefully

## 📝 Notes Section

Use this space to jot down important information:

**Render Service URL**: 
```
https://____________________.onrender.com
```

**Supabase Project Details**:
- Project Name: ____________________
- Region: ____________________
- Connection String: ____________________
  (Store securely, not in this file!)

**Important Dates**:
- Deployment Date: ____________________
- Database Initialized: ____________________

**Team Access**:
- Render Dashboard: ____________________
- Supabase Dashboard: ____________________

---

## 🎉 Completion

Once all items are checked, your deployment is complete!

**Next Steps:**
1. Update Flutter app API endpoints
2. Test all functionality
3. Monitor for any issues
4. Set up backups (if needed)

---

**Last Updated**: 2025-01-27

