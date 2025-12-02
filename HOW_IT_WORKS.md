# 🚀 How Your Flutter Apps Work with Render Server

This guide explains how your Flutter applications connect to and work with your Render-hosted FastAPI server.

## 📊 Architecture Overview

```
┌─────────────────┐
│  Flutter App    │  (Learner App or Admin App)
│  (Mobile/Web)   │
└────────┬────────┘
         │
         │ HTTPS Request
         │ (JSON)
         ▼
┌─────────────────┐
│  Render Server  │  (FastAPI Backend)
│  smart-license- │  https://smart-license-api.onrender.com
│  api.onrender.  │
│  com            │
└────────┬────────┘
         │
         │ SQL Query
         │ (PostgreSQL)
         ▼
┌─────────────────┐
│  Supabase       │  (PostgreSQL Database)
│  Database       │  (Your data: users, bookings, etc.)
└─────────────────┘
```

## 🔄 How It Works - Step by Step

### Example: User Login Flow

1. **User opens Flutter app** and enters credentials
   - Username: `pauln`
   - Password: `pauln123`

2. **Flutter app makes HTTP request:**
   ```dart
   // In login_backend.dart
   final url = Uri.parse(ApiConfig.buildUrl(context, "login"));
   // This becomes: https://smart-license-api.onrender.com/login
   
   final response = await http.post(
     url,
     headers: {"Content-Type": "application/json"},
     body: jsonEncode({
       "username": "pauln",
       "password": "pauln123",
       "role": "instructor"
     }),
   );
   ```

3. **Request travels over internet:**
   - Flutter app → Internet → Render server
   - Uses HTTPS (secure connection)
   - Works from anywhere (phone, tablet, computer)

4. **Render server receives request:**
   ```python
   # In main.py
   @app.post("/login")
   def login(req: LoginRequest, db: DBSession = Depends(get_db)):
       # FastAPI processes the request
       user = db.query(User).filter(User.username == req.username).first()
       # ... validates password, checks role, etc.
       return {"userid": user.id, "username": user.username, ...}
   ```

5. **Render server queries Supabase:**
   - Connects to Supabase database using `DATABASE_URL`
   - Executes SQL query: `SELECT * FROM users WHERE username = 'pauln'`
   - Gets user data from database

6. **Supabase returns data:**
   - User record found
   - Password verified
   - Returns user information

7. **Render server sends response:**
   ```json
   {
     "userid": 1,
     "username": "pauln",
     "role": "instructor",
     "email": "paul.ntsinyi@smart.test"
   }
   ```

8. **Flutter app receives response:**
   ```dart
   if (response.statusCode == 200) {
     final decoded = jsonDecode(response.body);
     // Save user session
     session.updateFromLogin(userId: decoded['userid'], ...);
     // Navigate to home page
     Navigator.pushReplacement(context, HomePage());
   }
   ```

9. **User sees dashboard** with their data!

## 📱 Real-World Scenarios

### Scenario 1: Instructor Logs In

**What happens:**
1. Instructor opens app on their phone
2. Enters username `pauln` and password `pauln123`
3. App sends: `POST https://smart-license-api.onrender.com/login`
4. Render server checks Supabase database
5. Server responds: "Login successful, user ID: 1"
6. App shows instructor dashboard
7. App can now fetch bookings, learners, etc.

### Scenario 2: View Today's Test Bookings

**What happens:**
1. Instructor clicks "Today's Bookings"
2. App sends: `GET https://smart-license-api.onrender.com/learner-test-bookings/pending/2026-01-28`
3. Render server queries Supabase: `SELECT * FROM learner_test_bookings WHERE test_date = '2026-01-28' AND result = 'pending'`
4. Server returns list of 3 learners for today
5. App displays the list on screen

### Scenario 3: Update Test Result

**What happens:**
1. Instructor marks a test as "passed"
2. App sends: `PUT https://smart-license-api.onrender.com/learner-test-bookings/123/result`
   ```json
   {"result": "passed"}
   ```
3. Render server updates Supabase database
4. Server responds: "Updated successfully"
5. App refreshes the list to show updated status

## 🌐 Network Flow Details

### Request Flow:
```
Flutter App (Your Phone)
    ↓
Internet (HTTPS)
    ↓
Render Server (FastAPI)
    ↓
Supabase Database (PostgreSQL)
    ↓
[Data Processing]
    ↓
Supabase → Render → Flutter App
```

