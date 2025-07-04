import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_constants.dart';
import 'hourly_patrol_screen.dart';
import 'login_screen.dart';

class ManagementDashboardScreen extends StatefulWidget {
  const ManagementDashboardScreen({super.key});

  @override
  State<ManagementDashboardScreen> createState() => _ManagementDashboardScreenState();
}

class _ManagementDashboardScreenState extends State<ManagementDashboardScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<GuardInfo> _guards = [];
  List<PatrolRecord> _allPatrols = [];
  List<IncidentInfo> _incidents = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadMockData();
  }

  void _loadMockData() {
    // Mock guard data
    _guards = [
      GuardInfo(
        id: 'G001',
        name: 'John Smith',
        location: 'Security Post Alpha',
        latitude: 40.7128,
        longitude: -74.0060,
        status: GuardStatus.onDuty,
        lastUpdate: DateTime.now().subtract(const Duration(minutes: 5)),
        nextPatrolDue: DateTime.now().add(const Duration(minutes: 25)),
        patrolsToday: 8,
        missedPatrols: 0,
        phoneNumber: '+1 555-0123',
        shift: 'Day Shift (6AM - 6PM)',
      ),
      GuardInfo(
        id: 'G002',
        name: 'Sarah Johnson',
        location: 'Security Post Beta',
        latitude: 40.7589,
        longitude: -73.9851,
        status: GuardStatus.onPatrol,
        lastUpdate: DateTime.now().subtract(const Duration(minutes: 2)),
        nextPatrolDue: DateTime.now().add(const Duration(minutes: 45)),
        patrolsToday: 6,
        missedPatrols: 1,
        phoneNumber: '+1 555-0124',
        shift: 'Night Shift (6PM - 6AM)',
      ),
      GuardInfo(
        id: 'G003',
        name: 'Mike Wilson',
        location: 'Security Post Gamma',
        latitude: 40.7505,
        longitude: -73.9934,
        status: GuardStatus.offDuty,
        lastUpdate: DateTime.now().subtract(const Duration(hours: 2)),
        nextPatrolDue: DateTime.now().add(const Duration(hours: 6)),
        patrolsToday: 12,
        missedPatrols: 0,
        phoneNumber: '+1 555-0125',
        shift: 'Morning Shift (12AM - 12PM)',
      ),
    ];

    // Mock patrol data
    _allPatrols = [
      PatrolRecord(
        id: 'P001',
        guardId: 'G001',
        guardName: 'John Smith',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        location: 'Security Post Alpha - Main Entrance',
        latitude: 40.7128,
        longitude: -74.0060,
        notes: 'All clear, main entrance secured',
        photoPath: 'assets/sample_patrol1.jpg',
        status: PatrolStatus.completed,
      ),
      PatrolRecord(
        id: 'P002',
        guardId: 'G002',
        guardName: 'Sarah Johnson',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        location: 'Security Post Beta - Parking Area',
        latitude: 40.7589,
        longitude: -73.9851,
        notes: 'Minor lighting issue in section B',
        photoPath: 'assets/sample_patrol2.jpg',
        status: PatrolStatus.completed,
      ),
      PatrolRecord(
        id: 'P003',
        guardId: 'G001',
        guardName: 'John Smith',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        location: 'Security Post Alpha - Back Gate',
        latitude: 40.7130,
        longitude: -74.0065,
        notes: 'Routine check completed',
        photoPath: 'assets/sample_patrol3.jpg',
        status: PatrolStatus.completed,
      ),
    ];

    // Mock incidents
    _incidents = [
      IncidentInfo(
        id: 'I001',
        guardId: 'G002',
        guardName: 'Sarah Johnson',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        location: 'Security Post Beta - Parking Area',
        description: 'Suspicious individual loitering near vehicles',
        severity: 'Medium',
        status: 'Resolved',
        photoPath: 'assets/incident1.jpg',
      ),
      IncidentInfo(
        id: 'I002',
        guardId: 'G001',
        guardName: 'John Smith',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        location: 'Security Post Alpha - Main Building',
        description: 'Alarm system malfunction reported',
        severity: 'High',
        status: 'Under Investigation',
        photoPath: null,
      ),
    ];

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Company - Boss Dashboard'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.photo_camera), text: 'Patrol Photos'),
            Tab(icon: Icon(Icons.people), text: 'Guards'),
            Tab(icon: Icon(Icons.security), text: 'Patrols'),
            Tab(icon: Icon(Icons.analytics), text: 'Reports'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadMockData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data refreshed')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPatrolPhotosTab(),
          _buildGuardsTab(),
          _buildPatrolsTab(),
          _buildReportsTab(),
        ],
      ),
    );
  }

  Widget _buildPatrolPhotosTab() {
    final todayPatrols = _allPatrols.where((p) {
      final today = DateTime.now();
      return p.timestamp.year == today.year &&
             p.timestamp.month == today.month &&
             p.timestamp.day == today.day &&
             p.photoPath != null;
    }).toList();

    return Column(
      children: [
        // Summary Header
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue[50],
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today\'s Patrol Photos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${todayPatrols.length} Photos',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Review patrol photos submitted by your security guards',
                style: TextStyle(color: Colors.blue[600]),
              ),
            ],
          ),
        ),
        
        // Photos Grid
        Expanded(
          child: todayPatrols.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_camera, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No patrol photos today',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      Text(
                        'Photos will appear here when guards submit patrols',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: todayPatrols.length,
                    itemBuilder: (context, index) {
                      final patrol = todayPatrols[index];
                      return _buildPatrolPhotoCard(patrol);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPatrolPhotoCard(PatrolRecord patrol) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _viewPatrolPhotoDetails(patrol),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo preview
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Patrol Photo', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    // Status badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'VERIFIED',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Photo details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: Colors.blue[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            patrol.guardName ?? 'Unknown Guard',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('HH:mm').format(patrol.timestamp),
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            patrol.location,
                            style: TextStyle(color: Colors.grey[600], fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewPatrolPhotoDetails(PatrolRecord patrol) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Patrol Photo - ${patrol.guardName}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo display
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Patrol Photo'),
                    Text('(High resolution available)', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Details
              _buildDetailRow('Guard:', patrol.guardName ?? 'Unknown'),
              _buildDetailRow('Time:', DateFormat('MMM dd, yyyy HH:mm:ss').format(patrol.timestamp)),
              _buildDetailRow('Location:', patrol.location),
              _buildDetailRow('Coordinates:', '${patrol.latitude.toStringAsFixed(6)}, ${patrol.longitude.toStringAsFixed(6)}'),
              if (patrol.notes.isNotEmpty) 
                _buildDetailRow('Notes:', patrol.notes),
              
              const SizedBox(height: 16),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Photo marked as verified')),
                        );
                      },
                      icon: const Icon(Icons.verified),
                      label: const Text('Verify'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Photo downloaded')),
                        );
                      },
                      icon: const Icon(Icons.download),
                      label: const Text('Download'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
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
            width: 80,
            child: Text(
              label,
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

  Widget _buildGuardsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        _loadMockData();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _guards.length,
        itemBuilder: (context, index) {
          final guard = _guards[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: _getStatusColor(guard.status).withOpacity(0.1),
                        child: Icon(
                          Icons.person,
                          color: _getStatusColor(guard.status),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              guard.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              guard.shift,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(guard.status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    guard.status.name.toUpperCase(),
                                    style: TextStyle(
                                      color: _getStatusColor(guard.status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.phone),
                            onPressed: () => _callGuard(guard),
                            color: Colors.green,
                          ),
                          IconButton(
                            icon: const Icon(Icons.location_on),
                            onPressed: () => _viewGuardLocation(guard),
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_pin, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                guard.location,
                                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              'Last update: ${DateFormat('HH:mm:ss').format(guard.lastUpdate)}',
                              style: TextStyle(color: Colors.grey[700], fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatChip('Patrols Today', '${guard.patrolsToday}', Colors.blue),
                            _buildStatChip('Missed', '${guard.missedPatrols}', 
                                guard.missedPatrols > 0 ? Colors.red : Colors.green),
                            _buildStatChip('Next Patrol', 
                                guard.status == GuardStatus.offDuty 
                                    ? 'Off Duty'
                                    : DateFormat('HH:mm').format(guard.nextPatrolDue), 
                                Colors.purple),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPatrolsTab() {
    final todayPatrols = _allPatrols.where((p) {
      final today = DateTime.now();
      return p.timestamp.year == today.year &&
             p.timestamp.month == today.month &&
             p.timestamp.day == today.day;
    }).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('Total Today', '${todayPatrols.length}', Icons.security, Colors.blue),
              _buildStatCard('Completed', '${todayPatrols.where((p) => p.status == PatrolStatus.completed).length}', 
                  Icons.check_circle, Colors.green),
              _buildStatCard('Missed', '${todayPatrols.where((p) => p.status == PatrolStatus.missed).length}', 
                  Icons.error, Colors.red),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _allPatrols.length,
            itemBuilder: (context, index) {
              final patrol = _allPatrols[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getPatrolStatusColor(patrol.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      patrol.photoPath != null ? Icons.photo_camera : Icons.security,
                      color: _getPatrolStatusColor(patrol.status),
                    ),
                  ),
                  title: Text(
                    '${patrol.guardName} - ${patrol.location}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat('MMM dd, HH:mm:ss').format(patrol.timestamp)),
                      if (patrol.notes.isNotEmpty)
                        Text(
                          patrol.notes,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (patrol.photoPath != null)
                        Icon(Icons.photo, color: Colors.green[600], size: 16),
                      const SizedBox(height: 4),
                      Text(
                        patrol.status.name.toUpperCase(),
                        style: TextStyle(
                          color: _getPatrolStatusColor(patrol.status),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _viewPatrolDetails(patrol),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIncidentsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _incidents.length,
      itemBuilder: (context, index) {
        final incident = _incidents[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        color: _getSeverityColor(incident.severity).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.report_problem,
                        color: _getSeverityColor(incident.severity),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Incident ${incident.id}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Reported by ${incident.guardName}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getSeverityColor(incident.severity).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        incident.severity,
                        style: TextStyle(
                          color: _getSeverityColor(incident.severity),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  incident.description,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        incident.location,
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd, yyyy HH:mm:ss').format(incident.timestamp),
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status: ${incident.status}',
                      style: TextStyle(
                        color: incident.status == 'Resolved' ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (incident.photoPath != null)
                      Row(
                        children: [
                          Icon(Icons.photo, size: 16, color: Colors.blue[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Photo attached',
                            style: TextStyle(color: Colors.blue[600], fontSize: 12),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportsTab() {
    final totalGuards = _guards.length;
    final activeGuards = _guards.where((g) => g.status != GuardStatus.offDuty).length;
    final totalPatrolsToday = _guards.fold<int>(0, (sum, guard) => sum + guard.patrolsToday);
    final totalMissedPatrols = _guards.fold<int>(0, (sum, guard) => sum + guard.missedPatrols);
    final totalPhotosToday = _allPatrols.where((p) => 
        p.photoPath != null && 
        p.timestamp.difference(DateTime.now()).inDays == 0
    ).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.assessment, size: 28, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Security Reports',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Overview of guard activities and performance',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          
          // Key Metrics
          const Text(
            'Today\'s Overview',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildReportCard('Active Guards', '$activeGuards/$totalGuards', Icons.people, Colors.green),
              _buildReportCard('Patrols Completed', '$totalPatrolsToday', Icons.security, Colors.blue),
              _buildReportCard('Photos Submitted', '$totalPhotosToday', Icons.photo_camera, Colors.purple),
              _buildReportCard('Missed Patrols', '$totalMissedPatrols', Icons.error, 
                  totalMissedPatrols > 0 ? Colors.red : Colors.green),
            ],
          ),
          const SizedBox(height: 32),
          
          // Guard Performance
          const Text(
            'Guard Performance Today',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._guards.map((guard) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(guard.status).withOpacity(0.1),
                child: Icon(Icons.person, color: _getStatusColor(guard.status)),
              ),
              title: Text(guard.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${guard.patrolsToday} patrols completed'),
                  if (guard.missedPatrols > 0)
                    Text(
                      '${guard.missedPatrols} missed patrols',
                      style: const TextStyle(color: Colors.red),
                    ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${((guard.patrolsToday / (guard.patrolsToday + guard.missedPatrols)) * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: guard.missedPatrols == 0 ? Colors.green : Colors.orange,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Completion',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          )).toList(),
          
          const SizedBox(height: 32),
          
          // Recent Activity
          const Text(
            'Recent Photo Submissions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._allPatrols.take(5).map((patrol) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: patrol.photoPath != null ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  patrol.photoPath != null ? Icons.photo_camera : Icons.security,
                  color: patrol.photoPath != null ? Colors.green : Colors.grey,
                ),
              ),
              title: Text('${patrol.guardName} - ${patrol.location}'),
              subtitle: Text(DateFormat('MMM dd, HH:mm:ss').format(patrol.timestamp)),
              trailing: patrol.photoPath != null 
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : Icon(Icons.info, color: Colors.grey[400]),
              onTap: () => _viewPatrolDetails(patrol),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildReportCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
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
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(GuardStatus status) {
    switch (status) {
      case GuardStatus.onDuty:
        return Colors.green;
      case GuardStatus.onPatrol:
        return Colors.blue;
      case GuardStatus.offDuty:
        return Colors.grey;
    }
  }

  Color _getPatrolStatusColor(PatrolStatus status) {
    switch (status) {
      case PatrolStatus.completed:
        return const Color(AppConstants.successColor);
      case PatrolStatus.pending:
        return const Color(AppConstants.warningColor);
      case PatrolStatus.missed:
        return const Color(AppConstants.errorColor);
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  void _callGuard(GuardInfo guard) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Call ${guard.name}?'),
        content: Text('This will initiate a call to ${guard.phoneNumber}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement actual phone call
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling ${guard.name}...')),
              );
            },
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  void _viewGuardLocation(GuardInfo guard) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${guard.name} Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Location: ${guard.location}'),
            const SizedBox(height: 8),
            Text('Coordinates: ${guard.latitude.toStringAsFixed(6)}, ${guard.longitude.toStringAsFixed(6)}'),
            const SizedBox(height: 8),
            Text('Last Update: ${DateFormat('MMM dd, HH:mm:ss').format(guard.lastUpdate)}'),
            const SizedBox(height: 16),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Interactive Map Coming Soon'),
                  ],
                ),
              ),
            ),
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
              // TODO: Open in maps app
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening in Maps app...')),
              );
            },
            child: const Text('Open in Maps'),
          ),
        ],
      ),
    );
  }

  void _viewPatrolDetails(PatrolRecord patrol) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Patrol ${patrol.id}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Guard: ${patrol.guardName}'),
              Text('Time: ${DateFormat('MMM dd, yyyy HH:mm:ss').format(patrol.timestamp)}'),
              Text('Location: ${patrol.location}'),
              Text('Coordinates: ${patrol.latitude}, ${patrol.longitude}'),
              if (patrol.notes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Notes: ${patrol.notes}'),
              ],
              if (patrol.photoPath != null) ...[
                const SizedBox(height: 16),
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Patrol Photo'),
                        Text('(Photo viewing coming soon)', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// Data Models for Management Dashboard
class GuardInfo {
  final String id;
  final String name;
  final String location;
  final double latitude;
  final double longitude;
  final GuardStatus status;
  final DateTime lastUpdate;
  final DateTime nextPatrolDue;
  final int patrolsToday;
  final int missedPatrols;
  final String phoneNumber;
  final String shift;

  GuardInfo({
    required this.id,
    required this.name,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.lastUpdate,
    required this.nextPatrolDue,
    required this.patrolsToday,
    required this.missedPatrols,
    required this.phoneNumber,
    required this.shift,
  });
}

class PatrolRecord {
  final String id;
  final String guardId;
  final String guardName;
  final DateTime timestamp;
  final String location;
  final double latitude;
  final double longitude;
  final String notes;
  final String? photoPath;
  final PatrolStatus status;

  PatrolRecord({
    required this.id,
    required this.guardId,
    required this.guardName,
    required this.timestamp,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.notes,
    this.photoPath,
    required this.status,
  });
}

class IncidentInfo {
  final String id;
  final String guardId;
  final String guardName;
  final DateTime timestamp;
  final String location;
  final String description;
  final String severity;
  final String status;
  final String? photoPath;

  IncidentInfo({
    required this.id,
    required this.guardId,
    required this.guardName,
    required this.timestamp,
    required this.location,
    required this.description,
    required this.severity,
    required this.status,
    this.photoPath,
  });
}

enum GuardStatus { onDuty, onPatrol, offDuty }
enum PatrolStatus { completed, pending, missed }
