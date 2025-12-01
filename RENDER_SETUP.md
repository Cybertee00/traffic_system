# 🔗 Connect Flutter Apps to Render Server

This guide explains how to configure your Flutter apps to connect to your Render server instead of localhost.

## ✅ What's Been Updated

I've updated both Flutter apps to use your Render server by default:

### 1. **Flutter Learner App** (`flutter_app/`)
- ✅ Default URL: `https://smart-license-api.onrender.com`
- ✅ Settings page supports both IP addresses and full URLs
- ✅ Automatically uses HTTPS for Render URLs
- ✅ Backward compatible with IP addresses

### 2. **Smart Admin App** (`smart_admin/`)
- ✅ Default URL: `https://smart-license-api.onrender.com`
- ✅ Direct connection to Render server

## 🔍 Get Your Render Service URL

1. **Go to [Render Dashboard](https://dashboard.render.com/)**
2. **Click on your `smart-license-api` service**
3. **Copy the service URL** from the top of the page
   - It should look like: `https://smart-license-api.onrender.com`
   - Or: `https://smart-license-api-xxxx.onrender.com` (if you have a custom name)

## 📱 Update Flutter Apps

### Option 1: Use Default (Already Set)

The apps are already configured to use `https://smart-license-api.onrender.com`. If your Render service has a different URL, update it:

**For Flutter Learner App:**
1. Open `flutter_app/lib/pages/settings_backend.dart`
2. Find line with `_defaultUrl = 'https://smart-license-api.onrender.com'`
3. Replace with your actual Render URL

**For Smart Admin App:**
1. Open `smart_admin/lib/services/api_service.dart`
2. Find line with `baseUrl = 'https://smart-license-api.onrender.com'`
3. Replace with your actual Render URL

### Option 2: Change in App Settings (Flutter Learner App Only)

The Flutter Learner App has a settings page where users can change the server URL:

1. **Open the app**
2. **Go to Settings**
3. **Enter your Render URL** (e.g., `https://smart-license-api.onrender.com`)
4. **Save**

The app will remember this setting.

## 🔧 Verify Connection

### Test API Endpoint

1. **Open your Render service URL** in a browser:
   ```
   https://your-service.onrender.com/
   ```
   Should show: `{"message": "FastAPI backend is running!"}`

2. **Check API documentation:**
   ```
   https://your-service.onrender.com/docs
   ```

### Test from Flutter App

1. **Run the Flutter app**
2. **Try to login** with:
   - Username: `pauln`
   - Password: `pauln123`
3. **If it works**, you're connected! ✅

## 🐛 Troubleshooting

### Error: "Connection refused" or "Network error"

**Possible causes:**
1. **Wrong URL** - Verify your Render service URL
2. **Service not running** - Check Render dashboard, service should be "Live"
3. **Free tier spin-down** - Free tier services spin down after 15 minutes of inactivity
   - **Solution:** Wait 30 seconds for it to wake up, or upgrade to paid plan

### Error: "SSL/TLS error"

**Solution:** 
- Make sure you're using `https://` not `http://`
- The network security config is already set up for HTTPS

### Error: "CORS error"

**Solution:**
- The FastAPI backend already has CORS configured to allow all origins
- If you see CORS errors, check the Render logs

### Service is "Unhealthy" in Render

**Check:**
1. **Render Logs** - Look for error messages
2. **Environment Variables** - Verify `DATABASE_URL` is set correctly
3. **Database Connection** - Make sure Supabase database is accessible

## 📝 Important Notes

1. **HTTPS Required**: Render uses HTTPS by default, so always use `https://` URLs
2. **No Port Needed**: Render URLs don't need `:8000` port
3. **Free Tier Limitations**: 
   - Services spin down after 15 min inactivity
   - First request after spin-down takes ~30 seconds
   - Consider upgrading for production use

## 🎯 Quick Checklist

- [ ] Render service is deployed and "Live"
- [ ] Render service URL is correct
- [ ] Flutter apps updated with Render URL
- [ ] Test login works from Flutter app
- [ ] API endpoints accessible from browser

## 🔄 Switching Between Local and Render

### Use Render (Production):
- Flutter app: Already set to Render URL by default
- Or change in Settings: `https://smart-license-api.onrender.com`

### Use Local (Development):
- Flutter app Settings: Enter `http://YOUR_LOCAL_IP:8000`
- Example: `http://192.168.1.100:8000`

---

**Your Render Service URL:** `https://smart-license-api.onrender.com`

**Update this in the code if your actual URL is different!**

