#!/usr/bin/env python3
"""
Complete database setup script:
1. Initialize database tables
2. Create instructor: Paul Ntsinyi (username: pauln)
3. Create learners with test bookings: 3 per day from tomorrow until end of February
"""

import sys
from datetime import datetime, date, timedelta, timezone
from passlib.context import CryptContext
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from db import Base, DATABASE_URL
from main import (
    User, UserProfile, InstructorProfile, LearnerProfile, 
    LearnerTestBooking, Station, SecurityQuestion
)
import random

# Initialize password context
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Configuration
INSTRUCTOR_USERNAME = "pauln"
INSTRUCTOR_NAME = "Paul"
INSTRUCTOR_SURNAME = "Ntsinyi"
INSTRUCTOR_PASSWORD = "pauln123"  # Change this to a secure password
INSTRUCTOR_EMAIL = "paul.ntsinyi@smart.test"
INSTRUCTOR_INF_NR = "INF-001"  # Instructor number
STATION_ID = 1  # Will use first station, or create if doesn't exist
LEARNERS_PER_DAY = 3

# Sample data for generating realistic profiles
FIRST_NAMES = [
    "John", "Sarah", "Michael", "Emily", "David", "Jessica", "James", "Ashley",
    "Robert", "Amanda", "William", "Melissa", "Richard", "Deborah", "Joseph", "Michelle",
    "Thomas", "Carol", "Christopher", "Amanda", "Charles", "Dorothy", "Daniel", "Nancy",
    "Matthew", "Lisa", "Anthony", "Betty", "Mark", "Helen", "Donald", "Sandra",
    "Steven", "Donna", "Andrew", "Ruth", "Joshua", "Sharon", "Kenneth", "Michelle",
    "Kevin", "Laura", "Brian", "Sarah", "George", "Kimberly", "Timothy", "Deborah"
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
    year_short = date_of_birth.year % 100
    month = date_of_birth.month
    day = date_of_birth.day
    gender_digit = random.randint(5, 9) if gender == "Male" else random.randint(0, 4)
    sequence = random.randint(1000, 9999)
    checksum = random.randint(0, 9)
    id_num = f"{year_short:02d}{month:02d}{day:02d}{gender_digit}{sequence}08{checksum}"
    return id_num

def generate_phone_number():
    """Generate a South African phone number"""
    area_codes = ["082", "083", "084", "072", "073", "074", "081", "061"]
    return f"{random.choice(area_codes)}{random.randint(1000000, 9999999)}"

def init_database_tables(engine, db):
    """Initialize database tables and default data"""
    print("\n" + "=" * 60)
    print("📊 STEP 1: Initializing Database Tables")
    print("=" * 60)
    
    try:
        # Create all tables
        print("Creating database tables...")
        Base.metadata.create_all(bind=engine)
        print("✅ Database tables created successfully!")
        
        # Insert default stations if they don't exist
        print("\nInserting default stations...")
        default_stations = [
            {"name": "Main Station", "num_grounds": 5},
            {"name": "North Station", "num_grounds": 3},
            {"name": "South Station", "num_grounds": 4},
            {"name": "East Station", "num_grounds": 2},
            {"name": "West Station", "num_grounds": 3},
        ]
        
        for station_data in default_stations:
            existing_station = db.query(Station).filter(Station.name == station_data["name"]).first()
            if not existing_station:
                station = Station(**station_data)
                db.add(station)
                print(f"  ✅ Added station: {station_data['name']}")
            else:
                print(f"  ⚠️  Station already exists: {station_data['name']}")
        
        # Insert default security questions if they don't exist
        print("\nInserting default security questions...")
        default_questions = [
            "What is the name of your first pet?",
            "What was the model of your first car?",
            "In what city were you born?",
            "What is your mother's maiden name?",
            "What is the name of the street you grew up?",
            "What is the name of your primary school?"
        ]
        
        for question_text in default_questions:
            existing_question = db.query(SecurityQuestion).filter(SecurityQuestion.question == question_text).first()
            if not existing_question:
                question = SecurityQuestion(question=question_text)
                db.add(question)
                print(f"  ✅ Added question: {question_text}")
            else:
                print(f"  ⚠️  Question already exists: {question_text}")
        
        db.commit()
        print("\n✅ Database initialization completed!")
        return True
        
    except Exception as e:
        print(f"❌ Error initializing database: {e}")
        import traceback
        traceback.print_exc()
        db.rollback()
        return False

def create_instructor(db):
    """Create instructor Paul Ntsinyi with complete profile"""
    print("\n" + "=" * 60)
    print("👨‍🏫 STEP 2: Creating Instructor")
    print("=" * 60)
    
    try:
        # Check if instructor already exists
        existing_user = db.query(User).filter(User.username == INSTRUCTOR_USERNAME).first()
        if existing_user:
            print(f"⚠️  Instructor user already exists: {INSTRUCTOR_USERNAME} (ID: {existing_user.id})")
            
            # Check if profile exists
            profile = db.query(UserProfile).filter(UserProfile.user_id == existing_user.id).first()
            instructor_profile = db.query(InstructorProfile).filter(InstructorProfile.user_id == existing_user.id).first()
            
            if profile and instructor_profile:
                print(f"✅ Instructor profile complete:")
                print(f"   Name: {profile.name} {profile.surname}")
                print(f"   Instructor Number: {instructor_profile.inf_nr}")
                print(f"   Station ID: {instructor_profile.station_id}")
                return existing_user.id
            else:
                print("⚠️  User exists but profile incomplete. Creating profile...")
                user_id = existing_user.id
        else:
            # Create new instructor user
            print(f"📝 Creating instructor user: {INSTRUCTOR_USERNAME}")
            password_hash = pwd_context.hash(INSTRUCTOR_PASSWORD)
            
            instructor_user = User(
                username=INSTRUCTOR_USERNAME,
                password=password_hash,
                email=INSTRUCTOR_EMAIL,
                role="instructor",
                is_active=True
            )
            db.add(instructor_user)
            db.flush()
            user_id = instructor_user.id
            print(f"✅ Created instructor user (ID: {user_id})")
        
        # Create or update UserProfile
        user_profile = db.query(UserProfile).filter(UserProfile.user_id == user_id).first()
        if not user_profile:
            print("📝 Creating user profile...")
            user_profile = UserProfile(
                user_id=user_id,
                name=INSTRUCTOR_NAME,
                surname=INSTRUCTOR_SURNAME,
                date_of_birth=date(1985, 5, 15),  # Example DOB
                gender="Male",
                nationality="South African",
                id_number="8505155800081",
                contact_number="0821234567",
                physical_address="123 Instructor Street, Pretoria, 0001",
                race="Black"
            )
            db.add(user_profile)
            print("✅ Created user profile")
        else:
            print("✅ User profile already exists")
        
        # Create or update InstructorProfile
        instructor_profile = db.query(InstructorProfile).filter(InstructorProfile.user_id == user_id).first()
        if not instructor_profile:
            # Get or create station
            station = db.query(Station).filter(Station.station_id == STATION_ID).first()
            if not station:
                print(f"⚠️  Station {STATION_ID} not found. Using first available station...")
                station = db.query(Station).first()
                if not station:
                    print("❌ No stations available. Please run init_db.py first.")
                    return None
                actual_station_id = station.station_id
            else:
                actual_station_id = STATION_ID
            
            print(f"📝 Creating instructor profile (Station ID: {actual_station_id})...")
            instructor_profile = InstructorProfile(
                user_id=user_id,
                inf_nr=INSTRUCTOR_INF_NR,
                station_id=actual_station_id
            )
            db.add(instructor_profile)
            print("✅ Created instructor profile")
        else:
            print("✅ Instructor profile already exists")
        
        db.commit()
        
        print("\n" + "=" * 60)
        print("✅ INSTRUCTOR CREATED SUCCESSFULLY!")
        print("=" * 60)
        print(f"   Username: {INSTRUCTOR_USERNAME}")
        print(f"   Password: {INSTRUCTOR_PASSWORD}")
        print(f"   Name: {INSTRUCTOR_NAME} {INSTRUCTOR_SURNAME}")
        print(f"   Email: {INSTRUCTOR_EMAIL}")
        print(f"   Instructor Number: {INSTRUCTOR_INF_NR}")
        print(f"   User ID: {user_id}")
        print("=" * 60)
        
        return user_id
        
    except Exception as e:
        print(f"❌ Error creating instructor: {e}")
        import traceback
        traceback.print_exc()
        db.rollback()
        return None

def create_learner_for_date(db, instructor_id, test_date, learner_number):
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
            id_number = f"{id_number[:9]}{random.randint(10, 99)}"
        
        # Generate other fields
        contact_number = generate_phone_number()
        physical_address = random.choice(ADDRESSES)
        license_code = random.choice(LICENSE_CODES)
        
        # Create User
        password_hash = pwd_context.hash("password123")
        user = User(
            username=username,
            password=password_hash,
            email=email,
            role="learner",
            is_active=True
        )
        db.add(user)
        db.flush()
        
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
        
        # Get station ID
        station = db.query(Station).filter(Station.station_id == STATION_ID).first()
        if not station:
            station = db.query(Station).first()
        
        # Create LearnerTestBooking
        test_booking = LearnerTestBooking(
            learner_id=user.id,
            instructor_id=instructor_id,
            station_id=station.station_id if station else 1,
            test_date=test_date,
            result="pending",
            license_code=license_code,
            registered_on=datetime.now(timezone.utc)
        )
        db.add(test_booking)
        
        return user.id
        
    except Exception as e:
        print(f"❌ Error creating learner for {test_date}: {e}")
        import traceback
        traceback.print_exc()
        return None

def create_learners(db, instructor_id):
    """Create learners with test bookings from tomorrow until end of February"""
    print("\n" + "=" * 60)
    print("👥 STEP 3: Creating Learners and Test Bookings")
    print("=" * 60)
    
    try:
        # Calculate date range - always use 2025 dates
        today = date.today()
        tomorrow = today + timedelta(days=1)
        
        # If we're past Feb 2025, use next year's dates
        if today.year > 2025 or (today.year == 2025 and today.month > 2):
            # Use next year's February
            end_date = date(today.year + 1, 2, 28)
            start_date = date(today.year + 1, 1, 28) if today.month > 2 else tomorrow
        else:
            # Use 2025 dates
            if today.month == 12:  # December 2025
                # Start from January 2026
                start_date = date(2026, 1, 28)
                end_date = date(2026, 2, 28)
            else:
                # Use 2025 dates
                start_date = tomorrow if today.year == 2025 else date(2025, 1, 28)
                end_date = date(2025, 2, 28)
        
        if start_date > end_date:
            print(f"⚠️  Start date ({start_date}) is after end date ({end_date}). No learners will be created.")
            return 0
        
        total_days = (end_date - start_date).days + 1
        total_learners = total_days * LEARNERS_PER_DAY
        
        print(f"📅 Date range: {start_date} to {end_date}")
        print(f"📊 Total days: {total_days}")
        print(f"👥 Total learners to create: {total_learners}")
        print(f"👨‍🏫 Instructor ID: {instructor_id}")
        print("=" * 60)
        
        total_created = 0
        current_date = start_date
        
        # Create learners for each day
        while current_date <= end_date:
            print(f"\n📅 Creating learners for {current_date.strftime('%Y-%m-%d')}...")
            
            for learner_num in range(1, LEARNERS_PER_DAY + 1):
                learner_id = create_learner_for_date(db, instructor_id, current_date, learner_num)
                if learner_id:
                    total_created += 1
            
            # Commit after each day
            db.commit()
            print(f"✅ Completed {current_date.strftime('%Y-%m-%d')} - {LEARNERS_PER_DAY} learners created")
            
            # Move to next day
            current_date += timedelta(days=1)
        
        print("\n" + "=" * 60)
        print(f"✅ SUCCESS! Created {total_created} learners across {total_days} days")
        print(f"📝 All learners have password: 'password123'")
        print(f"📧 Username format: learner.YYYYMMDD.N (e.g., learner.20250128.1)")
        print("=" * 60)
        
        return total_created
        
    except Exception as e:
        print(f"\n❌ Error creating learners: {e}")
        import traceback
        traceback.print_exc()
        db.rollback()
        return 0

def main():
    """Main function to set up complete database"""
    print("\n" + "=" * 60)
    print("🚀 SMART LICENSE SYSTEM - COMPLETE DATABASE SETUP")
    print("=" * 60)
    print("This script will:")
    print("  1. Initialize database tables and default data")
    print("  2. Create instructor: Paul Ntsinyi (username: pauln)")
    print("  3. Create learners with test bookings (3 per day until end of Feb)")
    print("=" * 60)
    
    # Create engine and session
    try:
        print(f"\n🔌 Connecting to database...")
        if not DATABASE_URL:
            print("❌ DATABASE_URL not set! Please set it as environment variable or in config.env")
            sys.exit(1)
        
        # Show masked connection string
        masked_url = DATABASE_URL.split('@')[0].split(':')[-1] + '@' + DATABASE_URL.split('@')[1] if '@' in DATABASE_URL else DATABASE_URL[:50]
        print(f"📡 Connecting to: {masked_url}...")
        
        engine = create_engine(DATABASE_URL, pool_pre_ping=True, connect_args={"connect_timeout": 10})
        SessionLocal = sessionmaker(bind=engine)
        db = SessionLocal()
        print("✅ Connected successfully!")
    except Exception as e:
        print(f"❌ Failed to connect to database: {e}")
        print(f"   DATABASE_URL: {DATABASE_URL[:80] if DATABASE_URL else 'NOT SET'}...")
        import traceback
        traceback.print_exc()
        sys.exit(1)
    
    try:
        # Step 1: Initialize database
        if not init_database_tables(engine, db):
            print("❌ Database initialization failed. Exiting.")
            return
        
        # Step 2: Create instructor
        instructor_id = create_instructor(db)
        if not instructor_id:
            print("❌ Instructor creation failed. Exiting.")
            return
        
        # Step 3: Create learners
        total_learners = create_learners(db, instructor_id)
        
        print("\n" + "=" * 60)
        print("🎉 DATABASE SETUP COMPLETE!")
        print("=" * 60)
        print(f"✅ Instructor created: {INSTRUCTOR_USERNAME}")
        print(f"✅ Learners created: {total_learners}")
        print("\n📋 Login Credentials:")
        print(f"   Instructor Username: {INSTRUCTOR_USERNAME}")
        print(f"   Instructor Password: {INSTRUCTOR_PASSWORD}")
        print(f"   Learner Password (all): password123")
        print("=" * 60)
        
    except Exception as e:
        print(f"\n❌ Fatal error: {e}")
        import traceback
        traceback.print_exc()
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    main()

