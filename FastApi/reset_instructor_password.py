#!/usr/bin/env python3
"""
Reset instructor password by creating a new user or updating existing one
Uses direct database connection to fix password
"""

import os
import sys
from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker
from passlib.context import CryptContext

# Load environment
if os.path.exists('config.env'):
    from dotenv import load_dotenv
    load_dotenv('config.env')

DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    print("❌ DATABASE_URL not set!")
    sys.exit(1)

# Convert to psycopg if needed
if DATABASE_URL.startswith("postgresql://") and not DATABASE_URL.startswith("postgresql+psycopg://"):
    DATABASE_URL = DATABASE_URL.replace("postgresql://", "postgresql+psycopg://", 1)

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def reset_password():
    """Reset password directly in database"""
    print("=" * 60)
    print("🔧 Resetting Instructor Password")
    print("=" * 60)
    
    try:
        engine = create_engine(DATABASE_URL, pool_pre_ping=True, connect_args={"connect_timeout": 10})
        SessionLocal = sessionmaker(bind=engine)
        db = SessionLocal()
        
        try:
            # Get user
            result = db.execute(text("SELECT id, username, password FROM users WHERE username = 'pauln'"))
            user = result.fetchone()
            
            if not user:
                print("❌ User 'pauln' not found!")
                return False
            
            user_id, username, old_hash = user
            print(f"✅ Found user: {username} (ID: {user_id})")
            print(f"   Old hash: {old_hash[:50]}...")
            
            # Generate new password hash
            new_password = "pauln123"
            new_hash = pwd_context.hash(new_password)
            print(f"\n🔐 Generating new password hash...")
            print(f"   New hash: {new_hash[:50]}...")
            
            # Update password
            db.execute(
                text("UPDATE users SET password = :password WHERE id = :user_id"),
                {"password": new_hash, "user_id": user_id}
            )
            db.commit()
            
            print("✅ Password updated in database!")
            
            # Verify the new hash
            verify_result = pwd_context.verify(new_password, new_hash)
            print(f"✅ Password verification test: {verify_result}")
            
            return True
            
        except Exception as e:
            print(f"❌ Error: {e}")
            import traceback
            traceback.print_exc()
            db.rollback()
            return False
        finally:
            db.close()
            
    except Exception as e:
        print(f"❌ Connection error: {e}")
        return False

if __name__ == "__main__":
    print("\n🚀 Resetting Instructor Password\n")
    success = reset_password()
    
    print("\n" + "=" * 60)
    if success:
        print("✅ SUCCESS! Password has been reset")
        print("=" * 60)
        print("   Username: pauln")
        print("   Password: pauln123")
        print("\n   Try logging in now!")
    else:
        print("❌ Failed to reset password")
    print("=" * 60)

