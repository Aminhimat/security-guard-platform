import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_constants.dart';

class CheckInOutScreen extends StatefulWidget {
  const CheckInOutScreen({super.key});

  @override
  State<CheckInOutScreen> createState() => _CheckInOutScreenState();
}

class _CheckInOutScreenState extends State<CheckInOutScreen> {
  bool isCheckedIn = false;
  DateTime? lastCheckInTime;
  DateTime? lastCheckOutTime;
  Position? currentPosition;
  String currentLocation = 'Fetching location...';
  bool isLoadingLocation = true;
  
  final List<CheckInRecord> checkInHistory = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadCheckInStatus();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          currentLocation = 'Location services disabled';
          isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            currentLocation = 'Location permission denied';
            isLoadingLocation = false;
          });
          return;
        }
      }

      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocoding simulation
      setState(() {
        currentLocation = 'Main Building, Security Post A\nLat: ${currentPosition!.latitude.toStringAsFixed(6)}, Lng: ${currentPosition!.longitude.toStringAsFixed(6)}';
        isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        currentLocation = 'Unable to get location';
        isLoadingLocation = false;
      });
    }
  }

  void _loadCheckInStatus() {
    // TODO: Load from local storage or API
    // For demo purposes, using sample data
    setState(() {
      isCheckedIn = false;
      lastCheckInTime = DateTime.now().subtract(const Duration(hours: 2));
      
      // Sample history
      checkInHistory.addAll([
        CheckInRecord(
          type: CheckInType.checkIn,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          location: 'Main Building, Security Post A',
        ),
        CheckInRecord(
          type: CheckInType.checkOut,
          timestamp: DateTime.now().subtract(const Duration(hours: 10)),
          location: 'Main Building, Security Post A',
        ),
        CheckInRecord(
          type: CheckInType.checkIn,
          timestamp: DateTime.now().subtract(const Duration(hours: 10, minutes: 5)),
          location: 'Main Building, Security Post B',
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check In/Out'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Status Card
            _buildStatusCard(),
            const SizedBox(height: 24),
            
            // Location Card
            _buildLocationCard(),
            const SizedBox(height: 24),
            
            // Check In/Out Button
            _buildCheckInOutButton(),
            const SizedBox(height: 32),
            
            // History Section
            _buildHistorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCheckedIn 
                        ? const Color(AppConstants.successColor).withOpacity(0.1)
                        : const Color(AppConstants.errorColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isCheckedIn ? Icons.access_time : Icons.access_time_filled,
                    color: isCheckedIn 
                        ? const Color(AppConstants.successColor)
                        : const Color(AppConstants.errorColor),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCheckedIn ? 'Checked In' : 'Checked Out',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isCheckedIn 
                              ? const Color(AppConstants.successColor)
                              : const Color(AppConstants.errorColor),
                        ),
                      ),
                      if (lastCheckInTime != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Last: ${DateFormat('MMM dd, yyyy HH:mm').format(lastCheckInTime!)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            
            if (isCheckedIn && lastCheckInTime != null) ...[
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
                      'Shift Duration: ${_calculateShiftDuration()}',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.blue[700],
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Current Location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isLoadingLocation)
              const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Getting your location...'),
                ],
              )
            else
              Text(
                currentLocation,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Location'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckInOutButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: isLoadingLocation ? null : _toggleCheckInOut,
        style: ElevatedButton.styleFrom(
          backgroundColor: isCheckedIn 
              ? const Color(AppConstants.errorColor)
              : const Color(AppConstants.successColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          isCheckedIn ? 'Check Out' : 'Check In',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        if (checkInHistory.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No check-in history yet',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: checkInHistory.length,
            itemBuilder: (context, index) {
              final record = checkInHistory[index];
              return _buildHistoryItem(record);
            },
          ),
      ],
    );
  }

  Widget _buildHistoryItem(CheckInRecord record) {
    final isCheckIn = record.type == CheckInType.checkIn;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isCheckIn 
                ? const Color(AppConstants.successColor).withOpacity(0.1)
                : const Color(AppConstants.errorColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isCheckIn ? Icons.login : Icons.logout,
            color: isCheckIn 
                ? const Color(AppConstants.successColor)
                : const Color(AppConstants.errorColor),
          ),
        ),
        title: Text(
          isCheckIn ? 'Check In' : 'Check Out',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('MMM dd, yyyy HH:mm:ss').format(record.timestamp)),
            Text(
              record.location,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.location_on,
          color: Colors.grey[400],
          size: 16,
        ),
      ),
    );
  }

  String _calculateShiftDuration() {
    if (lastCheckInTime == null) return '0h 0m';
    
    final duration = DateTime.now().difference(lastCheckInTime!);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    return '${hours}h ${minutes}m';
  }

  void _toggleCheckInOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isCheckedIn ? 'Check Out' : 'Check In'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isCheckedIn 
                ? 'Are you sure you want to check out?' 
                : 'Are you sure you want to check in?'),
            const SizedBox(height: 8),
            Text(
              'Location: $currentLocation',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Time: ${DateFormat('MMM dd, yyyy HH:mm:ss').format(DateTime.now())}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
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
              _performCheckInOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isCheckedIn 
                  ? const Color(AppConstants.errorColor)
                  : const Color(AppConstants.successColor),
            ),
            child: Text(
              isCheckedIn ? 'Check Out' : 'Check In',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _performCheckInOut() {
    final now = DateTime.now();
    final newRecord = CheckInRecord(
      type: isCheckedIn ? CheckInType.checkOut : CheckInType.checkIn,
      timestamp: now,
      location: currentLocation,
    );

    setState(() {
      isCheckedIn = !isCheckedIn;
      if (isCheckedIn) {
        lastCheckInTime = now;
      } else {
        lastCheckOutTime = now;
      }
      checkInHistory.insert(0, newRecord);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCheckedIn ? 'Checked in successfully' : 'Checked out successfully'),
        backgroundColor: const Color(AppConstants.successColor),
      ),
    );

    // TODO: Send to API
  }
}

class CheckInRecord {
  final CheckInType type;
  final DateTime timestamp;
  final String location;

  CheckInRecord({
    required this.type,
    required this.timestamp,
    required this.location,
  });
}

enum CheckInType { checkIn, checkOut }
