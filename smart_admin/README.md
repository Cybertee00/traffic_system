# SMART - System for Motorists Automated Road Testing

A comprehensive admin application for managing the SMART (System for Motorists Automated Road Testing) system. This Flutter application provides a clean separation between frontend and backend components.

## Features

### 1. Login System
- **Username/Password Authentication**: Secure login with role-based access
- **Forgot Password**: Password reset functionality
- **Sign Up**: Registration for new users
- **Demo Credentials**:
  - Admin: `admin` / `admin123`
  - Instructor: `instructor` / `instructor123`

### 2. Dashboard
- **Graphical Statistics**: Visual representation of system data
- **User Management**: Overview of all registered users
  - Admins
  - Instructors
  - Learners
- **Testing Stations**: Active and inactive station tracking
- **Report Analytics**:
  - Total reports generated
  - Monthly report statistics
  - Pass/fail rates
  - Provincial breakdown
- **Quick Actions**: Easy access to common tasks

### 3. Registration System
- **Instructor Registration**: Comprehensive form with all required fields
- **Data Validation**: South African ID and phone number validation
- **OTP System**: SMS-based verification for initial password
- **Permission-based Access**: Role-based registration permissions

### 4. Instructor Management
- **View Instructors**: List all registered instructors
- **Search & Filter**: Find instructors by name, INF number, or status
- **Status Management**: Activate/deactivate instructors
- **Detailed View**: Complete instructor information
- **Edit Functionality**: Update instructor details

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── screens/                  # Frontend UI Components
│   ├── login_screen.dart     # Login page
│   ├── dashboard_screen.dart # Dashboard with statistics
│   ├── registration_screen.dart # Instructor registration
│   └── instructor_management_screen.dart # Instructor management
├── services/                 # Backend Services
│   ├── auth_service.dart     # Authentication logic
│   ├── api_service.dart      # API communication
│   └── navigation_service.dart # Route management
└── utils/                    # Utilities
    └── app_theme.dart        # App theming and colors
```

## Backend Integration

The app is designed with a clean separation between frontend and backend:

### API Service (`lib/services/api_service.dart`)
- **Authentication**: Login, password reset
- **Dashboard Data**: Statistics and analytics
- **Instructor Management**: CRUD operations
- **Validation**: South African ID and phone validation

### Authentication Service (`lib/services/auth_service.dart`)
- **Session Management**: User authentication state
- **Role-based Access**: Permission checking
- **Demo Mode**: Local authentication for testing

## Data Models

### Instructor Registration Fields
1. **Name** (required)
2. **Surname** (required)
3. **Date of Birth** (datetime picker)
4. **Gender** (Male/Female/Other)
5. **Nationality** (dropdown)
6. **Race** (dropdown)
7. **ID Number** (13-digit South African validation)
8. **Contact Number** (South African phone validation)
9. **Physical Address** (required)
10. **INF Number** (required)

## Validation Rules

### South African ID Number
- Must be exactly 13 digits
- Date portion validation (YYMMDD)
- Format: YYMMDD 0000 000

### South African Phone Number
- Format: +27XXXXXXXXX or 0XXXXXXXXX
- Length validation for both formats

## Installation & Setup

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run the Application**:
   ```bash
   flutter run
   ```

3. **Demo Mode**:
   - Use the provided demo credentials
   - All data is simulated for demonstration
   - No actual backend connection required

## Backend API Endpoints

The app is designed to work with these API endpoints:

### Authentication
- `POST /auth/login` - User login
- `POST /auth/forgot-password` - Password reset

### Dashboard
- `GET /dashboard/stats` - Dashboard statistics

### Instructor Management
- `GET /instructors` - List all instructors
- `POST /instructors` - Register new instructor
- `PUT /instructors/{id}` - Update instructor
- `PATCH /instructors/{id}/status` - Toggle status

## Security Features

- **Role-based Access Control**: Different permissions for admins and instructors
- **Input Validation**: Comprehensive form validation
- **Secure Authentication**: Token-based authentication (ready for implementation)
- **Data Protection**: Sensitive data handling

## Future Enhancements

1. **Real Backend Integration**: Connect to actual API endpoints
2. **Database Integration**: Persistent data storage
3. **Push Notifications**: Real-time updates
4. **Offline Support**: Local data caching
5. **Advanced Analytics**: Detailed reporting features
6. **Multi-language Support**: Internationalization
7. **Dark Mode**: Theme customization

## Contributing

1. Follow the existing code structure
2. Maintain separation between frontend and backend
3. Add proper validation for all forms
4. Include error handling for API calls
5. Test thoroughly before submitting

## License

This project is developed for the Traffic Department's SMART system administration.
