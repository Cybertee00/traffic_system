# 🚀 Database Setup Instructions

This guide will help you set up your Supabase database with:
- Database tables initialization
- Instructor: Paul Ntsinyi (username: pauln)
- Learners with test bookings (3 per day from tomorrow until end of February)

## 📋 Prerequisites

1. ✅ Supabase database created
2. ✅ Connection string obtained from Supabase
3. ✅ Render service deployed (or local Python environment)

## 🎯 Option 1: Run via Render Shell (Recommended)

Since your Render service is already deployed, this is the easiest method:

### Steps:

1. **Go to Render Dashboard**
   - Navigate to your `smart-license-api` service
   - Click on **"Shell"** tab

2. **Navigate to FastApi directory:**
   ```bash
   cd FastApi
   ```

3. **Run the setup script:**
   ```bash
   python setup_database_complete.py
   ```

4. **Wait for completion** - The script will:
   - Create all database tables
   - Create default stations and security questions
   - Create instructor Paul Ntsinyi
   - Create ~96 learners (3 per day × 32 days)

5. **Verify output** - You should see:
   ```
   ✅ DATABASE SETUP COMPLETE!
   ✅ Instructor created: pauln
   ✅ Learners created: 96
   ```

## 🎯 Option 2: Run Locally

If you want to run it from your local machine:

### Steps:

1. **Set environment variable:**
   
   **Windows PowerShell:**
   ```powershell
   $env:DATABASE_URL="postgresql://postgres.zivpoauevhefeeugdolq:0000@aws-1-eu-west-1.pooler.supabase.com:5432/postgres"
   ```
   
   **Windows CMD:**
   ```cmd
   set DATABASE_URL=postgresql://postgres.zivpoauevhefeeugdolq:0000@aws-1-eu-west-1.pooler.supabase.com:5432/postgres
   ```
   
   **Linux/Mac:**
   ```bash
   export DATABASE_URL="postgresql://postgres.zivpoauevhefeeugdolq:0000@aws-1-eu-west-1.pooler.supabase.com:5432/postgres"
   ```

2. **Navigate to FastApi directory:**
   ```bash
   cd FastApi
   ```

3. **Install dependencies (if not already done):**
   ```bash
   pip install -r requirements.txt
   ```

4. **Run the setup script:**
   ```bash
   python setup_database_complete.py
   ```

## 📊 What Gets Created

### 1. Database Tables
- `users` - User accounts
- `user_profiles` - User profile information
- `instructor_profile` - Instructor details
- `learner_profiles` - Learner information
- `learner_test_bookings` - Test bookings
- `station` - Testing stations
- `security_questions` - Security questions for password recovery

### 2. Default Data
- 5 default stations (Main, North, South, East, West)
- 6 security questions

### 3. Instructor
- **Username:** `pauln`
- **Password:** `pauln123`
- **Name:** Paul Ntsinyi
- **Email:** paul.ntsinyi@smart.test
- **Instructor Number:** INF-001
- **Station:** Main Station (ID: 1)

### 4. Learners
- **Total:** ~96 learners (3 per day × 32 days)
- **Date Range:** Tomorrow (Jan 28) to Feb 28, 2025
- **Password:** `password123` (all learners)
- **Username Format:** `learner.YYYYMMDD.N`
  - Example: `learner.20250128.1`, `learner.20250128.2`, `learner.20250128.3`

### 5. Test Bookings
- Each learner has a test booking for their assigned date
- All bookings are assigned to instructor Paul Ntsinyi
- All bookings are in "pending" status
- Bookings are at Main Station (ID: 1)

## ✅ Verification

After running the script, verify in Supabase:

1. **Go to Supabase Dashboard → Table Editor**

2. **Check tables:**
   - `users` - Should have instructor + ~96 learners
   - `user_profiles` - Should have profiles for all users
   - `instructor_profile` - Should have Paul Ntsinyi
   - `learner_profiles` - Should have ~96 learners
   - `learner_test_bookings` - Should have ~96 bookings
   - `station` - Should have 5 stations

3. **Test API endpoints:**
   ```bash
   # Get instructor profile
   curl https://your-render-url.onrender.com/instructor-profiles/
   
   # Get learners for a specific date
   curl https://your-render-url.onrender.com/learner-test-bookings/pending/2025-01-28
   
   # Get all stations
   curl https://your-render-url.onrender.com/stations/
   ```

## 🔧 Troubleshooting

### Error: "Failed to connect to database"
- Verify DATABASE_URL is set correctly
- Check Supabase project is active (not paused)
- Verify connection string has correct password (URL-encoded if needed)

### Error: "Station not found"
- The script will use the first available station
- Make sure `init_db.py` ran successfully to create default stations

### Error: "Instructor already exists"
- Script will use existing instructor if found
- Check existing instructor ID matches

### Script runs but no data appears
- Check Supabase Table Editor
- Verify database connection is working
- Check Render logs for errors

## 📝 Notes

- The script is idempotent - you can run it multiple times safely
- Existing data won't be duplicated (checks for existing records)
- All learners have the same password: `password123`
- Instructor password: `pauln123` (change this in production!)

## 🎉 Next Steps

After setup is complete:

1. **Test login:**
   - Instructor: username `pauln`, password `pauln123`
   - Any learner: username `learner.YYYYMMDD.N`, password `password123`

2. **Update Flutter apps:**
   - Point to your Render API URL
   - Test instructor login
   - Test learner bookings

3. **Monitor:**
   - Check Supabase dashboard for data
   - Monitor Render logs
   - Test API endpoints

---

**Need Help?** Check the main [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) for more details.

