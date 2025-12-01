import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_admin/utils/app_theme.dart';
import 'package:smart_admin/services/api_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _physicalAddressController = TextEditingController();
  final _infrNumberController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  
  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedNationality;
  String? _selectedRace;
  String? _selectedStationId;
  bool _isLoading = false;

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _nationalities = [
    'South African', 'Zimbabwean', 'Mozambican', 'Malawian', 'Zambian', 'Other'
  ];
  final List<String> _races = [
    'Black African', 'Coloured', 'Indian/Asian', 'White', 'Other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _idNumberController.dispose();
    _contactNumberController.dispose();
    _physicalAddressController.dispose();
    _infrNumberController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  bool _validateSouthAfricanID(String id) {
    if (id.length != 13) return false;
    
    // Check if all characters are digits
    if (!RegExp(r'^\d{13}$').hasMatch(id)) return false;
    
    // Validate date part (YYMMDD)
    final month = int.parse(id.substring(2, 4));
    final day = int.parse(id.substring(4, 6));
    
    if (month < 1 || month > 12) return false;
    if (day < 1 || day > 31) return false;
    
    return true;
  }

  bool _validateSouthAfricanPhone(String phone) {
    // Remove spaces and dashes
    final cleanPhone = phone.replaceAll(RegExp(r'[\s-]'), '');
    
    // Check if it starts with +27 or 0
    if (cleanPhone.startsWith('+27')) {
      return cleanPhone.length == 12;
    } else if (cleanPhone.startsWith('0')) {
      return cleanPhone.length == 10;
    }
    
    return false;
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your date of birth'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your gender'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    if (_selectedNationality == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your nationality'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    if (_selectedRace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your race'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    if (_selectedStationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a station ID'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Step 1: Validate station exists
      final stationId = int.parse(_selectedStationId!);
      final isStationValid = await ApiService.validateStation(stationId);
      
      if (!isStationValid) {
        throw Exception('Selected station does not exist');
      }

      // Step 2: Create user account
      final userResult = await ApiService.createUser(
        username: _usernameController.text,
        password: _passwordController.text,
        email: _emailController.text,
        role: 'instructor',
        isActive: true,
      );

      if (!userResult['success']) {
        throw Exception(userResult['message']);
      }

      // Get the actual user ID from the created user
      final actualUserId = userResult['user_id'];
      print('Extracted user ID: $actualUserId');
      print('User result: $userResult');
      print('User ID type: ${actualUserId.runtimeType}');
      print('User ID value: $actualUserId');

      // Step 3: Create user profile FIRST
      print('About to create user profile with user ID: $actualUserId');
      final dateOfBirth = '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
      print('Date of birth: $dateOfBirth');
      
      final userProfileResult = await ApiService.createUserProfile(
        userId: actualUserId,
        name: _nameController.text,
        surname: _surnameController.text,
        dateOfBirth: dateOfBirth,
        gender: _selectedGender!,
        nationality: _selectedNationality!,
        idNumber: _idNumberController.text,
        contactNumber: _contactNumberController.text,
        physicalAddress: _physicalAddressController.text,
        race: _selectedRace!,
      );

      print('User profile result: $userProfileResult');
      if (!userProfileResult['success']) {
        throw Exception(userProfileResult['message']);
      }

      // Step 4: Create instructor profile AFTER user profile exists
      print('About to create instructor profile with user ID: $actualUserId');
      print('Station ID: $stationId');
      print('INF Number: ${_infrNumberController.text}');
      final instructorResult = await ApiService.createInstructorProfile(
        userId: actualUserId,
        infNr: _infrNumberController.text,
        stationId: stationId,
      );

      print('Instructor profile result: $instructorResult');
      if (!instructorResult['success']) {
        throw Exception(instructorResult['message']);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show success dialog
        _showSuccessDialog();
      }
    } catch (e) {
      print('Exception caught in _handleSubmit: $e');
      print('Exception type: ${e.runtimeType}');
      if (e is Exception) {
        print('Exception message: ${e.toString()}');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Registration Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              size: 48,
              color: AppTheme.successColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'Instructor has been registered successfully!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'The instructor can now log in using their username and password.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Instructor registered successfully!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          children: [
            Icon(Icons.person_add, size: 24),
            SizedBox(width: 12),
            Text('Register Instructor'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Instructor Registration',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Register a new instructor for the SMART system',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Personal Information
              _buildSectionCard(
                title: 'Personal Information',
                icon: Icons.person,
                children: [

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name *',
                        hintText: 'Enter first name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _surnameController,
                      decoration: const InputDecoration(
                        labelText: 'Surname *',
                        hintText: 'Enter surname',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your surname';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Date of Birth
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[50],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? 'Date of Birth *'
                            : 'Date of Birth: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        style: TextStyle(
                          color: _selectedDate == null ? Colors.grey[600] : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Gender and Nationality
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Gender *',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      items: _genders.map((gender) {
                        return DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select gender';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedNationality,
                      decoration: const InputDecoration(
                        labelText: 'Nationality *',
                        prefixIcon: Icon(Icons.flag),
                      ),
                      items: _nationalities.map((nationality) {
                        return DropdownMenuItem(
                          value: nationality,
                          child: Text(nationality),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedNationality = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select nationality';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Race
              DropdownButtonFormField<String>(
                initialValue: _selectedRace,
                decoration: const InputDecoration(
                  labelText: 'Race *',
                  prefixIcon: Icon(Icons.people),
                ),
                items: _races.map((race) {
                  return DropdownMenuItem(
                    value: race,
                    child: Text(race),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRace = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select race';
                  }
                  return null;
                },
              ),
              ]),
              const SizedBox(height: 4),

              // Contact Information
              _buildSectionCard(
                title: 'Contact Information',
                icon: Icons.contact_mail,
                children: [

              // ID Number
              TextFormField(
                controller: _idNumberController,
                decoration: const InputDecoration(
                  labelText: 'ID Number *',
                  hintText: 'Enter 13-digit South African ID',
                  prefixIcon: Icon(Icons.badge),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(13),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your ID number';
                  }
                  if (!_validateSouthAfricanID(value)) {
                    return 'Please enter a valid 13-digit South African ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Contact Number
              TextFormField(
                controller: _contactNumberController,
                decoration: const InputDecoration(
                  labelText: 'Contact Number *',
                  hintText: 'Enter South African phone number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your contact number';
                  }
                  if (!_validateSouthAfricanPhone(value)) {
                    return 'Please enter a valid South African phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Physical Address
              TextFormField(
                controller: _physicalAddressController,
                decoration: const InputDecoration(
                  labelText: 'Physical Address *',
                  hintText: 'Enter your physical address',
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your physical address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // INF Number
              TextFormField(
                controller: _infrNumberController,
                decoration: const InputDecoration(
                  labelText: 'INF Number *',
                  hintText: 'Enter INF number',
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter INF number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Station ID
              DropdownButtonFormField<String>(
                 initialValue: _selectedStationId,
                 decoration: const InputDecoration(
                   labelText: 'Station ID *',
                   hintText: 'Select station ID',
                   prefixIcon: Icon(Icons.business),
                 ),
                 items: List.generate(51, (index) {
                   if (index == 0) {
                     return const DropdownMenuItem(
                       value: null,
                       child: Text('Select a station ID'),
                     );
                   }
                   return DropdownMenuItem(
                     value: index.toString(),
                     child: Text(index.toString()),
                   );
                 }),
                 onChanged: (value) {
                   setState(() {
                     _selectedStationId = value;
                   });
                 },
                 validator: (value) {
                   if (value == null || value.isEmpty) {
                     return 'Please select a station ID';
                   }
                   return null;
                 },
               ),
               ]),
               const SizedBox(height: 4),

               // Account Information
               _buildSectionCard(
                 title: 'Account Information',
                 icon: Icons.account_circle,
                 children: [

               // Username
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username *',
                    hintText: 'Enter username',
                    prefixIcon: Icon(Icons.account_circle),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter username';
                    }
                    return null;
                  },
                ),
               const SizedBox(height: 16),

                               // Password
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password *',
                    hintText: 'Enter password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
               const SizedBox(height: 16),

                               // Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    hintText: 'Enter email address',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
               ]),
               const SizedBox(height: 32),

               // Submit Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleSubmit,
                  icon: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.person_add, size: 24),
                  label: Text(
                    _isLoading ? 'Registering...' : 'Register Instructor',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.only(bottom: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppTheme.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
} 