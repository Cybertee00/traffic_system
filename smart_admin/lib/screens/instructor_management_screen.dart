import 'package:flutter/material.dart';
import 'package:smart_admin/services/auth_service.dart';
import 'package:smart_admin/utils/app_theme.dart';

class InstructorManagementScreen extends StatefulWidget {
  const InstructorManagementScreen({super.key});

  @override
  State<InstructorManagementScreen> createState() => _InstructorManagementScreenState();
}

class _InstructorManagementScreenState extends State<InstructorManagementScreen> {
  final List<Map<String, dynamic>> _instructors = [
    {
      'id': '1',
      'name': 'John',
      'surname': 'Doe',
      'idNumber': '8501015009087',
      'contactNumber': '+27123456789',
      'infrNumber': 'INF001',
      'status': 'Active',
      'registrationDate': '2024-01-15',
    },
    {
      'id': '2',
      'name': 'Jane',
      'surname': 'Smith',
      'idNumber': '9203155009087',
      'contactNumber': '+27123456790',
      'infrNumber': 'INF002',
      'status': 'Active',
      'registrationDate': '2024-01-20',
    },
    {
      'id': '3',
      'name': 'Mike',
      'surname': 'Johnson',
      'idNumber': '8807125009087',
      'contactNumber': '+27123456791',
      'infrNumber': 'INF003',
      'status': 'Inactive',
      'registrationDate': '2024-02-01',
    },
  ];

  String _searchQuery = '';
  String _statusFilter = 'All';

  List<Map<String, dynamic>> get _filteredInstructors {
    return _instructors.where((instructor) {
      final matchesSearch = instructor['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          instructor['surname'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          instructor['infrNumber'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesStatus = _statusFilter == 'All' || instructor['status'] == _statusFilter;
      
      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _showInstructorDetails(Map<String, dynamic> instructor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${instructor['name']} ${instructor['surname']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('ID Number', instructor['idNumber']),
            _buildDetailRow('Contact Number', instructor['contactNumber']),
            _buildDetailRow('INF Number', instructor['infrNumber']),
            _buildDetailRow('Status', instructor['status']),
            _buildDetailRow('Registration Date', instructor['registrationDate']),
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
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _editInstructor(Map<String, dynamic> instructor) {
    // In a real app, this would navigate to an edit screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit functionality for ${instructor['name']} ${instructor['surname']}'),
        backgroundColor: AppTheme.warningColor,
      ),
    );
  }

  void _toggleInstructorStatus(Map<String, dynamic> instructor) {
    setState(() {
      instructor['status'] = instructor['status'] == 'Active' ? 'Inactive' : 'Active';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${instructor['name']} ${instructor['surname']} status updated to ${instructor['status']}'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructor Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => Navigator.pushNamed(context, '/registration'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Search Instructors',
                    hintText: 'Search by name or INF number',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Status Filter
                Row(
                  children: [
                    const Text(
                      'Status: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _statusFilter,
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
                  ],
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
                    _instructors.where((i) => i['status'] == 'Active').length.toString(),
                    Icons.check_circle,
                    AppTheme.successColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Inactive',
                    _instructors.where((i) => i['status'] == 'Inactive').length.toString(),
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
            child: _filteredInstructors.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No instructors found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredInstructors.length,
                    itemBuilder: (context, index) {
                      final instructor = _filteredInstructors[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: instructor['status'] == 'Active'
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                            child: Text(
                              instructor['name'][0] + instructor['surname'][0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            '${instructor['name']} ${instructor['surname']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('INF: ${instructor['infrNumber']}'),
                              Text(
                                'Status: ${instructor['status']}',
                                style: TextStyle(
                                  color: instructor['status'] == 'Active'
                                      ? AppTheme.successColor
                                      : AppTheme.errorColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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
                                      instructor['status'] == 'Active'
                                          ? Icons.block
                                          : Icons.check_circle,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      instructor['status'] == 'Active'
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
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 