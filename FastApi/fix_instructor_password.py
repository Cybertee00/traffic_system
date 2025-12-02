#!/usr/bin/env python3
"""
Fix instructor password using API calls
This script will create or update the instructor user via the Render API
"""

import requests
import json

BASE_URL = "https://smart-license-api-9otw.onrender.com"

def create_or_update_instructor():
    """Create or update instructor user via API"""
    print("=" * 60)
    print("🔧 Fixing Instructor User")
    print("=" * 60)
    
    # Step 1: Check if user exists
    print("\n1. Checking if user exists...")
    try:
        response = requests.get(
            f"{BASE_URL}/users/pauln",
            timeout=30
        )
        
        if response.status_code == 200:
            user = response.json()
            print(f"✅ User exists: {user.get('username')} (ID: {user.get('id')})")
            print(f"   Current email: {user.get('email')}")
            user_id = user.get('id')
            
            # Update password - we need to use a valid email
            print("\n2. Updating password...")
            # Get current email and fix if invalid
            current_email = user.get('email', '')
            # If email is invalid, use a valid one
            if 'smart.test' in current_email or not current_email:
                new_email = 'paul.ntsinyi@example.com'
            else:
                new_email = current_email
            
            update_data = {
                "username": "pauln",
                "password": "pauln123",
                "email": new_email,
                "role": "instructor",
                "is_active": True
            }
            
            print(f"   Updating with email: {new_email}")
            response = requests.put(
                f"{BASE_URL}/users/id/{user_id}",
                json=update_data,
                headers={"Content-Type": "application/json"},
                timeout=30
            )
            
            if response.status_code == 200:
                print("✅ Password updated!")
            else:
                print(f"❌ Failed to update: {response.status_code} - {response.text}")
                # Try alternative: create a new user with different username
                print("\n⚠️  Trying alternative: creating new user with different email...")
                return False
                
        else:
            print("⚠️  User not found, creating new user...")
            # Create user
            user_data = {
                "username": "pauln",
                "password": "pauln123",
                "email": "paul.ntsinyi@example.com",
                "role": "instructor",
                "is_active": True
            }
            
            response = requests.post(
                f"{BASE_URL}/users/",
                json=user_data,
                headers={"Content-Type": "application/json"},
                timeout=30
            )
            
            if response.status_code in [200, 201]:
                user = response.json()
                print(f"✅ User created: {user.get('username')} (ID: {user.get('id')})")
                user_id = user.get('id')
            else:
                print(f"❌ Failed to create user: {response.status_code} - {response.text}")
                return False
                
    except Exception as e:
        print(f"❌ Error: {e}")
        return False
    
    # Step 3: Create/update profile
    print("\n3. Checking user profile...")
    try:
        response = requests.get(
            f"{BASE_URL}/user-profiles/{user_id}",
            timeout=30
        )
        
        if response.status_code != 200:
            print("⚠️  Profile not found, creating...")
            profile_data = {
                "user_id": user_id,
                "name": "Paul",
                "surname": "Ntsinyi",
                "date_of_birth": "1985-05-15",
                "gender": "Male",
                "nationality": "South African",
                "id_number": "8505155800081",
                "contact_number": "0821234567",
                "physical_address": "123 Instructor Street, Pretoria, 0001",
                "race": "Black"
            }
            
            response = requests.post(
                f"{BASE_URL}/user-profiles/",
                json=profile_data,
                headers={"Content-Type": "application/json"},
                timeout=30
            )
            
            if response.status_code in [200, 201]:
                print("✅ Profile created!")
            else:
                print(f"⚠️  Profile creation failed: {response.status_code} - {response.text}")
        else:
            print("✅ Profile exists")
            
    except Exception as e:
        print(f"⚠️  Profile check error: {e}")
    
    # Step 4: Create/update instructor profile
    print("\n4. Checking instructor profile...")
    try:
        response = requests.get(
            f"{BASE_URL}/instructor-profiles/{user_id}",
            timeout=30
        )
        
        if response.status_code != 200:
            print("⚠️  Instructor profile not found, creating...")
            # Get stations first
            stations_response = requests.get(f"{BASE_URL}/stations/", timeout=30)
            station_id = 1
            if stations_response.status_code == 200:
                stations = stations_response.json()
                if stations:
                    station_id = stations[0].get('station_id', 1)
            
            instructor_data = {
                "user_id": user_id,
                "inf_nr": "INF-001",
                "station_id": station_id
            }
            
            response = requests.post(
                f"{BASE_URL}/instructor-profiles/",
                json=instructor_data,
                headers={"Content-Type": "application/json"},
                timeout=30
            )
            
            if response.status_code in [200, 201]:
                print("✅ Instructor profile created!")
            else:
                print(f"⚠️  Instructor profile creation failed: {response.status_code} - {response.text}")
        else:
            print("✅ Instructor profile exists")
            
    except Exception as e:
        print(f"⚠️  Instructor profile check error: {e}")
    
    # Step 5: Test login
    print("\n5. Testing login...")
    try:
        login_data = {
            "username": "pauln",
            "password": "pauln123",
            "role": "instructor"
        }
        
        response = requests.post(
            f"{BASE_URL}/login",
            json=login_data,
            headers={"Content-Type": "application/json"},
            timeout=30
        )
        
        if response.status_code == 200:
            result = response.json()
            print("✅ LOGIN SUCCESSFUL!")
            print(f"   User ID: {result.get('userid')}")
            print(f"   Username: {result.get('username')}")
            print(f"   Role: {result.get('role')}")
            return True
        else:
            print(f"❌ Login failed: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Login test error: {e}")
        return False

if __name__ == "__main__":
    print("\n🚀 Fixing Instructor User via API\n")
    success = create_or_update_instructor()
    
    print("\n" + "=" * 60)
    if success:
        print("✅ SUCCESS! Instructor is ready to use")
        print("=" * 60)
        print("   Username: pauln")
        print("   Password: pauln123")
        print("   Try logging in now!")
    else:
        print("⚠️  Some steps may have failed. Check the output above.")
    print("=" * 60)

