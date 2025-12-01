# 🚗 Smart License Traffic System

A comprehensive traffic license management system with FastAPI backend and Flutter mobile applications for learners, instructors, and administrators.

## 📋 Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Components](#components)
- [Deployment](#deployment)
- [API Documentation](#api-documentation)
- [Contributing](#contributing)

## 🎯 Overview

The Smart License Traffic System is a complete solution for managing driver's license testing and training. It consists of:

- **FastAPI Backend** - RESTful API for managing users, profiles, bookings, and stations
- **Flutter Learner App** - Mobile application for learners to book tests and track progress
- **Flutter Admin App** - Administrative dashboard for managing instructors, learners, and bookings

## 📁 Project Structure

```
SMART_APP/
├── FastApi/                    # FastAPI backend application
│   ├── main.py                # Main FastAPI application
│   ├── db.py                  # Database configuration
│   ├── init_db.py             # Database initialization
│   ├── requirements.txt       # Python dependencies
│   ├── render.yaml            # Render deployment config
│   ├── DEPLOYMENT_GUIDE.md    # Complete deployment guide
│   └── README.md              # FastAPI documentation
│
├── flutter_app/                # Learner mobile application
│   ├── lib/                   # Dart source code
│   │   ├── main.dart          # App entry point
│   │   ├── pages/             # App screens and pages
│   │   └── config/            # Configuration files
│   ├── android/               # Android platform files
│   ├── ios/                   # iOS platform files
│   └── pubspec.yaml           # Flutter dependencies
│
├── smart_admin/               # Admin mobile application
│   ├── lib/                   # Dart source code
│   │   ├── main.dart          # App entry point
│   │   ├── screens/           # Admin screens
│   │   └── services/          # API services
│   └── pubspec.yaml           # Flutter dependencies
│
└── README.md                  # This file
```

## 🛠 Tech Stack

### Backend
- **FastAPI** - Modern Python web framework
- **SQLAlchemy** - ORM for database operations
- **PostgreSQL** - Database (deployed on Supabase)
- **Python 3.11+** - Programming language
- **Uvicorn** - ASGI server

### Frontend
- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language
- **Provider/Riverpod** - State management (if used)

### Infrastructure
- **Supabase** - PostgreSQL database hosting
- **Render** - Backend API hosting
- **GitHub** - Version control and CI/CD

## 🚀 Getting Started

### Prerequisites

- Python 3.11 or higher
- Flutter SDK (latest stable version)
- PostgreSQL database (Supabase recommended)
- Git

### Backend Setup

1. **Navigate to FastAPI directory:**
   ```bash
   cd FastApi
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

3. **Configure environment:**
   - Copy `config.env.example` to `config.env`
   - Add your database connection string

4. **Initialize database:**
   ```bash
   python init_db.py
   ```

5. **Run the server:**
   ```bash
   uvicorn main:app --reload
   ```

   API will be available at: http://localhost:8000
   API Docs: http://localhost:8000/docs

### Flutter App Setup

1. **Navigate to Flutter app directory:**
   ```bash
   cd flutter_app  # or smart_admin
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Update API configuration:**
   - Edit `lib/config/api_config.dart`
   - Set your backend API URL

4. **Run the app:**
   ```bash
   flutter run
   ```

## 📦 Components

### FastAPI Backend (`FastApi/`)

RESTful API providing endpoints for:
- User authentication and authorization
- User profile management (learners, instructors, admins)
- Test booking system
- Station management
- Security questions for password recovery

**Key Features:**
- Automatic API documentation (Swagger/ReDoc)
- Database migrations
- CORS support
- Password hashing with bcrypt

**See [FastApi/README.md](./FastApi/README.md) for detailed documentation.**

### Flutter Learner App (`flutter_app/`)

Mobile application for learners featuring:
- User registration and login
- Test booking functionality
- Driving test modules (parallel parking, hill start, etc.)
- Progress tracking
- Test result viewing

**Platforms:** Android, iOS, Web, Windows, Linux, macOS

### Flutter Admin App (`smart_admin/`)

Administrative dashboard for managing:
- Instructor management
- Learner management
- Test booking oversight
- Station management
- User registration and activation

**Platforms:** Android, iOS, Web, Windows, Linux, macOS

## 🚀 Deployment

### Backend Deployment (Render + Supabase)

The FastAPI backend can be deployed to Render with Supabase as the database.

**Quick Steps:**
1. Create Supabase database
2. Push code to GitHub
3. Deploy to Render
4. Configure environment variables
5. Initialize database

**For detailed instructions, see:**
- **[FastApi/DEPLOYMENT_GUIDE.md](./FastApi/DEPLOYMENT_GUIDE.md)** - Complete step-by-step guide
- **[FastApi/QUICK_START.md](./FastApi/QUICK_START.md)** - Quick reference
- **[FastApi/DEPLOYMENT_CHECKLIST.md](./FastApi/DEPLOYMENT_CHECKLIST.md)** - Deployment checklist

### Flutter App Deployment

#### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

#### Web
```bash
flutter build web --release
```

## 📚 API Documentation

Once the backend is running, access the interactive API documentation:

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

### Key API Endpoints

#### Authentication
- `POST /login` - User login

#### Users
- `POST /users/` - Create user
- `GET /users/{user_id}` - Get user by ID
- `PUT /users/id/{user_id}` - Update user

#### Profiles
- `POST /instructor-profiles/` - Create instructor profile
- `GET /instructor-profiles/` - Get all instructor profiles
- `POST /learner-profiles/` - Create learner profile
- `GET /learner-profiles/{user_id}` - Get learner profile

#### Bookings
- `POST /learner-test-bookings/` - Create test booking
- `GET /learner-test-bookings/pending/{date}` - Get pending learners
- `PUT /learner-test-bookings/{booking_id}/result` - Update test result

#### Stations
- `GET /stations/` - Get all stations
- `POST /stations/` - Create station

**For complete API documentation, visit `/docs` when the server is running.**

## 🔧 Configuration

### Backend Configuration

Environment variables (set in `config.env` or Render):
- `DATABASE_URL` - PostgreSQL connection string

### Flutter App Configuration

Update API endpoint in:
- `flutter_app/lib/config/api_config.dart`
- `smart_admin/lib/services/api_service.dart`

## 🧪 Testing

### Backend Testing

```bash
# Test root endpoint
curl http://localhost:8000/

# Test stations
curl http://localhost:8000/stations/

# Test login
curl -X POST http://localhost:8000/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "password", "role": "admin"}'
```

### Flutter Testing

```bash
cd flutter_app  # or smart_admin
flutter test
```

## 🔒 Security

- Passwords are hashed using bcrypt
- CORS configured for production
- Environment variables for sensitive data
- HTTPS in production (Render provides automatically)

## 📝 License

This project is part of the Smart License Traffic System.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

For issues and questions:
- Check the [FastAPI Deployment Guide](./FastApi/DEPLOYMENT_GUIDE.md)
- Review API documentation at `/docs`
- Check application logs

## 📄 Additional Documentation

- **[FastApi/README.md](./FastApi/README.md)** - FastAPI backend documentation
- **[FastApi/DEPLOYMENT_GUIDE.md](./FastApi/DEPLOYMENT_GUIDE.md)** - Complete deployment guide
- **[FastApi/QUICK_START.md](./FastApi/QUICK_START.md)** - Quick deployment reference
- **[flutter_app/README.md](./flutter_app/README.md)** - Flutter learner app documentation
- **[smart_admin/README.md](./smart_admin/README.md)** - Flutter admin app documentation

---

**Repository**: [https://github.com/Cybertee00/traffic_system](https://github.com/Cybertee00/traffic_system)

**Last Updated**: 2025-01-27
