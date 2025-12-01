#!/usr/bin/env python3
"""
Keep Alive Script for Render API
Pings the Render endpoint every 10 minutes to prevent it from going to sleep.
"""

import requests
import time
import datetime
import sys
from typing import Optional

# Configuration
RENDER_API_URL = "https://smart-license-api.onrender.com"
PING_INTERVAL = 600  # 10 minutes in seconds
TIMEOUT = 30  # Request timeout in seconds

def ping_endpoint(url: str) -> tuple[bool, Optional[str]]:
    """
    Ping the endpoint and return success status and response message.
    
    Args:
        url: The URL to ping
        
    Returns:
        Tuple of (success: bool, message: str)
    """
    try:
        print(f"[{datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] Pinging {url}...")
        
        response = requests.get(url, timeout=TIMEOUT)
        
        if response.status_code == 200:
            message = f"✅ Success! Status: {response.status_code}"
            return True, message
        else:
            message = f"⚠️  Warning! Status: {response.status_code}"
            return False, message
            
    except requests.exceptions.Timeout:
        message = "❌ Timeout - Server took too long to respond"
        return False, message
    except requests.exceptions.ConnectionError:
        message = "❌ Connection Error - Could not connect to server"
        return False, message
    except requests.exceptions.RequestException as e:
        message = f"❌ Request Error: {str(e)}"
        return False, message
    except Exception as e:
        message = f"❌ Unexpected Error: {str(e)}"
        return False, message

def main():
    """Main function to run the keep-alive service."""
    print("🚀 Keep Alive Service Starting...")
    print(f"📍 Target URL: {RENDER_API_URL}")
    print(f"⏰ Ping Interval: {PING_INTERVAL} seconds ({PING_INTERVAL // 60} minutes)")
    print(f"⏱️  Timeout: {TIMEOUT} seconds")
    print("=" * 60)
    
    ping_count = 0
    success_count = 0
    failure_count = 0
    
    try:
        while True:
            ping_count += 1
            success, message = ping_endpoint(RENDER_API_URL)
            
            if success:
                success_count += 1
            else:
                failure_count += 1
            
            print(f"   {message}")
            print(f"   📊 Stats: Total={ping_count}, Success={success_count}, Failed={failure_count}")
            
            if ping_count == 1:
                print("   🎯 First ping completed! Starting 10-minute interval...")
            
            print("-" * 60)
            
            # Wait for the next ping (except after the first one)
            if ping_count == 1:
                print(f"⏳ Waiting {PING_INTERVAL // 60} minutes until next ping...")
            else:
                print(f"⏳ Waiting {PING_INTERVAL // 60} minutes until next ping...")
            
            time.sleep(PING_INTERVAL)
            
    except KeyboardInterrupt:
        print("\n" + "=" * 60)
        print("🛑 Keep Alive Service Stopped by User")
        print(f"📊 Final Stats:")
        print(f"   Total Pings: {ping_count}")
        print(f"   Successful: {success_count}")
        print(f"   Failed: {failure_count}")
        if ping_count > 0:
            success_rate = (success_count / ping_count) * 100
            print(f"   Success Rate: {success_rate:.1f}%")
        print("👋 Goodbye!")
        sys.exit(0)
    except Exception as e:
        print(f"\n❌ Fatal Error: {str(e)}")
        print("🛑 Keep Alive Service Stopped")
        sys.exit(1)

if __name__ == "__main__":
    main()