### Key Points:

1. **HTTPS Encryption**: All data is encrypted in transit
2. **Works Anywhere**: Phone, tablet, computer - anywhere with internet
3. **Real-time**: Changes in database appear immediately
4. **Scalable**: Render handles multiple users simultaneously

## 🔧 Configuration

### Flutter App Configuration

**Default URL (already set):**
```dart
// flutter_app/lib/pages/settings_backend.dart
static const String _defaultUrl = 'https://smart-license-api.onrender.com';
```

**How to change (if needed):**
- Users can change it in app settings
- Or update the default in code

### Render Server Configuration

**Environment Variables (already set):**
- `DATABASE_URL` - Points to your Supabase database
- Server automatically connects to Supabase on startup

## ✅ What Works Now

### ✅ Works Automatically:
- ✅ Login/authentication
- ✅ Fetching user profiles
- ✅ Viewing test bookings
- ✅ Updating test results
- ✅ Creating new bookings
- ✅ Managing instructors
- ✅ All API endpoints

### ✅ Works From:
- ✅ Any device (phone, tablet, computer)
- ✅ Any location (home, office, on the road)
- ✅ Any network (WiFi, mobile data)
- ✅ Multiple users simultaneously

## 🚨 Important Considerations

### 1. Internet Connection Required
- App needs internet to work
- Works offline: ❌ (no offline mode currently)
- Caching: Limited (some data cached in app)

### 2. Render Free Tier Limitations
- **Spins down after 15 minutes of inactivity**
- First request after spin-down takes ~30 seconds
- Subsequent requests are fast
- **Solution**: Use paid tier for always-on, or accept the delay

### 3. CORS (Cross-Origin Resource Sharing)
- Already configured in FastAPI to allow all origins
- No issues with Flutter apps

### 4. HTTPS Required
- Render provides HTTPS automatically
- Flutter apps use HTTPS by default
- Secure connection guaranteed

## 🧪 Testing the Connection

### Test 1: Check Server is Online
```bash
curl https://smart-license-api.onrender.com/
```
**Expected:** `{"message": "FastAPI backend is running!"}`

### Test 2: Test Login Endpoint
```bash
curl -X POST https://smart-license-api.onrender.com/login \
  -H "Content-Type: application/json" \
  -d '{"username": "pauln", "password": "pauln123", "role": "instructor"}'
```
**Expected:** User data JSON

### Test 3: From Flutter App
1. Open the app
2. Try to login with `pauln` / `pauln123`
3. Should connect and login successfully

## 📊 Data Flow Example

### Complete Example: Instructor Views Dashboard

```
1. User opens app
   ↓
2. App checks: "Is user logged in?"
   ↓
3. If not logged in → Show login screen
   ↓
4. User enters credentials
   ↓
5. App → POST /login → Render Server
   ↓
6. Render Server → Query Supabase → Check user credentials
   ↓
7. Supabase → Return user data
   ↓
8. Render Server → Return JSON response
   ↓
9. App → Save session → Navigate to dashboard
   ↓
10. Dashboard loads → App → GET /instructor-profiles/1 → Render Server
   ↓
11. Render Server → Query Supabase → Get instructor profile
   ↓
12. Supabase → Return profile data
   ↓
13. Render Server → Return JSON
   ↓
14. App → Display dashboard with instructor info
   ↓
15. User sees their dashboard!
```

## 🔐 Security

### What's Secure:
- ✅ HTTPS encryption (all data encrypted)
- ✅ Password hashing (bcrypt in database)
- ✅ CORS configured properly
- ✅ No sensitive data in app code

### Best Practices:
- ✅ Never commit API keys to Git
- ✅ Use environment variables
- ✅ Render handles SSL certificates automatically

## 🎯 Summary

**How it works:**
1. Flutter app makes HTTP requests to Render server
2. Render server processes requests and queries Supabase
3. Supabase returns data
4. Render server sends JSON response back
5. Flutter app displays data to user

**Key Benefits:**
- ✅ Works from anywhere with internet
- ✅ Real-time data updates
- ✅ Secure HTTPS connection
- ✅ Scalable (handles multiple users)
- ✅ No local server needed

**Everything is connected and ready to use!** 🎉

---

**Need Help?**
- Check Render logs: Dashboard → Your Service → Logs
- Check Supabase logs: Dashboard → Logs
- Test API: Visit `https://your-render-url.onrender.com/docs`

