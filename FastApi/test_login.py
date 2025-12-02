#!/usr/bin/env python3
"""
Test login endpoint to debug authentication issues
"""

import requests
import json

# Your Render server URL
BASE_URL = "https://smart-license-api-9otw.onrender.com"

def test_login(username, password, role="instructor"):
    """Test login with given credentials"""
    url = f"{BASE_URL}/login"
    
    payload = {
        "username": username,
        "password": password,
        "role": role
    }
    
    print(f"\n{'='*60}")
    print(f"Testing Login")
    print(f"{'='*60}")
    print(f"URL: {url}")
    print(f"Username: {username}")
    print(f"Password: {'*' * len(password)}")
    print(f"Role: {role}")
    print(f"{'='*60}\n")
    
    try:
        response = requests.post(
            url,
            json=payload,
            headers={"Content-Type": "application/json"},
            timeout=30
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response Headers: {dict(response.headers)}")
        print(f"\nResponse Body:")
        print(f"{response.text}\n")
        
        if response.status_code == 200:
            data = response.json()
            print("✅ LOGIN SUCCESSFUL!")
            print(f"   User ID: {data.get('userid')}")
            print(f"   Username: {data.get('username')}")
            print(f"   Role: {data.get('role')}")
            print(f"   Email: {data.get('email')}")
            return True
        else:
            print(f"❌ LOGIN FAILED")
            try:
                error_data = response.json()
                print(f"   Error: {error_data.get('detail', 'Unknown error')}")
            except:
                print(f"   Error: {response.text}")
            return False
            
    except requests.exceptions.Timeout:
        print("❌ Request timed out (server might be spinning up)")
        print("   This is normal for Render free tier - wait 30 seconds and try again")
        return False
    except requests.exceptions.ConnectionError:
        print("❌ Connection error - could not reach server")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def test_root():
    """Test if server is online"""
    print(f"\n{'='*60}")
    print(f"Testing Server Connection")
    print(f"{'='*60}")
    try:
        response = requests.get(BASE_URL, timeout=30)
        print(f"Status: {response.status_code}")
        print(f"Response: {response.text}")
        return response.status_code == 200
    except Exception as e:
        print(f"❌ Server not reachable: {e}")
        return False

if __name__ == "__main__":
    print("\n🔍 Testing Render API Login\n")
    
    # First test if server is online
    if not test_root():
        print("\n⚠️  Server might be spinning up. Wait 30 seconds and try again.")
        exit(1)
    
    # Test login with pauln
    print("\n" + "="*60)
    print("TEST 1: Login with pauln / pauln123")
    print("="*60)
    test_login("pauln", "pauln123", "instructor")
    
    # Test with different role
    print("\n" + "="*60)
    print("TEST 2: Login with pauln / pauln123 (role: admin)")
    print("="*60)
    test_login("pauln", "pauln123", "admin")
    
    print("\n" + "="*60)
    print("Testing Complete")
    print("="*60)

