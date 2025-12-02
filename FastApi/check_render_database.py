#!/usr/bin/env python3
"""
Check if Render server is using the same database
"""

import requests
import json

BASE_URL = "https://smart-license-api-9otw.onrender.com"

print("=" * 60)
print("Checking Render Server Database Connection")
print("=" * 60)

# Test 1: Get user from Render server
print("\n1. Getting user from Render API...")
try:
    response = requests.get(f"{BASE_URL}/users/pauln", timeout=30)
    if response.status_code == 200:
        user = response.json()
        print(f"✅ User found on Render server:")
        print(f"   ID: {user.get('id')}")
        print(f"   Username: {user.get('username')}")
        print(f"   Email: {user.get('email')}")
        print(f"   Role: {user.get('role')}")
        print(f"   Is Active: {user.get('is_active')}")
        print(f"   Password Hash: {user.get('password')[:60]}...")
        
        # Compare with what we expect
        expected_hash_start = "$2b$12$sxZ27gvs5LkSe8ORZynpZudn5FH0dfgqOEC/vzYmKzX"
        actual_hash = user.get('password', '')
        
        print(f"\n   Hash comparison:")
        print(f"   Expected start: {expected_hash_start[:30]}...")
        print(f"   Actual hash:    {actual_hash[:30]}...")
        
        if actual_hash.startswith(expected_hash_start):
            print("   ✅ Hash matches what we set!")
        else:
            print("   ❌ Hash is DIFFERENT - Render might be using different database!")
            print("   This means Render DATABASE_URL might be pointing to a different Supabase project")
    else:
        print(f"❌ User not found: {response.status_code}")
        print(f"   Response: {response.text}")
except Exception as e:
    print(f"❌ Error: {e}")

# Test 2: Check if we can see other users
print("\n2. Checking total users in database...")
try:
    # Note: /users/ endpoint might not exist, but let's try
    response = requests.get(f"{BASE_URL}/instructor-profiles/", timeout=30)
    if response.status_code == 200:
        instructors = response.json()
        print(f"✅ Found {len(instructors)} instructor profiles")
        for inst in instructors:
            if inst.get('user_id') == 1:
                print(f"   ✅ Instructor profile for user_id 1 exists")
except Exception as e:
    print(f"⚠️  Could not check instructors: {e}")

print("\n" + "=" * 60)
print("Analysis Complete")
print("=" * 60)
print("\n💡 If the hash is different, check:")
print("   1. Render Dashboard → Your Service → Environment")
print("   2. Verify DATABASE_URL matches your Supabase connection string")
print("   3. Make sure you're looking at the same Supabase project")

