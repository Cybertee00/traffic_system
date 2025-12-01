#!/usr/bin/env python3
"""
Script to create 5 different learners per day from today until November 30, 2025
Each learner will have complete profile data and test bookings
"""

import sys
from datetime import datetime, date, timedelta, timezone
from passlib.context import CryptContext
from db import SessionLocal
from main import User, UserProfile, LearnerProfile, LearnerTestBooking, Station
import random

# Initialize password context
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Configuration
INSTRUCTOR_USER_ID = 4  # Changed from 25 to 4 (existing instructor)
STATION_ID = 1
LEARNERS_PER_DAY = 5
STANDARD_PASSWORD = "password123"

# Sample data for generating realistic profiles
FIRST_NAMES = [
    "John", "Sarah", "Michael", "Emily", "David", "Jessica", "James", "Ashley",
    "Robert", "Amanda", "William", "Melissa", "Richard", "Deborah", "Joseph", "Michelle",
    "Thomas", "Carol", "Christopher", "Amanda", "Charles", "Dorothy", "Daniel", "Nancy",
    "Matthew", "Lisa", "Anthony", "Betty", "Mark", "Helen", "Donald", "Sandra",
    "Steven", "Donna", "Paul", "Carol", "Andrew", "Ruth", "Joshua", "Sharon",
    "Kenneth", "Michelle", "Kevin", "Laura", "Brian", "Sarah", "George", "Kimberly",
    "Timothy", "Deborah"
]

LAST_NAMES = [
    "Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis",
    "Rodriguez", "Martinez", "Hernandez", "Lopez", "Wilson", "Anderson", "Thomas", "Taylor",
    "Moore", "Jackson", "Martin", "Lee", "Thompson", "White", "Harris", "Sanchez",
    "Clark", "Ramirez", "Lewis", "Robinson", "Walker", "Young", "Allen", "King",
    "Wright", "Scott", "Torres", "Nguyen", "Hill", "Flores", "Green", "Adams",
    "Nelson", "Baker", "Hall", "Rivera", "Campbell", "Mitchell", "Carter", "Roberts"
]

NATIONALITIES = ["South African", "Zimbabwean", "Mozambican", "Botswanan", "Lesotho"]
GENDERS = ["Male", "Female"]
RACES = ["Black", "White", "Coloured", "Indian/Asian"]
LICENSE_CODES = ["Code 8", "Code 10", "Code 14"]

# Addresses in South Africa
ADDRESSES = [
    "123 Main Street, Johannesburg, 2000",
    "456 Park Avenue, Cape Town, 8001",
    "789 Victoria Road, Durban, 4001",
    "321 Nelson Mandela Street, Pretoria, 0002",
    "654 Freedom Way, Port Elizabeth, 6001",
    "987 Market Street, Bloemfontein, 9301",
    "147 Union Road, East London, 5201",
    "258 Commerce Street, Pietermaritzburg, 3201",
    "369 High Street, Nelspruit, 1200",
    "741 Business Park, Polokwane, 0700"
]

def generate_id_number(date_of_birth, gender):
    """Generate a realistic South African ID number"""
    # Format: YYMMDD G SSSS C A Z
    # YYMMDD - Date of birth
    # G - Gender (0-4 = female, 5-9 = male)
    # SSSS - Sequence number
    # C - Citizenship (0 = SA, 1 = other)
    # A - Race (not used in new IDs)
    # Z - Checksum
    
    year_short = date_of_birth.year % 100
    month = date_of_birth.month
    day = date_of_birth.day
    
    # Gender digit
    gender_digit = random.randint(5, 9) if gender == "Male" else random.randint(0, 4)
    
    # Sequence number
    sequence = random.randint(1000, 9999)
    
    # Citizenship (0 for SA)
    citizenship = 0
    
    # Checksum (simplified)
    checksum = random.randint(0, 9)
    
    id_num = f"{year_short:02d}{month:02d}{day:02d}{gender_digit}{sequence}{citizenship}8{checksum}"
    return id_num

def generate_phone_number():
    """Generate a South African phone number"""
    area_codes = ["082", "083", "084", "072", "073", "074", "081", "061"]
    return f"{random.choice(area_codes)}{random.randint(1000000, 9999999)}"

