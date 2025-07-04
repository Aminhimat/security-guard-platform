import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/api_service.dart';

void main() {
  runApp(const ManagementDashboard());
}

class ManagementDashboard extends StatelessWidget {
  const ManagementDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Management Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final response = await ApiService().login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      // Check if user is management (boss, manager, admin)
      if (response.user.role == 'CompanyAdmin' || response.user.role == 'PlatformOwner') {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ManagementDashboardScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Access denied. Management credentials required.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString().replaceAll('ApiException: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Management Dashboard Login'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.security,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'Management Portal',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: 300,
              child: TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 300,
              child: TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 300,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ManagementDashboardScreen extends StatefulWidget {
  const ManagementDashboardScreen({super.key});

  @override
  State<ManagementDashboardScreen> createState() => _ManagementDashboardScreenState();
}

class _ManagementDashboardScreenState extends State<ManagementDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<GuardInfo> _guards = [];
  List<PatrolRecord> _allPatrols = [];
  List<IncidentInfo> _incidents = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadRealData(); // Load real data from API
  }

  Future<void> _loadRealData() async {
    try {
      print('Loading real data from API...');
      // Load real data from API
      final guards = await ApiService().getGuards();
      print('Guards loaded: ${guards.length}');
      
      final patrols = await ApiService().getPatrols();
      print('Patrols loaded: ${patrols.length}');
      
      final incidents = await ApiService().getIncidents();
      print('Incidents loaded: ${incidents.length}');
      
      setState(() {
        _guards = guards;
        _allPatrols = patrols;
        _incidents = incidents;
      });
    } catch (e) {
      print('Error loading API data: $e');
      // If API fails, fall back to mock data
      _loadMockData();
    }
  }

  void _loadMockData() {
    setState(() {
      _guards = [
        GuardInfo(
          id: '1',
          name: 'John Doe',
          email: 'john@example.com',
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          isActive: true,
        ),
        GuardInfo(
          id: '2',
          name: 'Jane Smith',
          email: 'jane@example.com',
          createdAt: DateTime.now().subtract(const Duration(days: 15)),
          isActive: true,
        ),
      ];

      _allPatrols = [
        PatrolRecord(
          id: '1',
          guardId: '1',
          guardName: 'John Doe',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          location: 'Main Entrance',
          latitude: 40.7128,
          longitude: -74.0060,
          notes: 'All secure',
          photos: [],
          status: 'completed',
        ),
        PatrolRecord(
          id: '2',
          guardId: '2',
          guardName: 'Jane Smith',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          location: 'Parking Lot',
          latitude: 40.7129,
          longitude: -74.0061,
          notes: 'Vehicle inspection completed',
          photos: [],
          status: 'completed',
        ),
      ];

      _incidents = [
        IncidentInfo(
          id: '1',
          guardId: '1',
          guardName: 'John Doe',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
          location: 'Building A',
          latitude: 40.7130,
          longitude: -74.0062,
          type: 'Security',
          severity: 'Medium',
          description: 'Suspicious activity reported',
          status: 'Open',
          photos: [],
        ),
      ];
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Management Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.people), text: 'Guards'),
            Tab(icon: Icon(Icons.photo_camera), text: 'Patrol Photos'),
            Tab(icon: Icon(Icons.report), text: 'Incidents'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildGuardsTab(),
          _buildPatrolPhotosTab(),
          _buildIncidentsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Active Guards',
                  '${_guards.length}',
                  Icons.people,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Today\'s Patrols',
                  '${_allPatrols.length}',
                  Icons.route,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Open Incidents',
                  '${_incidents.where((i) => i.status == 'Open').length}',
                  Icons.warning,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Total Incidents',
                  '${_incidents.length}',
                  Icons.report,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          
          // Recent Activity
          const Text(
            'Recent Activity',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildRecentActivityList(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityList() {
    List<Map<String, dynamic>> activities = [];
    
    // Add patrols
    for (var patrol in _allPatrols.take(5)) {
      activities.add({
        'type': 'patrol',
        'title': 'Patrol Completed',
        'subtitle': '${patrol.guardName} - ${patrol.location}',
        'time': patrol.timestamp,
        'icon': Icons.check_circle,
        'color': Colors.green,
      });
    }
    
    // Add incidents
    for (var incident in _incidents.take(3)) {
      activities.add({
        'type': 'incident',
        'title': 'Incident Reported',
        'subtitle': '${incident.guardName} - ${incident.type}',
        'time': incident.timestamp,
        'icon': Icons.warning,
        'color': Colors.orange,
      });
    }
    
    // Sort by time
    activities.sort((a, b) => b['time'].compareTo(a['time']));
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.take(8).length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: activity['color'],
            child: Icon(activity['icon'], color: Colors.white),
          ),
          title: Text(activity['title']),
          subtitle: Text(activity['subtitle']),
          trailing: Text(
            DateFormat('MMM d, HH:mm').format(activity['time']),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildGuardsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Guards Management',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _guards.length,
            itemBuilder: (context, index) {
              return _buildGuardCard(_guards[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGuardCard(GuardInfo guard) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    guard.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guard.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        guard.email,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: guard.isActive ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    guard.isActive ? 'Active' : 'Inactive',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.date_range, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Joined: ${DateFormat('MMM d, yyyy').format(guard.createdAt)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatrolPhotosTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Patrol Photos',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _allPatrols.length,
            itemBuilder: (context, index) {
              return _buildPatrolPhotoCard(_allPatrols[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPatrolPhotoCard(PatrolRecord patrol) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.photo_camera, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    patrol.location,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  DateFormat('MMM d, HH:mm').format(patrol.timestamp),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Guard: ${patrol.guardName}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(patrol.notes),
            const SizedBox(height: 16),
            
            // Photo placeholder
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo, size: 50, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('No photos available', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncidentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Incident Reports',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _incidents.length,
            itemBuilder: (context, index) {
              return _buildIncidentCard(_incidents[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentCard(IncidentInfo incident) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getIncidentColor(incident.severity),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIncidentIcon(incident.type),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        incident.type,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${incident.guardName} - ${incident.location}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: incident.status == 'Open' ? Colors.orange : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    incident.status,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(incident.description),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM d, yyyy HH:mm').format(incident.timestamp),
                  style: const TextStyle(color: Colors.grey),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getIncidentColor(incident.severity),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    incident.severity,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getIncidentColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'critical':
        return Colors.red[900]!;
      default:
        return Colors.grey;
    }
  }

  IconData _getIncidentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'security':
        return Icons.security;
      case 'maintenance':
        return Icons.build;
      case 'medical':
        return Icons.medical_services;
      default:
        return Icons.report;
    }
  }
}

// Data Models

