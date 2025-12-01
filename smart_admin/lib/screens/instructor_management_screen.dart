//Dart code for Instructor Management Screen in a Flutter application
import 'package:flutter/material.dart';
import 'package:smart_admin/utils/app_theme.dart';
import 'package:smart_admin/services/instructor_service.dart';

class InstructorManagementScreen extends StatefulWidget {
  const InstructorManagementScreen({super.key});

  @override
  State<InstructorManagementScreen> createState() =>
      _InstructorManagementScreenState();
}

class _InstructorManagementScreenState
    extends State<InstructorManagementScreen> with WidgetsBindingObserver {
  List<Map<String, dynamic>> _instructors = [];
  String _searchQuery = '';
  String _statusFilter = 'All';
  bool _isLoading = true;

  List<Map<String, dynamic>> get _filteredInstructors {
    return _instructors.where((instructor) {
      final profile = instructor['profile'] as Map<dynamic, dynamic>?;
      final name = profile?['name']?.toString() ?? '';
      final surname = profile?['surname']?.toString() ?? '';
      final infraNr = profile?['inf_nr']?.toString() ?? 
                      profile?['infraNr']?.toString() ?? 
                      profile?['infra_nr']?.toString() ?? 
                      profile?['instructor_number']?.toString() ?? 
                      profile?['license_number']?.toString() ?? '';
      
      final matchesSearch =
          name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          surname.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          infraNr.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          instructor['username'].toString().toLowerCase().contains(_searchQuery.toLowerCase());

      final isActive = instructor['is_active'] ?? false;
      final status = isActive ? 'Active' : 'Inactive';
      final matchesStatus = _statusFilter == 'All' || status == _statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _showInstructorDetails(Map<String, dynamic> instructor) {
    final profile = instructor['profile'] as Map<dynamic, dynamic>?;
    final name = profile?['name'] ?? 'Unknown';
    final surname = profile?['surname'] ?? '';
    final isActive = instructor['is_active'] ?? false;
    final status = isActive ? 'Active' : 'Inactive';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$name $surname'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('User ID', instructor['id']?.toString() ?? instructor['userid']?.toString() ?? 'N/A'),
            _buildDetailRow('Username', instructor['username'] ?? 'N/A'),
            _buildDetailRow('Email', instructor['email'] ?? 'N/A'),
            _buildDetailRow('ID Number', profile?['id_number']?.toString() ?? 'N/A'),
            _buildDetailRow('Contact Number', profile?['contact_number']?.toString() ?? profile?['phone']?.toString() ?? 'N/A'),
            _buildDetailRow('INF Number', profile?['inf_nr']?.toString() ?? 
                                        profile?['infraNr']?.toString() ?? 
                                        profile?['infra_nr']?.toString() ?? 
                                        profile?['instructor_number']?.toString() ?? 
                                        profile?['license_number']?.toString() ?? 'N/A'),
            _buildDetailRow('Status', status),
            _buildDetailRow('Role', instructor['role'] ?? 'N/A'),
            if (profile?['years_of_experience'] != null) 
              _buildDetailRow('Experience', '${profile!['years_of_experience']} years'),
            if (profile?['specialization'] != null) 
              _buildDetailRow('Specialization', profile!['specialization'].toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _editInstructor(instructor);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _editInstructor(Map<String, dynamic> instructor) {
    // In a real app, this would navigate to an edit screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Edit functionality for ${instructor['name']} ${instructor['surname']}',
        ),
        backgroundColor: AppTheme.warningColor,
      ),
    );
  }

  // Load instructors from database
  Future<void> _loadInstructors() async {
    setState(() {
      _isLoading = true;
    });

    try {      
      final instructors = await InstructorService.getAllInstructors();
      setState(() {
        _instructors = instructors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading instructors: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadInstructors();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app is resumed
      _loadInstructors();
    }
  }



  // Toggle instructor status (active/inactive)
  Future<void> _toggleInstructorStatus(Map<String, dynamic> instructor) async {
    final userId = instructor['id'] ?? instructor['userid'];
    final currentStatus = instructor['is_active'] ?? false;
    final newStatus = !currentStatus;

    try {
      final result = await InstructorService.updateInstructorStatus(
        userId: userId,
        isActive: newStatus,
        username: instructor['username'],
        email: instructor['email'],
      );

      if (mounted) {
        if (result['success']) {
          // Refresh data from database to get the actual status
          await _loadInstructors();

          final statusText = newStatus ? 'Active' : 'Inactive';
          final profile = instructor['profile'] as Map<dynamic, dynamic>?;
          final name = profile?['name'] ?? 'Instructor';
          final surname = profile?['surname'] ?? '';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$name $surname status updated to $statusText'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating instructor status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.people, size: 24),
            SizedBox(width: 12),
            Text('Instructor Management'),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
              onPressed: _loadInstructors,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.person_add),
              tooltip: 'Register New Instructor',
              onPressed: () => Navigator.pushNamed(context, '/registration'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Search Instructors',
                    hintText: 'Search by name or INF number',
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(12),
                      child: const Icon(Icons.search, color: AppTheme.primaryColor),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.clear, size: 18),
                            ),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Status Filter
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.filter_list,
                          color: AppTheme.primaryColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Status:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: DropdownButton<String>(
                            value: _statusFilter,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: ['All', 'Active', 'Inactive'].map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _statusFilter = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Statistics Cards
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Instructors',
                    _instructors.length.toString(),
                    Icons.people,
                    AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Active',
                    _instructors
                        .where((i) => i['is_active'] == true)
                        .length
                        .toString(),
                    Icons.check_circle,
                    AppTheme.successColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Inactive',
                    _instructors
                        .where((i) => i['is_active'] == false)
                        .length
                        .toString(),
                    Icons.cancel,
                    AppTheme.errorColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Instructors List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _filteredInstructors.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No instructors found',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredInstructors.length,
                    itemBuilder: (context, index) {
                      final instructor = _filteredInstructors[index];
                      final profile = instructor['profile'] as Map<dynamic, dynamic>?;
                      final name = profile?['name'] ?? 'Unknown';
                      final surname = profile?['surname'] ?? '';
                      final isActive = instructor['is_active'] ?? false;
                      final status = isActive ? 'Active' : 'Inactive';
                      final infraNr = profile?['inf_nr']?.toString() ?? 
                                      profile?['infraNr']?.toString() ?? 
                                      profile?['infra_nr']?.toString() ?? 
                                      profile?['instructor_number']?.toString() ?? 
                                      profile?['license_number']?.toString() ?? 'N/A';
                      
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isActive
                                      ? [
                                          AppTheme.successColor.withOpacity(0.8),
                                          AppTheme.successColor,
                                        ]
                                      : [
                                          AppTheme.errorColor.withOpacity(0.8),
                                          AppTheme.errorColor,
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isActive
                                            ? AppTheme.successColor
                                            : AppTheme.errorColor)
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '${name.isNotEmpty ? name[0] : 'I'}${surname.isNotEmpty ? surname[0] : 'N'}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              '$name $surname',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.badge,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'INF: $infraNr',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? AppTheme.successColor.withOpacity(0.1)
                                          : AppTheme.errorColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? AppTheme.successColor
                                                : AppTheme.errorColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          status,
                                          style: TextStyle(
                                            color: isActive
                                                ? AppTheme.successColor
                                                : AppTheme.errorColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'view':
                                  _showInstructorDetails(instructor);
                                  break;
                                case 'edit':
                                  _editInstructor(instructor);
                                  break;
                                case 'toggle':
                                  _toggleInstructorStatus(instructor);
                                  break;
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'view',
                                child: Row(
                                  children: [
                                    Icon(Icons.visibility),
                                    SizedBox(width: 8),
                                    Text('View Details'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'toggle',
                                child: Row(
                                  children: [
                                    Icon(
                                      isActive
                                          ? Icons.block
                                          : Icons.check_circle,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isActive
                                          ? 'Deactivate'
                                          : 'Activate',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: () => _showInstructorDetails(instructor),
                        ),
                      ),
                    );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