def create_learner_for_date(db, test_date, learner_number):
    """Create a complete learner with all required data for a specific test date"""
    try:
        # Generate unique data
        first_name = random.choice(FIRST_NAMES)
        last_name = random.choice(LAST_NAMES)
        gender = random.choice(GENDERS)
        nationality = random.choice(NATIONALITIES)
        race = random.choice(RACES)
        
        # Generate date of birth (18-65 years old)
        birth_year = random.randint(1959, 2006)
        birth_month = random.randint(1, 12)
        birth_day = random.randint(1, 28)
        date_of_birth = date(birth_year, birth_month, birth_day)
        
        # Generate unique username and email
        username = f"learner.{test_date.strftime('%Y%m%d')}.{learner_number}"
        email = f"{username}@test.com"
        
        # Generate ID number
        id_number = generate_id_number(date_of_birth, gender)
        
        # Check if ID number already exists
        existing_profile = db.query(UserProfile).filter(UserProfile.id_number == id_number).first()
        if existing_profile:
            # Add random suffix to make it unique
            id_number = f"{id_number[:9]}{random.randint(10, 99)}"
        
        # Generate other fields
        contact_number = generate_phone_number()
        physical_address = random.choice(ADDRESSES)
        license_code = random.choice(LICENSE_CODES)
        
        # Create User
        password_hash = pwd_context.hash(STANDARD_PASSWORD)
        user = User(
            username=username,
            password=password_hash,
            email=email,
            role="learner",
            is_active=True
        )
        db.add(user)
        db.flush()  # Get the user ID
        
        # Create UserProfile
        user_profile = UserProfile(
            user_id=user.id,
            name=first_name,
            surname=last_name,
            date_of_birth=date_of_birth,
            gender=gender,
            nationality=nationality,
            id_number=id_number,
            contact_number=contact_number,
            physical_address=physical_address,
            race=race
        )
        db.add(user_profile)
        
        # Create LearnerProfile
        learner_profile = LearnerProfile(
            user_id=user.id,
            test_booking_date=test_date,
            learner_status="pending",
            registered_on=datetime.now(timezone.utc),
            license_code=license_code
        )
        db.add(learner_profile)
        
        # Create LearnerTestBooking
        test_booking = LearnerTestBooking(
            learner_id=user.id,
            instructor_id=INSTRUCTOR_USER_ID,
            station_id=STATION_ID,
            test_date=test_date,
            result="pending",
            license_code=license_code,
            registered_on=datetime.now(timezone.utc)
        )
        db.add(test_booking)
        
        print(f"✅ Created learner: {first_name} {last_name} (ID: {user.id}) for {test_date.strftime('%Y-%m-%d')}")
        return user.id
        
    except Exception as e:
        print(f"❌ Error creating learner for {test_date}: {e}")
        db.rollback()
        return None

def main():
    """Main function to create learners for all days until November 30"""
    print("🚀 Starting learner data generation...")
    print(f"📅 Generating {LEARNERS_PER_DAY} learners per day until November 30, 2025")
    print(f"👨‍🏫 Instructor ID: {INSTRUCTOR_USER_ID}")
    print(f"📍 Station ID: {STATION_ID}")
    print("=" * 60)
    
    db = SessionLocal()
    
    try:
        # Verify instructor exists
        instructor_profile = db.query(UserProfile).filter(UserProfile.user_id == INSTRUCTOR_USER_ID).first()
        if not instructor_profile:
            print(f"⚠️  Warning: Instructor with user_id={INSTRUCTOR_USER_ID} not found!")
            print("   Creating learners anyway, but bookings will fail if instructor doesn't exist.")
        
        # Verify station exists
        station = db.query(Station).filter(Station.station_id == STATION_ID).first()
        if not station:
            print(f"⚠️  Warning: Station with station_id={STATION_ID} not found!")
            print("   Please create the station first.")
            return
        
        # Calculate date range
        today = date.today()
        end_date = date(2025, 11, 30)
        
        if today > end_date:
            print(f"⚠️  Today ({today}) is after November 30, 2025. No learners will be created.")
            return
        
        print(f"📆 Date range: {today} to {end_date}")
        print(f"📊 Total days: {(end_date - today).days + 1}")
        print(f"👥 Total learners to create: {(end_date - today).days + 1} days × {LEARNERS_PER_DAY} = {((end_date - today).days + 1) * LEARNERS_PER_DAY}")
        print("=" * 60)
        
        total_created = 0
        current_date = today
        
        # Create learners for each day
        while current_date <= end_date:
            print(f"\n📅 Creating learners for {current_date.strftime('%Y-%m-%d')}...")
            
            for learner_num in range(1, LEARNERS_PER_DAY + 1):
                learner_id = create_learner_for_date(db, current_date, learner_num)
                if learner_id:
                    total_created += 1
            
            # Commit after each day
            db.commit()
            print(f"✅ Completed {current_date.strftime('%Y-%m-%d')} - {LEARNERS_PER_DAY} learners created")
            
            # Move to next day
            current_date += timedelta(days=1)
        
        print("\n" + "=" * 60)
        print(f"✅ SUCCESS! Created {total_created} learners across {(end_date - today).days + 1} days")
        print(f"📝 All learners have password: '{STANDARD_PASSWORD}'")
        print(f"📧 Username format: learner.YYYYMMDD.N (e.g., learner.20241101.1)")
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    main()

