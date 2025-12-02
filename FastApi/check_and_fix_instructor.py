#!/usr/bin/env python3
"""
Check instructor user and fix password if needed
"""

import os
import sys
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from db import DATABASE_URL, Base
from main import User, UserProfile, InstructorProfile
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def check_and_fix_instructor():
    """Check if instructor exists and fix password"""
    print("=" * 60)
    print("🔍 Checking Instructor User")
    print("=" * 60)
    
    if not DATABASE_URL:
        print("❌ DATABASE_URL not set!")
        return
    
    try:
        engine = create_engine(DATABASE_URL, pool_pre_ping=True, connect_args={"connect_timeout": 10})
        SessionLocal = sessionmaker(bind=engine)
        db = SessionLocal()
        
        try:
            # Check if user exists
            user = db.query(User).filter(User.username == "pauln").first()
            
            if not user:
                print("❌ User 'pauln' not found in database!")
                print("\nCreating instructor user...")
                
                # Create user
                password_hash = pwd_context.hash("pauln123")
                user = User(
                    username="pauln",
                    password=password_hash,
                    email="paul.ntsinyi@smart.test",
                    role="instructor",
                    is_active=True
                )
                db.add(user)
                db.flush()
                print(f"✅ Created user: pauln (ID: {user.id})")
                
                # Create profile
                from datetime import date
                profile = UserProfile(
                    user_id=user.id,
                    name="Paul",
                    surname="Ntsinyi",
                    date_of_birth=date(1985, 5, 15),
                    gender="Male",
                    nationality="South African",
                    id_number="8505155800081",
                    contact_number="0821234567",
                    physical_address="123 Instructor Street, Pretoria, 0001",
                    race="Black"
                )
                db.add(profile)
                print("✅ Created user profile")
                
                # Create instructor profile
                station = db.query(Base.metadata.tables['station']).filter_by(station_id=1).first()
                if not station:
                    # Get first station
                    from main import Station
                    station = db.query(Station).first()
                
                if station:
                    instructor_profile = InstructorProfile(
                        user_id=user.id,
                        inf_nr="INF-001",
                        station_id=station.station_id if hasattr(station, 'station_id') else 1
                    )
                    db.add(instructor_profile)
                    print("✅ Created instructor profile")
                
                db.commit()
                print("\n✅ Instructor created successfully!")
                
            else:
                print(f"✅ User found: pauln (ID: {user.id})")
                print(f"   Email: {user.email}")
                print(f"   Role: {user.role}")
                print(f"   Is Active: {user.is_active}")
                
                # Check password
                print("\n🔐 Testing password...")
                test_password = "pauln123"
                password_valid = pwd_context.verify(test_password, user.password)
                
                if password_valid:
                    print("✅ Password is correct!")
                else:
                    print("❌ Password doesn't match! Resetting password...")
                    # Reset password
                    user.password = pwd_context.hash(test_password)
                    db.commit()
                    print("✅ Password reset to: pauln123")
                
                # Check profile
                profile = db.query(UserProfile).filter(UserProfile.user_id == user.id).first()
                if profile:
                    print(f"\n✅ Profile found: {profile.name} {profile.surname}")
                else:
                    print("\n⚠️  No profile found - creating one...")
                    from datetime import date
                    profile = UserProfile(
                        user_id=user.id,
                        name="Paul",
                        surname="Ntsinyi",
                        date_of_birth=date(1985, 5, 15),
                        gender="Male",
                        nationality="South African",
                        id_number="8505155800081",
                        contact_number="0821234567",
                        physical_address="123 Instructor Street, Pretoria, 0001",
                        race="Black"
                    )
                    db.add(profile)
                    db.commit()
                    print("✅ Profile created")
                
                # Check instructor profile
                instructor_profile = db.query(InstructorProfile).filter(InstructorProfile.user_id == user.id).first()
                if instructor_profile:
                    print(f"✅ Instructor profile found: INF-{instructor_profile.inf_nr}")
                else:
                    print("⚠️  No instructor profile - creating one...")
                    from main import Station
                    station = db.query(Station).first()
                    instructor_profile = InstructorProfile(
                        user_id=user.id,
                        inf_nr="INF-001",
                        station_id=station.station_id if station else 1
                    )
                    db.add(instructor_profile)
                    db.commit()
                    print("✅ Instructor profile created")
            
            print("\n" + "=" * 60)
            print("✅ Instructor is ready!")
            print("=" * 60)
            print("   Username: pauln")
            print("   Password: pauln123")
            print("   Role: instructor")
            print("=" * 60)
            
        finally:
            db.close()
            
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    check_and_fix_instructor()

