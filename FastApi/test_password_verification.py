#!/usr/bin/env python3
"""
Test password verification with the actual hash from database
"""

from passlib.context import CryptContext
import requests

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Get current hash from API
BASE_URL = "https://smart-license-api-9otw.onrender.com"

print("Getting user from API...")
response = requests.get(f"{BASE_URL}/users/pauln", timeout=30)
if response.status_code == 200:
    user = response.json()
    stored_hash = user.get('password')
    print(f"Stored hash: {stored_hash}")
    
    # Test password
    test_password = "pauln123"
    print(f"\nTesting password: {test_password}")
    
    # Test verification
    try:
        result = pwd_context.verify(test_password, stored_hash)
        print(f"✅ Verification result: {result}")
        
        if not result:
            print("\n❌ Password doesn't match!")
            print("Generating new hash...")
            new_hash = pwd_context.hash(test_password)
            print(f"New hash: {new_hash}")
            print("\nUse this hash in Supabase SQL Editor:")
            print(f"UPDATE users SET password = '{new_hash}' WHERE username = 'pauln';")
    except Exception as e:
        print(f"❌ Verification error: {e}")

