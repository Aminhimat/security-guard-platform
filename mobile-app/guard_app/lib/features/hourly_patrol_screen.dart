import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_constants.dart';
import '../core/services/camera_service.dart';
import 'incident_report_screen.dart';

class HourlyPatrolScreen extends StatefulWidget {
  const HourlyPatrolScreen({super.key});

  @override
  State<HourlyPatrolScreen> createState() => _HourlyPatrolScreenState();
}

class _HourlyPatrolScreenState extends State<HourlyPatrolScreen> {
  Timer? _patrolTimer;
  Timer? _reminderTimer;
  bool _isPatrolActive = false;
  DateTime? _lastPatrolTime;
  DateTime? _nextPatrolTime;
  Position? _currentPosition;
  String _currentLocation = 'Getting location...';
  final List<PatrolRecord> _patrolHistory = [];
  final CameraService _cameraService = CameraService();
  bool _showPatrolReminder = false;
  int _reminderCount = 0;
  
  // Current patrol data - mobile photos only
  final List<File> _currentPatrolPhotos = [];
  String _patrolNotes = '';
  final _notesController = TextEditingController();
  String _patrolStatus = 'patrol_completed'; // Default status
  
  // State management
  bool _isSubmittingPatrol = false;
  bool _isTakingPhoto = false;
  
  // Patrol status options
  final List<Map<String, String>> _patrolStatusOptions = [
    {'value': 'patrol_completed', 'label': 'I did patrol - All Clear'},
    {'value': 'patrol_with_issues', 'label': 'I did patrol - Issues Found'},
    {'value': 'patrol_incomplete', 'label': 'Patrol Incomplete'},
    {'value': 'emergency_situation', 'label': 'Emergency Situation'},
  ];

  @override
  void initState() {
    super.initState();
    _initializePatrol();
    _loadPatrolHistory();
    _startReminderSystem();
  }

  void _initializePatrol() {
    _getCurrentLocation();
    _calculateNextPatrolTime();
    _startPatrolTimer();
    _isPatrolActive = true; // Auto-start patrol mode
  }

