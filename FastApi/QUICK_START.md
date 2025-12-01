# ⚡ Quick Start Guide

This is a condensed version of the deployment guide. For detailed instructions, see [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md).

## 🎯 Quick Deployment Steps

### 1. Supabase Setup (5 minutes)

1. Go to [supabase.com](https://supabase.com) and create account
2. Create new project → Wait for provisioning
3. Go to **Settings → Database**
4. Copy **Connection string** (Connection pooling mode)
5. **URL-encode password** if it has special characters:
   - `@` → `%40`
   - `#` → `%23`
   - `%` → `%25`

### 2. Push to GitHub (2 minutes)

```bash
cd FastApi
git init
git remote add origin https://github.com/Cybertee00/traffic_system.git
git add .
git commit -m "Initial commit: FastAPI backend"
git branch -M main
git push -u origin main
```

### 3. Deploy to Render (5 minutes)

1. Go to [render.com](https://render.com) and sign up
2. Click **"New +" → "Web Service"**
3. Connect GitHub → Select `traffic_system` repository
4. Configure:
   - **Name**: `smart-license-api`
   - **Root Directory**: `FastApi`
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `uvicorn main:app --host 0.0.0.0 --port $PORT`
5. Add Environment Variable:
   - **Key**: `DATABASE_URL`
   - **Value**: Your Supabase connection string
6. Click **"Create Web Service"**

### 4. Initialize Database (2 minutes)

1. In Render dashboard → Your service → **Shell** tab
2. Run:
   ```bash
   cd FastApi
   python init_db.py
   ```

### 5. Verify (1 minute)

1. Visit your Render service URL
2. Check: `https://your-service.onrender.com/docs`
3. Test endpoint: `https://your-service.onrender.com/`

## ✅ Done!

Your API is now live! 🎉

**Next Steps:**
- Update Flutter app to use new API URL
- Configure CORS if needed
- Set up monitoring

## 🆘 Need Help?

See [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) for detailed troubleshooting.

