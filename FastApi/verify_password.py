#!/usr/bin/env python3
"""
Verify if password hash matches the password
"""

from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# The hash from the database
stored_hash = "$2b$12$PnvuXE8z3HMOfDUextPCBeLaDjYFq1jFnStss67IPUSTdRWWBypV6"
test_password = "pauln123"

print("Testing password verification...")
print(f"Stored hash: {stored_hash}")
print(f"Test password: {test_password}")
print()

# Try bcrypt verification
try:
    result = pwd_context.verify(test_password, stored_hash)
    print(f"✅ Bcrypt verification: {result}")
except Exception as e:
    print(f"❌ Bcrypt verification failed: {e}")

# Try simple hash (fallback)
import hashlib
simple_hash = hashlib.sha256(test_password.encode()).hexdigest()
print(f"Simple hash: {simple_hash}")
print(f"Hash matches stored: {simple_hash == stored_hash}")

# Generate new hash
new_hash = pwd_context.hash(test_password)
print(f"\nNew hash for 'pauln123': {new_hash}")

