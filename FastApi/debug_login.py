#!/usr/bin/env python3
"""
Debug login issue - check all possible causes
"""

import requests
import json

BASE_URL = "https://smart-license-api-9otw.onrender.com"

def check_user_details():
    """Get full user details"""
    print("=" * 60)
    print("Checking User Details")
    print("=" * 60)
    
    try:
        response = requests.get(
            f"{BASE_URL}/users/pauln",
            timeout=30
        )
        
        if response.status_code == 200:
            user = response.json()
            print("✅ User found:")
            print(f"   ID: {user.get('id')}")
            print(f"   Username: {user.get('username')}")
            print(f"   Email: {user.get('email')}")
            print(f"   Role: {user.get('role')}")
            print(f"   Is Active: {user.get('is_active')}")
            print(f"   Password Hash: {user.get('password')[:50]}...")
            
            # Check role
            role = str(user.get('role', '')).lower()
            print(f"\n   Role check:")
            print(f"   - Role value: '{role}'")
            print(f"   - Is 'instructor'? {role == 'instructor'}")
            print(f"   - Is 'admin'? {role == 'admin'}")
            print(f"   - Is 'super_admin'? {role == 'super_admin'}")
            print(f"   - Allowed roles: ['instructor', 'admin', 'super_admin']")
            print(f"   - Role in allowed? {role in ['instructor', 'admin', 'super_admin']}")
            
            # Check is_active
            is_active = user.get('is_active')
            print(f"\n   Active check:")
            print(f"   - Is Active value: {is_active}")
            print(f"   - Type: {type(is_active)}")
            print(f"   - Bool conversion: {bool(is_active)}")
            
            return user
        else:
            print(f"❌ User not found: {response.status_code}")
            print(f"   Response: {response.text}")
            return None
            
    except Exception as e:
        print(f"❌ Error: {e}")
        return None

def test_login_variations():
    """Test login with different variations"""
    print("\n" + "=" * 60)
    print("Testing Login Variations")
    print("=" * 60)
    
    variations = [
        {"username": "pauln", "password": "pauln123", "role": "instructor"},
        {"username": "pauln", "password": "pauln123", "role": "admin"},
        {"username": "pauln", "password": "pauln123", "role": "instructor"},
        {"username": "Pauln", "password": "pauln123", "role": "instructor"},  # Case variation
        {"username": "PAULN", "password": "pauln123", "role": "instructor"},  # Uppercase
    ]
    
    for i, login_data in enumerate(variations, 1):
        print(f"\nTest {i}: {login_data}")
        try:
            response = requests.post(
                f"{BASE_URL}/login",
                json=login_data,
                headers={"Content-Type": "application/json"},
                timeout=30
            )
            
            print(f"   Status: {response.status_code}")
            if response.status_code == 200:
                result = response.json()
                print(f"   ✅ SUCCESS!")
                print(f"   User ID: {result.get('userid')}")
                return True
            else:
                print(f"   ❌ Failed: {response.text}")
        except Exception as e:
            print(f"   ❌ Error: {e}")
    
    return False

if __name__ == "__main__":
    print("\n🔍 Debugging Login Issue\n")
    
    user = check_user_details()
    
    if user:
        # Check if role or is_active might be the issue
        role = str(user.get('role', '')).lower()
        is_active = user.get('is_active')
        
        print("\n" + "=" * 60)
        print("Potential Issues:")
        print("=" * 60)
        
        if role not in ['instructor', 'admin', 'super_admin']:
            print(f"❌ Role issue: '{role}' not in allowed roles")
        else:
            print(f"✅ Role is valid")
        
        if not bool(is_active):
            print(f"❌ User is inactive: {is_active}")
        else:
            print(f"✅ User is active")
        
        print("\n" + "=" * 60)
        test_login_variations()
    
    print("\n" + "=" * 60)
    print("Debug Complete")
    print("=" * 60)

