#!/usr/bin/env python3
"""
Script to create a superadmin user in the database for SMART Admin login
"""

import sys
from datetime import datetime
from passlib.context import CryptContext
from db import SessionLocal
from main import User, UserProfile
import os

# Initialize password context
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def create_superadmin_user():
    """Create a superadmin user with complete profile"""
    print("🔧 Creating superadmin user for SMART Admin...")
    
    db = SessionLocal()
    
    try:
        # Check if superadmin user already exists
        existing_superadmin = db.query(User).filter(
            User.username == "superadmin",
            User.role == "super_admin"
        ).first()
        
        if existing_superadmin:
            print(f"✅ Superadmin user already exists:")
            print(f"   Username: {existing_superadmin.username}")
            print(f"   Role: {existing_superadmin.role}")
            print(f"   Email: {existing_superadmin.email}")
            print(f"   User ID: {existing_superadmin.id}")
            print(f"   Is Active: {existing_superadmin.is_active}")
            
            # Check if profile exists
            profile = db.query(UserProfile).filter(UserProfile.user_id == existing_superadmin.id).first()
            if profile:
                print(f"   Profile: {profile.name} {profile.surname}")
            else:
                print(f"   ⚠️  No profile found for superadmin user")
            
            return existing_superadmin.id
        
        # Create new superadmin user
        print("📝 Creating new superadmin user...")
        
        # Generate password hash
        password = "superadmin123"
        password_hash = pwd_context.hash(password)
        
        # Create User
        superadmin_user = User(
            username="superadmin",
            password=password_hash,
            email="superadmin@smart.test",
            role="super_admin",
            is_active=True
        )
        db.add(superadmin_user)
        db.flush()  # Get the user ID
        
        print(f"✅ Created superadmin user: {superadmin_user.username} (ID: {superadmin_user.id})")
        
        # Create UserProfile for superadmin
        superadmin_profile = UserProfile(
            user_id=superadmin_user.id,
            name="Super",
            surname="Administrator",
            date_of_birth=datetime(1980, 1, 1).date(),
            gender="Other",
            nationality="South African",
            id_number="8001010000002",
            contact_number="+27123456790",
            physical_address="Admin Office, SMART System",
            race="Other"
        )
        db.add(superadmin_profile)
        
        db.commit()
        
        print("\n" + "=" * 60)
        print("✅ SUCCESS! Superadmin user created:")
        print(f"   Username: {superadmin_user.username}")
        print(f"   Password: {password}")
        print(f"   Email: {superadmin_user.email}")
        print(f"   Role: {superadmin_user.role}")
        print(f"   User ID: {superadmin_user.id}")
        print(f"   Profile: {superadmin_profile.name} {superadmin_profile.surname}")
        print("=" * 60)
        print("\n📋 Login Credentials:")
        print(f"   Username: superadmin")
        print(f"   Password: superadmin123")
        print("\n💡 You can now use these credentials to login to the smart_admin app")
        print("   and access the 'Register Admin' feature!")
        print("=" * 60)
        
        return superadmin_user.id
        
    except Exception as e:
        print(f"❌ Error creating superadmin user: {e}")
        import traceback
        traceback.print_exc()
        db.rollback()
        return None
    finally:
        db.close()

if __name__ == "__main__":
    create_superadmin_user()

