#!/usr/bin/env python3
"""
Script to create an admin user in the database for SMART Admin login
"""

import sys
from datetime import datetime
from passlib.context import CryptContext
from db import SessionLocal
from main import User, UserProfile
import os

# Initialize password context
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def create_admin_user():
    """Create an admin user with complete profile"""
    print("🔧 Creating admin user for SMART Admin...")
    
    db = SessionLocal()
    
    try:
        # Check if admin user already exists
        existing_admin = db.query(User).filter(
            User.username == "admin",
            User.role.in_(["admin", "super_admin"])
        ).first()
        
        if existing_admin:
            print(f"✅ Admin user already exists:")
            print(f"   Username: {existing_admin.username}")
            print(f"   Role: {existing_admin.role}")
            print(f"   Email: {existing_admin.email}")
            print(f"   User ID: {existing_admin.id}")
            print(f"   Is Active: {existing_admin.is_active}")
            
            # Check if profile exists
            profile = db.query(UserProfile).filter(UserProfile.user_id == existing_admin.id).first()
            if profile:
                print(f"   Profile: {profile.name} {profile.surname}")
            else:
                print(f"   ⚠️  No profile found for admin user")
            
            return existing_admin.id
        
        # Create new admin user
        print("📝 Creating new admin user...")
        
        # Generate password hash
        password = "admin123"
        password_hash = pwd_context.hash(password)
        
        # Create User
        admin_user = User(
            username="admin",
            password=password_hash,
            email="admin@smart.test",
            role="admin",
            is_active=True
        )
        db.add(admin_user)
        db.flush()  # Get the user ID
        
        print(f"✅ Created admin user: {admin_user.username} (ID: {admin_user.id})")
        
        # Create UserProfile for admin
        admin_profile = UserProfile(
            user_id=admin_user.id,
            name="Admin",
            surname="User",
            date_of_birth=datetime(1980, 1, 1).date(),
            gender="Other",
            nationality="South African",
            id_number="8001010000001",
            contact_number="+27123456789",
            physical_address="Admin Office, SMART System",
            race="Other"
        )
        db.add(admin_profile)
        
        db.commit()
        
        print("\n" + "=" * 60)
        print("✅ SUCCESS! Admin user created:")
        print(f"   Username: {admin_user.username}")
        print(f"   Password: {password}")
        print(f"   Email: {admin_user.email}")
        print(f"   Role: {admin_user.role}")
        print(f"   User ID: {admin_user.id}")
        print(f"   Profile: {admin_profile.name} {admin_profile.surname}")
        print("=" * 60)
        
        return admin_user.id
        
    except Exception as e:
        print(f"❌ Error creating admin user: {e}")
        import traceback
        traceback.print_exc()
        db.rollback()
        return None
    finally:
        db.close()

if __name__ == "__main__":
    create_admin_user()

