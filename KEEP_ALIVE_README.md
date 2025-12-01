# 🔄 Keep Alive Service for Render API

This service prevents your Render API from going to sleep by pinging it every 10 minutes.

## 📁 Files Included:

- **`keep_alive.py`** - Main keep-alive script
- **`test_keep_alive.py`** - Test script (runs once)
- **`requirements.txt`** - Python dependencies
- **`start_keep_alive.bat`** - Windows batch file to start the service

## 🚀 How to Use:

### Option 1: Direct Python Execution
```bash
# Install dependencies
pip install -r requirements.txt

# Run the keep-alive service
python keep_alive.py
```

### Option 2: Windows Batch File
```bash
# Double-click or run:
start_keep_alive.bat
```

### Option 3: Test First
```bash
# Test the connection first:
python test_keep_alive.py
```

## ⚙️ Configuration:

The script is configured to:
- **Target URL**: `https://smart-license-api.onrender.com`
- **Ping Interval**: 10 minutes (600 seconds)
- **Timeout**: 30 seconds per request

To modify these settings, edit the constants at the top of `keep_alive.py`:
```python
RENDER_API_URL = "https://smart-license-api.onrender.com"
PING_INTERVAL = 600  # 10 minutes in seconds
TIMEOUT = 30  # Request timeout in seconds
```

## 📊 Features:

- ✅ **Immediate first ping** when script starts
- ⏰ **10-minute intervals** between pings
- 📈 **Success/failure tracking** with statistics
- 🛑 **Graceful shutdown** with Ctrl+C
- 📝 **Detailed logging** with timestamps
- ⚠️ **Error handling** for various connection issues

## 🎯 What It Does:

1. **Immediate Ping**: Pings the API as soon as the script starts
2. **Regular Pings**: Continues pinging every 10 minutes
3. **Status Tracking**: Shows success/failure statistics
4. **Prevents Sleep**: Keeps your Render service active

## 🛑 How to Stop:

Press **Ctrl+C** to stop the service gracefully. The script will show final statistics before exiting.

## 📋 Sample Output:

```
🚀 Keep Alive Service Starting...
📍 Target URL: https://smart-license-api.onrender.com
⏰ Ping Interval: 600 seconds (10 minutes)
⏱️  Timeout: 30 seconds
============================================================
[2025-09-04 17:11:49] Pinging https://smart-license-api.onrender.com...
   ✅ Success! Status: 200
   📊 Stats: Total=1, Success=1, Failed=0
   🎯 First ping completed! Starting 10-minute interval...
------------------------------------------------------------
⏳ Waiting 10 minutes until next ping...
```

## 🔧 Troubleshooting:

- **Connection Errors**: Check your internet connection
- **Timeout Errors**: The server might be slow to respond
- **Import Errors**: Run `pip install -r requirements.txt`

## 💡 Tips:

- Run this script on a computer that stays on 24/7
- Consider running it on a VPS or cloud server for reliability
- The script is lightweight and won't impact system performance
- Free Render services sleep after 15 minutes of inactivity

---
*Keep your Render API alive! 🚀*
