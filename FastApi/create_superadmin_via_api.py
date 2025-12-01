#!/usr/bin/env python3
"""
Script to create a superadmin user via the API endpoint
This is safer than direct database access and works if the API is running
"""

import requests
import json

BASE_URL = "http://localhost:8000"

def create_superadmin_via_api():
    """Create a superadmin user via the API"""
    print("🔧 Creating superadmin user via API...")
    print(f"📡 API URL: {BASE_URL}")
    
    try:
        # Step 1: Create the user account
        print("\n📝 Step 1: Creating user account...")
        user_data = {
            "username": "superadmin",
            "password": "superadmin123",
            "email": "superadmin@example.com",
            "role": "super_admin",
            "is_active": True
        }
        
        response = requests.post(
            f"{BASE_URL}/users/",
            headers={"Content-Type": "application/json"},
            json=user_data,
            timeout=10
        )
        
        if response.status_code in [200, 201]:
            user_result = response.json()
            user_id = user_result.get("id")
            print(f"✅ User account created successfully!")
            print(f"   User ID: {user_id}")
        else:
            # Check if user already exists
            if response.status_code == 400 or "already exists" in response.text.lower():
                print("⚠️  User might already exist. Trying to get user info...")
                # Try to login to get user info
                login_response = requests.post(
                    f"{BASE_URL}/login",
                    headers={"Content-Type": "application/json"},
                    json={
                        "username": "superadmin",
                        "password": "superadmin123",
                        "role": "admin"
                    },
                    timeout=10
                )
                if login_response.status_code == 200:
                    login_data = login_response.json()
                    user_id = login_data.get("userid")
                    print(f"✅ Superadmin user already exists!")
                    print(f"   User ID: {user_id}")
                    print(f"   Username: superadmin")
                    print(f"   Password: superadmin123")
                    print("\n💡 You can now use these credentials to login!")
                    return True
                else:
                    print(f"❌ Error: {response.status_code} - {response.text}")
                    return False
            else:
                print(f"❌ Error creating user: {response.status_code} - {response.text}")
                return False
        
        # Step 2: Create user profile
        print("\n📝 Step 2: Creating user profile...")
        profile_data = {
            "user_id": user_id,
            "name": "Super",
            "surname": "Administrator",
            "date_of_birth": "1980-01-01",
            "gender": "Other",
            "nationality": "South African",
            "id_number": "8001010000002",
            "contact_number": "+27123456790",
            "physical_address": "Admin Office, SMART System",
            "race": "Other"
        }
        
        profile_response = requests.post(
            f"{BASE_URL}/user-profiles/",
            headers={"Content-Type": "application/json"},
            json=profile_data,
            timeout=10
        )
        
        if profile_response.status_code in [200, 201]:
            print(f"✅ User profile created successfully!")
        else:
            print(f"⚠️  Profile creation response: {profile_response.status_code} - {profile_response.text}")
            # Continue anyway, profile is not critical for login
        
        print("\n" + "=" * 60)
        print("✅ SUCCESS! Superadmin user created:")
        print(f"   Username: superadmin")
        print(f"   Password: superadmin123")
        print(f"   Email: superadmin@example.com")
        print(f"   Role: super_admin")
        print(f"   User ID: {user_id}")
        print("=" * 60)
        print("\n📋 Login Credentials:")
        print(f"   Username: superadmin")
        print(f"   Password: superadmin123")
        print("\n💡 You can now use these credentials to login to the smart_admin app")
        print("   and access the 'Register Admin' feature!")
        print("=" * 60)
        
        return True
        
    except requests.exceptions.ConnectionError:
        print("❌ Error: Could not connect to the API server.")
        print("   Make sure the FastAPI server is running on http://localhost:8000")
        print("\n   To start the server, run:")
        print("   cd FastApi")
        print("   python -m uvicorn main:app --reload")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = create_superadmin_via_api()
    if not success:
        print("\n⚠️  Alternative: You can also create the user manually by:")
        print("   1. Start the FastAPI server")
        print("   2. Use the smart_admin app to register a superadmin")
        print("   3. Or use the API endpoint POST /users/ with the superadmin role")

