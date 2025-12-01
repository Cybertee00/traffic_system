# Smart License API - FastAPI Backend

A FastAPI-based backend for the Smart License Traffic System.

## 🚀 Features

- User authentication and authorization
- Instructor and learner profile management
- Test booking system
- Station management
- Security questions for password recovery
- RESTful API with automatic documentation

## 🛠 Tech Stack

- **FastAPI** - Modern, fast web framework
- **SQLAlchemy** - ORM for database operations
- **PostgreSQL** - Database (hosted on Supabase)
- **Python 3.11+** - Programming language
- **Uvicorn** - ASGI server

## 📋 Prerequisites

- Python 3.11 or higher
- PostgreSQL database (Supabase recommended)
- pip package manager

## 🔧 Local Development Setup

### 1. Clone the Repository

```bash
git clone https://github.com/Cybertee00/traffic_system.git
cd traffic_system/FastApi
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Configure Environment Variables

Create a `config.env` file (or `.env`) in the `FastApi` directory:

```env
DATABASE_URL=postgresql://user:password@localhost:5432/dbname
```

**Note**: For Supabase, use the connection string from your Supabase project settings.

### 4. Initialize Database

```bash
python init_db.py
```

This will:
- Create all database tables
- Insert default security questions
- Insert default stations

### 5. Run the Development Server

```bash
uvicorn main:app --reload
```

The API will be available at:
- **API**: http://localhost:8000
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## 📚 API Documentation

Once the server is running, you can access:

- **Interactive API Docs (Swagger)**: http://localhost:8000/docs
- **Alternative API Docs (ReDoc)**: http://localhost:8000/redoc

## 🗂 Project Structure

```
FastApi/
├── main.py              # FastAPI application, models, routes
├── db.py                # Database configuration and connection
├── init_db.py           # Database initialization script
├── requirements.txt     # Python dependencies
├── runtime.txt          # Python version specification
├── render.yaml          # Render deployment configuration
├── .gitignore          # Git ignore rules
└── README.md           # This file
```

## 🔑 Key Endpoints

### Authentication
- `POST /login` - User login

### Users
- `POST /users/` - Create user
- `GET /users/{user_id}` - Get user by ID
- `GET /users/{username}` - Get user by username
- `PUT /users/id/{user_id}` - Update user

### Profiles
- `POST /user-profiles/` - Create user profile
- `GET /user-profiles/{user_id}` - Get user profile
- `POST /instructor-profiles/` - Create instructor profile
- `GET /instructor-profiles/` - Get all instructor profiles
- `POST /learner-profiles/` - Create learner profile

### Bookings
- `POST /learner-test-bookings/` - Create test booking
- `GET /learner-test-bookings/` - Get all bookings
- `GET /learner-test-bookings/pending/{date}` - Get pending learners for date
- `PUT /learner-test-bookings/{booking_id}/result` - Update test result

### Stations
- `POST /stations/` - Create station
- `GET /stations/` - Get all stations
- `GET /stations/{station_id}` - Get station by ID

## 🚀 Deployment

For detailed deployment instructions to Render with Supabase, see:
**[DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)**

Quick steps:
1. Create Supabase database
2. Push code to GitHub
3. Deploy to Render
4. Configure environment variables
5. Initialize database

## 🧪 Testing

Test the API using curl or any HTTP client:

```bash
# Test root endpoint
curl http://localhost:8000/

# Test stations endpoint
curl http://localhost:8000/stations/

# Test login
curl -X POST http://localhost:8000/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "password", "role": "admin"}'
```

## 🔒 Security Notes

- Passwords are hashed using bcrypt
- CORS is configured (adjust for production)
- Environment variables should never be committed
- Use HTTPS in production

## 📝 License

This project is part of the Smart License Traffic System.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📞 Support

For issues and questions:
- Check the [Deployment Guide](./DEPLOYMENT_GUIDE.md)
- Review API documentation at `/docs`
- Check Render and Supabase logs

---

**Last Updated**: 2025-01-27

