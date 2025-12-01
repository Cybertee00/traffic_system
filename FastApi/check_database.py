#!/usr/bin/env python3
"""
Diagnostic script to check database connection and verify data
"""

import os
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from db import DATABASE_URL, Base
from main import User, UserProfile, InstructorProfile, Station

def check_database():
    """Check database connection and list all data"""
    print("=" * 60)
    print("🔍 DATABASE DIAGNOSTIC CHECK")
    print("=" * 60)
    
    # Show connection string (masked password)
    if DATABASE_URL:
        masked_url = DATABASE_URL.split('@')[0].split(':')[-1] + '@' + DATABASE_URL.split('@')[1] if '@' in DATABASE_URL else DATABASE_URL
        print(f"\n📡 Connection String: {masked_url[:80]}...")
    else:
        print("❌ DATABASE_URL not set!")
        return
    
    try:
        # Create engine and test connection
        print("\n🔌 Testing database connection...")
        engine = create_engine(DATABASE_URL, pool_pre_ping=True, connect_args={"connect_timeout": 5})
        
        # Test raw connection
        with engine.connect() as conn:
            result = conn.execute(text("SELECT version();"))
            version = result.fetchone()[0]
            print(f"✅ Connected to PostgreSQL: {version[:50]}...")
        
        # Check if tables exist
        print("\n📊 Checking tables...")
        SessionLocal = sessionmaker(bind=engine)
        db = SessionLocal()
        
        try:
            # Check users table
            user_count = db.query(User).count()
            print(f"   Users table: {user_count} records")
            
            # Check user_profiles table
            profile_count = db.query(UserProfile).count()
            print(f"   User profiles table: {profile_count} records")
            
            # Check instructor_profile table
            instructor_count = db.query(InstructorProfile).count()
            print(f"   Instructor profiles table: {instructor_count} records")
            
            # Check stations table
            station_count = db.query(Station).count()
            print(f"   Stations table: {station_count} records")
            
            # List all users
            if user_count > 0:
                print("\n👥 All Users:")
                users = db.query(User).all()
                for user in users:
                    print(f"   - ID: {user.id}, Username: {user.username}, Role: {user.role}, Email: {user.email}")
            
            # Check for instructor pauln
            print("\n🔍 Checking for instructor 'pauln'...")
            instructor_user = db.query(User).filter(User.username == "pauln").first()
            if instructor_user:
                print(f"   ✅ Found user: {instructor_user.username} (ID: {instructor_user.id})")
                
                profile = db.query(UserProfile).filter(UserProfile.user_id == instructor_user.id).first()
                if profile:
                    print(f"   ✅ Profile: {profile.name} {profile.surname}")
                else:
                    print(f"   ❌ No profile found")
                
                instructor_profile = db.query(InstructorProfile).filter(InstructorProfile.user_id == instructor_user.id).first()
                if instructor_profile:
                    print(f"   ✅ Instructor profile: INF-{instructor_profile.inf_nr}, Station: {instructor_profile.station_id}")
                else:
                    print(f"   ❌ No instructor profile found")
            else:
                print("   ❌ Instructor 'pauln' not found")
            
            # List all stations
            if station_count > 0:
                print("\n📍 All Stations:")
                stations = db.query(Station).all()
                for station in stations:
                    print(f"   - ID: {station.station_id}, Name: {station.name}, Grounds: {station.num_grounds}")
            else:
                print("\n   ⚠️  No stations found")
            
            # Check table existence using raw SQL
            print("\n📋 Checking table existence...")
            with engine.connect() as conn:
                result = conn.execute(text("""
                    SELECT table_name 
                    FROM information_schema.tables 
                    WHERE table_schema = 'public'
                    ORDER BY table_name;
                """))
                tables = [row[0] for row in result]
                print(f"   Found {len(tables)} tables:")
                for table in tables:
                    print(f"   - {table}")
            
        finally:
            db.close()
        
        print("\n" + "=" * 60)
        print("✅ Diagnostic complete!")
        print("=" * 60)
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    check_database()

