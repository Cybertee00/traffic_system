#!/usr/bin/env python3
"""
Detailed login test with exact request format
"""

import requests
import json

BASE_URL = "https://smart-license-api-9otw.onrender.com"

def test_exact_request():
    """Test with exact request format"""
    url = f"{BASE_URL}/login"
    
    # Test with exact format Flutter sends
    payload = {
        "username": "pauln",
        "password": "pauln123",
        "role": "instructor"
    }
    
    print("=" * 60)
    print("Testing Login with Exact Request Format")
    print("=" * 60)
    print(f"URL: {url}")
    print(f"Payload: {json.dumps(payload, indent=2)}")
    print()
    
    # Test 1: Normal request
    print("Test 1: Normal JSON request")
    try:
        response = requests.post(
            url,
            json=payload,
            headers={"Content-Type": "application/json"},
            timeout=30
        )
        print(f"Status: {response.status_code}")
        print(f"Response: {response.text}")
        if response.status_code == 200:
            print("✅ SUCCESS!")
            return True
    except Exception as e:
        print(f"Error: {e}")
    
    # Test 2: With explicit JSON encoding
    print("\nTest 2: Explicit JSON encoding")
    try:
        response = requests.post(
            url,
            data=json.dumps(payload),
            headers={"Content-Type": "application/json"},
            timeout=30
        )
        print(f"Status: {response.status_code}")
        print(f"Response: {response.text}")
        if response.status_code == 200:
            print("✅ SUCCESS!")
            return True
    except Exception as e:
        print(f"Error: {e}")
    
    # Test 3: Check what the server expects
    print("\nTest 3: Checking API docs")
    try:
        response = requests.get(f"{BASE_URL}/docs", timeout=30)
        if response.status_code == 200:
            print("✅ API docs available at /docs")
            print("   Visit: https://smart-license-api-9otw.onrender.com/docs")
            print("   Try the login endpoint from there")
    except Exception as e:
        print(f"Error: {e}")
    
    return False

if __name__ == "__main__":
    print("\n🔍 Detailed Login Test\n")
    test_exact_request()
    
    print("\n" + "=" * 60)
    print("💡 Next Steps:")
    print("=" * 60)
    print("1. Check Render logs for detailed error messages")
    print("2. Try login from Swagger UI: https://smart-license-api-9otw.onrender.com/docs")
    print("3. Verify DATABASE_URL in Render matches Supabase")
    print("=" * 60)

