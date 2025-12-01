#!/usr/bin/env python3
"""
Script to fix password hashes in the database to work with the downgraded bcrypt version
"""

import sys
sys.path.append('FastApi')

from FastApi.db import SessionLocal
from FastApi.main import User
from passlib.context import CryptContext

# Initialize password context with bcrypt 3.2.0
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def fix_passwords():
    """Regenerate password hashes for all users with 'password123'"""
    print("🔧 Fixing password hashes in database...")
    
    db = SessionLocal()
    try:
        # Get all users
        users = db.query(User).all()
        print(f"Found {len(users)} users in database")
        
        # Standard password for test users
        test_password = "password123"
        new_hash = pwd_context.hash(test_password)
        
        updated_count = 0
        for user in users:
            print(f"Updating password for user: {user.username} (ID: {user.id})")
            user.password = new_hash
            updated_count += 1
        
        db.commit()
        print(f"✅ Successfully updated {updated_count} user passwords")
        print(f"✅ New password hash: {new_hash[:50]}...")
        print(f"✅ All users now have password: '{test_password}'")
        
    except Exception as e:
        print(f"❌ Error fixing passwords: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    fix_passwords()

