import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_constants.dart';

class PatrolRoutesScreen extends StatefulWidget {
  const PatrolRoutesScreen({super.key});

  @override
  State<PatrolRoutesScreen> createState() => _PatrolRoutesScreenState();
}

class _PatrolRoutesScreenState extends State<PatrolRoutesScreen> {
  final List<PatrolRoute> routes = [
    PatrolRoute(
      id: 'ROUTE_001',
      name: 'Main Building Perimeter',
      description: 'Complete patrol around the main building exterior',
      checkpoints: [
        Checkpoint(id: 'CP_001', name: 'Main Entrance', isCompleted: false),
        Checkpoint(id: 'CP_002', name: 'Parking Area', isCompleted: false),
        Checkpoint(id: 'CP_003', name: 'Loading Dock', isCompleted: false),
        Checkpoint(id: 'CP_004', name: 'Emergency Exit', isCompleted: false),
      ],
      estimatedDuration: const Duration(minutes: 30),
      priority: RoutePriority.high,
    ),
    PatrolRoute(
      id: 'ROUTE_002',
      name: 'Interior Security Check',
      description: 'Internal building security inspection',
      checkpoints: [
        Checkpoint(id: 'CP_005', name: 'Lobby Area', isCompleted: true),
        Checkpoint(id: 'CP_006', name: 'Elevator Banks', isCompleted: true),
        Checkpoint(id: 'CP_007', name: 'Emergency Stairwells', isCompleted: false),
        Checkpoint(id: 'CP_008', name: 'Server Room', isCompleted: false),
      ],
      estimatedDuration: const Duration(minutes: 20),
      priority: RoutePriority.medium,
      startTime: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    PatrolRoute(
      id: 'ROUTE_003',
      name: 'Night Security Round',
      description: 'Comprehensive night time security patrol',
      checkpoints: [
        Checkpoint(id: 'CP_009', name: 'Security Office', isCompleted: false),
        Checkpoint(id: 'CP_010', name: 'Storage Areas', isCompleted: false),
        Checkpoint(id: 'CP_011', name: 'Roof Access', isCompleted: false),
      ],
      estimatedDuration: const Duration(minutes: 45),
      priority: RoutePriority.low,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patrol Routes'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshRoutes,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshRoutes,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: routes.length,
          itemBuilder: (context, index) {
            return _buildRouteCard(routes[index]);
          },
        ),
      ),
    );
  }

  Widget _buildRouteCard(PatrolRoute route) {
    final completedCheckpoints = route.checkpoints.where((cp) => cp.isCompleted).length;
    final totalCheckpoints = route.checkpoints.length;
    final progress = totalCheckpoints > 0 ? completedCheckpoints / totalCheckpoints : 0.0;
    final isInProgress = route.startTime != null && !route.isCompleted;
    final isCompleted = route.isCompleted;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(route.priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle : 
                    isInProgress ? Icons.play_circle : Icons.route,
                    color: isCompleted ? const Color(AppConstants.successColor) :
                           isInProgress ? Colors.orange : _getPriorityColor(route.priority),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        route.description,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(route),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress: $completedCheckpoints/$totalCheckpoints checkpoints',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? const Color(AppConstants.successColor) : 
                    const Color(AppConstants.primaryColor),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Route Info
            Row(
              children: [
                Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Est. ${route.estimatedDuration.inMinutes} min',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.flag, size: 16, color: _getPriorityColor(route.priority)),
                const SizedBox(width: 4),
                Text(
                  route.priority.name.toUpperCase(),
                  style: TextStyle(
                    color: _getPriorityColor(route.priority),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (route.startTime != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('HH:mm').format(route.startTime!),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                if (!isCompleted && !isInProgress)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _startRoute(route),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Route'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(AppConstants.primaryColor),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  )
                else if (isInProgress)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _viewRouteDetails(route),
                      icon: const Icon(Icons.visibility),
                      label: const Text('Continue'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _viewRouteDetails(route),
                      icon: const Icon(Icons.check),
                      label: const Text('Completed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(AppConstants.successColor),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _viewRouteDetails(route),
                  child: const Text('Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(PatrolRoute route) {
    String status;
    Color color;
    
    if (route.isCompleted) {
      status = 'Completed';
      color = const Color(AppConstants.successColor);
    } else if (route.startTime != null) {
      status = 'In Progress';
      color = Colors.orange;
    } else {
      status = 'Pending';
      color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getPriorityColor(RoutePriority priority) {
    switch (priority) {
      case RoutePriority.high:
        return const Color(AppConstants.errorColor);
      case RoutePriority.medium:
        return const Color(AppConstants.warningColor);
      case RoutePriority.low:
        return const Color(AppConstants.successColor);
    }
  }

  void _startRoute(PatrolRoute route) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Patrol Route'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Route: ${route.name}'),
            const SizedBox(height: 8),
            Text('Checkpoints: ${route.checkpoints.length}'),
            Text('Estimated Duration: ${route.estimatedDuration.inMinutes} minutes'),
            const SizedBox(height: 16),
            const Text(
              'Make sure you have your mobile device and any required equipment before starting.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                route.startTime = DateTime.now();
              });
              _viewRouteDetails(route);
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  void _viewRouteDetails(PatrolRoute route) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RouteDetailsScreen(
          route: route,
          onRouteUpdated: () => setState(() {}),
        ),
      ),
    );
  }

  Future<void> _refreshRoutes() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Routes refreshed'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

// Route Details Screen
class RouteDetailsScreen extends StatefulWidget {
  final PatrolRoute route;
  final VoidCallback onRouteUpdated;

  const RouteDetailsScreen({
    super.key,
    required this.route,
    required this.onRouteUpdated,
  });

  @override
  State<RouteDetailsScreen> createState() => _RouteDetailsScreenState();
}

class _RouteDetailsScreenState extends State<RouteDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.route.name),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Route Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.route.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${widget.route.estimatedDuration.inMinutes} minutes'),
                      const SizedBox(width: 16),
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${widget.route.checkpoints.length} checkpoints'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Checkpoints List
          const Text(
            'Checkpoints',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          ...widget.route.checkpoints.asMap().entries.map((entry) {
            final index = entry.key;
            final checkpoint = entry.value;
            return _buildCheckpointCard(checkpoint, index);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCheckpointCard(Checkpoint checkpoint, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: checkpoint.isCompleted 
              ? const Color(AppConstants.successColor)
              : Colors.grey[300],
          child: checkpoint.isCompleted
              ? const Icon(Icons.check, color: Colors.white)
              : Text('${index + 1}'),
        ),
        title: Text(checkpoint.name),
        subtitle: checkpoint.completedAt != null 
            ? Text('Completed at ${DateFormat('HH:mm:ss').format(checkpoint.completedAt!)}')
            : const Text('Not completed'),
        trailing: checkpoint.isCompleted 
            ? const Icon(Icons.check_circle, color: Color(AppConstants.successColor))
            : OutlinedButton(
                onPressed: () => _completeCheckpoint(checkpoint),
                child: const Text('Complete'),
              ),
      ),
    );
  }

  void _completeCheckpoint(Checkpoint checkpoint) {
    setState(() {
      checkpoint.isCompleted = true;
      checkpoint.completedAt = DateTime.now();
    });
    
    widget.onRouteUpdated();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${checkpoint.name} completed'),
        backgroundColor: const Color(AppConstants.successColor),
      ),
    );
    
    // Check if all checkpoints are completed
    if (widget.route.checkpoints.every((cp) => cp.isCompleted)) {
      _completeRoute();
    }
  }

  void _completeRoute() {
    setState(() {
      widget.route.isCompleted = true;
      widget.route.completedAt = DateTime.now();
    });
    
    widget.onRouteUpdated();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Route Completed!'),
        content: const Text('All checkpoints have been completed. Great job!'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Data Models
class PatrolRoute {
  final String id;
  final String name;
  final String description;
  final List<Checkpoint> checkpoints;
  final Duration estimatedDuration;
  final RoutePriority priority;
  DateTime? startTime;
  DateTime? completedAt;
  bool isCompleted;

  PatrolRoute({
    required this.id,
    required this.name,
    required this.description,
    required this.checkpoints,
    required this.estimatedDuration,
    required this.priority,
    this.startTime,
    this.completedAt,
    this.isCompleted = false,
  });
}

class Checkpoint {
  final String id;
  final String name;
  bool isCompleted;
  DateTime? completedAt;

  Checkpoint({
    required this.id,
    required this.name,
    this.isCompleted = false,
    this.completedAt,
  });
}

enum RoutePriority { high, medium, low }