  void _startPatrolTimer() {
    _patrolTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkPatrolTime();
    });
  }

  void _startReminderSystem() {
    // Check every 30 seconds for better responsiveness
    _reminderTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkForPatrolReminders();
    });
  }

  void _checkForPatrolReminders() {
    if (!_isPatrolActive || _nextPatrolTime == null) return;
    
    final now = DateTime.now();
    final timeUntilPatrol = _nextPatrolTime!.difference(now).inMinutes;
    
    // Show reminder 5 minutes before patrol time
    if (timeUntilPatrol <= 5 && timeUntilPatrol > 0 && !_showPatrolReminder) {
      _showUpcomingPatrolReminder();
    }
    
    // Show urgent reminder if patrol is overdue
    if (now.isAfter(_nextPatrolTime!) && _reminderCount < 3) {
      _showOverduePatrolReminder();
    }
  }

  void _showUpcomingPatrolReminder() {
    setState(() => _showPatrolReminder = true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.access_time, color: Colors.white),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Patrol reminder: Next patrol due in 5 minutes'),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showOverduePatrolReminder() {
    _reminderCount++;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: Colors.red[600],
            ),
            const SizedBox(width: 8),
            const Text('Patrol Overdue!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your hourly patrol was due at ${DateFormat('HH:mm').format(_nextPatrolTime!)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Please complete your patrol check immediately.',
              style: TextStyle(
                color: Colors.red[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _snoozePatrol();
            },
            child: Text(
              'Snooze 5min',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _showPatrolReminder = false);
              _reminderCount = 0;
              // Auto-scroll to patrol section
              // TODO: Implement auto-scroll if using ScrollController
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Start Patrol Now'),
          ),
        ],
      ),
    );
  }

  void _checkPatrolTime() {
    if (_nextPatrolTime != null && DateTime.now().isAfter(_nextPatrolTime!)) {
      _showPatrolNotification();
    }
  }

  void _calculateNextPatrolTime() {
    final now = DateTime.now();
    if (_lastPatrolTime == null) {
      // First patrol - set to next hour
      _nextPatrolTime = DateTime(now.year, now.month, now.day, now.hour + 1, 0);
    } else {
      // Next patrol is 1 hour after last patrol
      _nextPatrolTime = _lastPatrolTime!.add(const Duration(hours: 1));
    }
    setState(() {});
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _currentLocation = 'Location services disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _currentLocation = 'Location permission denied');
          return;
        }
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = 'Security Post Alpha\n'
            'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}\n'
            'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}';
      });
    } catch (e) {
      setState(() => _currentLocation = 'Unable to get location');
    }
  }

  void _loadPatrolHistory() {
    // Sample patrol history
    _patrolHistory.addAll([
      PatrolRecord(
        id: 'P001',
        guardId: 'G001',
        guardName: 'Security Guard',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        location: 'Security Post Alpha',
        latitude: 40.7128,
        longitude: -74.0060,
        notes: 'All clear, no incidents reported',
        photoPath: null,
        status: PatrolStatus.completed,
      ),
      PatrolRecord(
        id: 'P002',
        guardId: 'G001',
        guardName: 'Security Guard',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        location: 'Security Post Beta',
        latitude: 40.7589,
        longitude: -73.9851,
        notes: 'Minor maintenance issue noted in report',
        photoPath: null,
        status: PatrolStatus.completed,
      ),
    ]);
    
    if (_patrolHistory.isNotEmpty) {
      _lastPatrolTime = _patrolHistory.first.timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hourly Patrol'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isPatrolActive ? Icons.pause : Icons.play_arrow),
            onPressed: _togglePatrolStatus,
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _showPatrolSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          // Patrol Reminder Banner
          if (_showPatrolReminder || _isCurrentPatrolTime())
            Container(
              width: double.infinity,
              color: _isCurrentPatrolTime() ? Colors.red[600] : Colors.orange,
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    _isCurrentPatrolTime() ? Icons.alarm : Icons.schedule,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isCurrentPatrolTime() 
                          ? 'PATROL TIME! Complete your hourly check now.'
                          : 'Patrol reminder: Next patrol due soon.',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (!_isCurrentPatrolTime())
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => setState(() => _showPatrolReminder = false),
                    ),
                ],
              ),
            ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patrol Status Card
                  _buildPatrolStatusCard(),
                  const SizedBox(height: 16),
                  
                  // Current Location Card
                  _buildLocationCard(),
                  const SizedBox(height: 16),
                  
                  // Current Patrol Section - Always show when patrol is active
                  _buildCurrentPatrolSection(),
                  const SizedBox(height: 16),
                  
                  // Patrol History
                  _buildPatrolHistorySection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPatrolSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Patrol Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Auto Reminders'),
              subtitle: const Text('Get notified before patrol time'),
              value: true, // TODO: Make this configurable
              onChanged: (value) {
                // TODO: Implement settings storage
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Auto reminders ${value ? 'enabled' : 'disabled'}')),
                );
              },
            ),
            ListTile(
              title: const Text('Patrol Interval'),
              subtitle: const Text('Currently: Every hour'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pop(context);
                _showIntervalSettings();
              },
            ),
            ListTile(
              title: const Text('Location Sharing'),
              subtitle: const Text('Share live location with management'),
              trailing: Switch(
                value: true,
                onChanged: (value) {
                  // TODO: Implement location sharing toggle
                },
              ),
            ),
          ],
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

  void _showIntervalSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Patrol Interval'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<int>(
              title: const Text('Every 30 minutes'),
              value: 30,
              groupValue: 60, // Current setting
              onChanged: (value) => _updatePatrolInterval(value!),
            ),
            RadioListTile<int>(
              title: const Text('Every hour'),
              value: 60,
              groupValue: 60,
              onChanged: (value) => _updatePatrolInterval(value!),
            ),
            RadioListTile<int>(
              title: const Text('Every 2 hours'),
              value: 120,
              groupValue: 60,
              onChanged: (value) => _updatePatrolInterval(value!),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _updatePatrolInterval(int minutes) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Patrol interval updated to $minutes minutes')),
    );
    // TODO: Implement actual interval update
  }

  Widget _buildPatrolStatusCard() {
    final timeUntilNext = _nextPatrolTime != null 
        ? _nextPatrolTime!.difference(DateTime.now())
        : Duration.zero;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isPatrolActive 
                        ? const Color(AppConstants.successColor).withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isPatrolActive ? Icons.security : Icons.pause_circle,
                    color: _isPatrolActive 
                        ? const Color(AppConstants.successColor)
                        : Colors.grey,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isPatrolActive ? 'Patrol Active' : 'Patrol Paused',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _isPatrolActive 
                              ? const Color(AppConstants.successColor)
                              : Colors.grey,
                        ),
                      ),
                      if (_nextPatrolTime != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Next patrol: ${DateFormat('HH:mm').format(_nextPatrolTime!)}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            
            if (_isPatrolActive && timeUntilNext.inMinutes > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Next patrol in: ${timeUntilNext.inHours}h ${timeUntilNext.inMinutes % 60}m',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (_isCurrentPatrolTime()) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Patrol time! Please complete your hourly check.',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue[700], size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Current Location',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _currentLocation,
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _getCurrentLocation,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Update Location'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _shareLocationWithBoss,
                    icon: const Icon(Icons.share_location),
                    label: const Text('Share Location'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPatrolSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.camera_alt, color: Colors.orange[700], size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Patrol Photos (Max 5)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_currentPatrolPhotos.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${_currentPatrolPhotos.length} Photo${_currentPatrolPhotos.length > 1 ? 's' : ''} Taken',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Photo Section
            if (_currentPatrolPhotos.isNotEmpty) ...[
              // Photos grid
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _currentPatrolPhotos.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _currentPatrolPhotos[index],
                              height: 200,
                              width: 150,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Delete button for each photo
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white, size: 16),
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                onPressed: () => _removePhoto(index),
                              ),
                            ),
                          ),
                          // Photo number overlay
                          Positioned(
                            bottom: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_currentPatrolPhotos.length} photo${_currentPatrolPhotos.length > 1 ? 's' : ''} captured',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ] else if (_isTakingPhoto) ...[
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[300]!, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Taking photo...',
                      style: TextStyle(
                        color: Colors.blue[700], 
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Please wait',
                      style: TextStyle(
                        color: Colors.blue[600], 
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[300]!, width: 2, style: BorderStyle.solid),
                ),
                child: InkWell(
                  onTap: _isTakingPhoto ? null : _takePatrolPhoto,
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt, 
                        size: 40, 
                        color: _isTakingPhoto ? Colors.grey : Colors.orange[700]
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isTakingPhoto ? 'Taking photo...' : 'Tap to take patrol photos',
                        style: TextStyle(
                          color: _isTakingPhoto ? Colors.grey : Colors.orange[700], 
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isTakingPhoto ? 'Please wait' : 'At least 1 photo required for patrol submission',
                        style: TextStyle(
                          color: _isTakingPhoto ? Colors.grey : Colors.orange[600], 
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Photo Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isTakingPhoto ? null : _takePatrolPhoto,
                    icon: _isTakingPhoto 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.camera_alt),
                    label: Text(_isTakingPhoto ? 'Taking Photo...' : 'Add Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(AppConstants.primaryColor),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[400],
                      disabledForegroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (_currentPatrolPhotos.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: (_isTakingPhoto || _isSubmittingPatrol) ? null : () {
                      // Show confirmation dialog before clearing all photos
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Clear All Photos?'),
                          content: Text('This will remove all ${_currentPatrolPhotos.length} photos. Are you sure?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                setState(() {
                                  _currentPatrolPhotos.clear();
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('All photos cleared'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Clear All'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear All'),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Notes Section
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Patrol Notes',
                hintText: 'Everything looks secure, no issues observed...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) => _patrolNotes = value,
            ),
            
            const SizedBox(height: 16),
            
            // Patrol Status Dropdown
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _patrolStatus,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  iconSize: 24,
                  elevation: 16,
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  onChanged: (String? newValue) {
                    setState(() {
                      _patrolStatus = newValue!;
                    });
                  },
                  items: _patrolStatusOptions.map<DropdownMenuItem<String>>((Map<String, String> option) {
                    return DropdownMenuItem<String>(
                      value: option['value'],
                      child: Row(
                        children: [
                          Icon(
                            _getStatusIconForValue(option['value']!),
                            color: _getStatusColorForValue(option['value']!),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option['label']!,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: _getStatusColorForValue(option['value']!),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Submit Patrol
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmittingPatrol 
                  ? null 
                  : (_currentPatrolPhotos.isNotEmpty ? _submitPatrol : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please take at least one photo before submitting patrol report'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSubmittingPatrol 
                    ? Colors.grey[400]
                    : (_currentPatrolPhotos.isNotEmpty 
                      ? const Color(AppConstants.successColor)
                      : Colors.orange),
                  disabledBackgroundColor: Colors.grey[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmittingPatrol 
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Submitting...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      _currentPatrolPhotos.isNotEmpty 
                        ? 'Submit Patrol Report (${_currentPatrolPhotos.length} photos)'
                        : 'Take Photos First to Submit',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatrolHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Patrol History (Last 24 Hours)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        
        if (_patrolHistory.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No patrol history yet',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _patrolHistory.length,
            itemBuilder: (context, index) {
              return _buildPatrolHistoryItem(_patrolHistory[index]);
            },
          ),
      ],
    );
  }

  Widget _buildPatrolHistoryItem(PatrolRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getStatusColor(record.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getStatusIcon(record.status),
            color: _getStatusColor(record.status),
          ),
        ),
        title: Text(
          '${record.location} - ${DateFormat('HH:mm').format(record.timestamp)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('MMM dd, yyyy').format(record.timestamp)),
            if (record.notes.isNotEmpty)
              Text(
                record.notes,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  record.photoCount > 0 ? Icons.photo_camera : Icons.notes,
                  color: Colors.grey[400],
                  size: 16,
                ),
                if (record.photoCount > 1) ...[
                  const SizedBox(width: 2),
                  Text(
                    '${record.photoCount}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              record.status.name.toUpperCase(),
              style: TextStyle(
                color: _getStatusColor(record.status),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        onTap: () => _viewPatrolDetails(record),
      ),
    );
  }

  bool _isCurrentPatrolTime() {
    if (_nextPatrolTime == null) return false;
    final now = DateTime.now();
    return now.isAfter(_nextPatrolTime!) && 
           now.isBefore(_nextPatrolTime!.add(const Duration(minutes: 15)));
  }

  void _showPatrolNotification() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.alarm, color: Colors.orange),
            SizedBox(width: 8),
            Text('Patrol Time!'),
          ],
        ),
        content: const Text(
          'It\'s time for your hourly patrol check. Please take a photo and submit your report.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _snoozePatrol();
            },
            child: const Text('Snooze 5 min'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {}); // Refresh to show patrol section
            },
            child: const Text('Start Patrol'),
          ),
        ],
      ),
    );
  }

  Future<void> _takePatrolPhoto() async {
    // Prevent multiple photo uploads at the same time
    if (_isTakingPhoto) {
      _showErrorSnackBar('Photo capture already in progress');
      return;
    }

    // Prevent submission while taking photo
    if (_isSubmittingPatrol) {
      _showErrorSnackBar('Cannot take photo while submitting patrol');
      return;
    }

    // Check maximum photos limit
    if (_currentPatrolPhotos.length >= 5) {
      _showErrorSnackBar('Maximum 5 photos allowed per patrol');
      return;
    }

    setState(() {
      _isTakingPhoto = true;
    });

    try {
      final hasPermission = await _cameraService.requestCameraPermission();
      if (!hasPermission) {
        _showErrorSnackBar('Camera permission denied');
        return;
      }

      // For mobile, get image file
      final image = await _cameraService.pickImageFromCamera();
      if (image != null) {
        setState(() {
          _currentPatrolPhotos.add(image);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Photo ${_currentPatrolPhotos.length} captured successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        _showErrorSnackBar('Photo capture was cancelled');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to take photo: $e');
    } finally {
      setState(() {
        _isTakingPhoto = false;
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      if (index < _currentPatrolPhotos.length) {
        _currentPatrolPhotos.removeAt(index);
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo removed'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 1),
      ),
    );
  }

  Future<void> _submitPatrol() async {
    if (_currentPatrolPhotos.isEmpty) {
      _showErrorSnackBar('Please take at least one photo before submitting patrol');
      return;
    }

    // Prevent multiple submissions
    if (_isSubmittingPatrol) {
      _showErrorSnackBar('Patrol submission already in progress');
      return;
    }

    setState(() {
      _isSubmittingPatrol = true;
    });

    try {
      // Show submitting dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text('Submitting patrol data...'),
              const SizedBox(height: 8),
              Text(
                'Uploading ${_currentPatrolPhotos.length} photos',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 3));

      // Create patrol record with multiple photos
      final List<String> photoPaths = [];
      
      // Add mobile photo paths
      for (int i = 0; i < _currentPatrolPhotos.length; i++) {
        photoPaths.add(_currentPatrolPhotos[i].path);
      }

      final patrolRecord = PatrolRecord(
        id: 'P${DateTime.now().millisecondsSinceEpoch}',
        guardId: 'G001', // Current guard ID
        guardName: 'Security Guard', // Current guard name
        timestamp: DateTime.now(),
        location: _currentLocation,
        latitude: _currentPosition?.latitude ?? 0.0,
        longitude: _currentPosition?.longitude ?? 0.0,
        notes: _patrolNotes.isEmpty ? 'Patrol completed, all secure' : _patrolNotes,
        photoPath: photoPaths.first, // Main photo for compatibility
        photoPaths: photoPaths, // All photos
        status: _getPatrolStatusFromString(_patrolStatus),
        patrolStatusText: _getPatrolStatusLabel(_patrolStatus),
      );

      // Add to history
      setState(() {
        _patrolHistory.insert(0, patrolRecord);
        _lastPatrolTime = DateTime.now();
        _currentPatrolPhotos.clear();
        _notesController.clear();
        _patrolNotes = '';
        _patrolStatus = 'patrol_completed'; // Reset to default
        _showPatrolReminder = false; // Hide reminder
        _reminderCount = 0; // Reset reminder count
        _isTakingPhoto = false; // Reset photo taking state
      });

      _calculateNextPatrolTime();

      // Close submitting dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Show success with detailed info
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Patrol Report Submitted Successfully'),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Submitted ${photoPaths.length} photos at ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          backgroundColor: const Color(AppConstants.successColor),
          duration: const Duration(seconds: 4),
        ),
      );

      // Simulate sending to management
      _sendPatrolToManagement(patrolRecord);

    } catch (e) {
      // Close submitting dialog if open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      _showErrorSnackBar('Failed to submit patrol report: ${e.toString()}');
    } finally {
      setState(() {
        _isSubmittingPatrol = false;
      });
    }
  }

  void _sendPatrolToManagement(PatrolRecord record) {
    // Simulate sending patrol data to management dashboard/API
    // This would include:
    // - GPS coordinates and location name
    // - Multiple photos with timestamps
    // - Guard notes and observations
    // - Patrol completion status
    // - Real-time notification to management
    
    print('=== PATROL DATA SENT TO MANAGEMENT ===');
    print('Guard: ${record.guardName} (${record.guardId})');
    print('Time: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(record.timestamp)}');
    print('Location: ${record.location}');
    print('Status: ${record.patrolStatusText ?? record.status.name}');
    print('GPS: ${record.latitude}, ${record.longitude}');
    print('Notes: ${record.notes}');
    print('Photos: ${record.photoCount} attached');
    if (record.photoPaths != null) {
      for (int i = 0; i < record.photoPaths!.length; i++) {
        print('  Photo ${i + 1}: ${record.photoPaths![i]}');
      }
    }
    print('=======================================');
    
    // In a real app, this would make an HTTP request to the backend API
    // Example:
    // await apiService.submitPatrolData({
    //   'guard_id': record.guardId,
    //   'timestamp': record.timestamp.toIso8601String(),
    //   'latitude': record.latitude,
    //   'longitude': record.longitude,
    //   'location': record.location,
    //   'notes': record.notes,
    //   'photos': record.photoPaths,
    //   'status': record.status.name,
    // });
    
    // Simulate real-time notification to management
    Future.delayed(const Duration(seconds: 1), () {
      print('📱 NOTIFICATION: Management notified of patrol completion with ${record.photoCount} photos');
    });
  }

  void _shareLocationWithBoss() {
    if (_currentPosition == null) {
      _showErrorSnackBar('Location not available');
      return;
    }

    // TODO: Implement real-time location sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location shared with management'),
        backgroundColor: Color(AppConstants.successColor),
      ),
    );
  }

  void _togglePatrolStatus() {
    setState(() {
      _isPatrolActive = !_isPatrolActive;
      if (_isPatrolActive) {
        _startPatrolTimer();
      } else {
        _patrolTimer?.cancel();
      }
    });
  }

  void _snoozePatrol() {
    setState(() {
      _nextPatrolTime = DateTime.now().add(const Duration(minutes: 5));
    });
  }

  void _viewPatrolDetails(PatrolRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Patrol ${record.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time: ${DateFormat('MMM dd, yyyy HH:mm:ss').format(record.timestamp)}'),
            Text('Location: ${record.location}'),
            Text('Coordinates: ${record.latitude}, ${record.longitude}'),
            if (record.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Notes: ${record.notes}'),
            ],
            if (record.photoCount > 0) ...[
              const SizedBox(height: 8),
              Text('Photos: ${record.photoCount} attached'),
              if (record.photoPaths != null) ...[
                const SizedBox(height: 4),
                ...record.photoPaths!.asMap().entries.map((entry) => 
                  Text('  ${entry.key + 1}. ${entry.value.split('/').last}', 
                       style: const TextStyle(fontSize: 12, color: Colors.grey))
                ),
              ],
            ],
          ],
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

  Color _getStatusColor(PatrolStatus status) {
    switch (status) {
      case PatrolStatus.completed:
        return const Color(AppConstants.successColor);
      case PatrolStatus.pending:
        return const Color(AppConstants.warningColor);
      case PatrolStatus.missed:
        return const Color(AppConstants.errorColor);
    }
  }

  IconData _getStatusIcon(PatrolStatus status) {
    switch (status) {
      case PatrolStatus.completed:
        return Icons.check_circle;
      case PatrolStatus.pending:
        return Icons.schedule;
      case PatrolStatus.missed:
        return Icons.error;
    }
  }

  IconData _getStatusIconForValue(String value) {
    switch (value) {
      case 'patrol_completed':
        return Icons.check_circle;
      case 'patrol_with_issues':
        return Icons.warning;
      case 'patrol_incomplete':
        return Icons.cancel;
      case 'emergency_situation':
        return Icons.emergency;
      default:
        return Icons.security;
    }
  }

  Color _getStatusColorForValue(String value) {
    switch (value) {
      case 'patrol_completed':
        return Colors.green;
      case 'patrol_with_issues':
        return Colors.orange;
      case 'patrol_incomplete':
        return Colors.red;
      case 'emergency_situation':
        return Colors.red[700]!;
      default:
        return Colors.blue;
    }
  }

  PatrolStatus _getPatrolStatusFromString(String statusString) {
    switch (statusString) {
      case 'patrol_completed':
        return PatrolStatus.completed;
      case 'patrol_with_issues':
        return PatrolStatus.completed; // Still completed but with notes
      case 'patrol_incomplete':
        return PatrolStatus.missed;
      case 'emergency_situation':
        return PatrolStatus.completed; // Completed but urgent
      default:
        return PatrolStatus.completed;
    }
  }

  String _getPatrolStatusLabel(String statusString) {
    final option = _patrolStatusOptions.firstWhere(
      (opt) => opt['value'] == statusString,
      orElse: () => {'value': statusString, 'label': 'Unknown Status'},
    );
    return option['label']!;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(AppConstants.errorColor),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

// Data Models
class PatrolRecord {
  final String id;
  final String? guardId;
  final String? guardName;
  final DateTime timestamp;
  final String location;
  final double latitude;
  final double longitude;
  final String notes;
  final String? photoPath; // For backward compatibility
  final List<String>? photoPaths; // Support multiple photos
  final PatrolStatus status;
  final String? patrolStatusText;

  PatrolRecord({
    required this.id,
    this.guardId,
    this.guardName,
    required this.timestamp,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.notes,
    this.photoPath,
    this.photoPaths,
    required this.status,
    this.patrolStatusText,
  });

  int get photoCount => photoPaths?.length ?? (photoPath != null ? 1 : 0);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guardId': guardId,
      'guardName': guardName,
      'timestamp': timestamp.toIso8601String(),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
      'photoPath': photoPath,
      'photoPaths': photoPaths,
      'status': status.name,
      'patrolStatusText': patrolStatusText,
    };
  }

  factory PatrolRecord.fromJson(Map<String, dynamic> json) {
    return PatrolRecord(
      id: json['id'],
      guardId: json['guardId'],
      guardName: json['guardName'],
      timestamp: DateTime.parse(json['timestamp']),
      location: json['location'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      notes: json['notes'],
      photoPath: json['photoPath'],
      photoPaths: json['photoPaths'] != null ? List<String>.from(json['photoPaths']) : null,
      status: PatrolStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PatrolStatus.completed,
      ),
      patrolStatusText: json['patrolStatusText'],
    );
  }
}

enum PatrolStatus {
  completed,
  pending,
  missed,
}
