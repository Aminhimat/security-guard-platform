import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';

class WebQRScannerScreen extends StatefulWidget {
  const WebQRScannerScreen({super.key});

  @override
  State<WebQRScannerScreen> createState() => _WebQRScannerScreenState();
}

class _WebQRScannerScreenState extends State<WebQRScannerScreen> {
  final _qrController = TextEditingController();
  String? scannedData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Camera not available message
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.orange[700]),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Camera scanning is not available on web. You can manually enter QR code data below.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Manual QR entry
            const Text(
              'Enter QR Code Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _qrController,
              decoration: InputDecoration(
                hintText: 'Enter QR code content (e.g., CHECKPOINT_001, PATROL_ROUTE_A)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.qr_code),
              ),
            ),
            
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _processManualEntry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppConstants.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Process QR Data',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Sample QR codes
            const Text(
              'Sample QR Codes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: ListView(
                children: [
                  _buildSampleQR('CHECKPOINT_001', 'Main Entrance Checkpoint'),
                  _buildSampleQR('CHECKPOINT_002', 'Parking Area Checkpoint'),
                  _buildSampleQR('CHECKPOINT_003', 'Loading Dock Checkpoint'),
                  _buildSampleQR('PATROL_ROUTE_A', 'Main Building Perimeter Route'),
                  _buildSampleQR('PATROL_ROUTE_B', 'Interior Security Route'),
                  _buildSampleQR('EMERGENCY_CONTACT', 'Emergency Contact Information'),
                ],
              ),
            ),
            
            if (scannedData != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'QR Code Processed',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Data: $scannedData',
                      style: const TextStyle(fontFamily: 'monospace'),
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

  Widget _buildSampleQR(String qrData, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.qr_code),
        title: Text(qrData),
        subtitle: Text(description),
        trailing: OutlinedButton(
          onPressed: () => _useSampleQR(qrData),
          child: const Text('Use'),
        ),
      ),
    );
  }

  void _useSampleQR(String qrData) {
    setState(() {
      _qrController.text = qrData;
    });
  }

  void _processManualEntry() {
    final qrData = _qrController.text.trim();
    if (qrData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter QR code data'),
          backgroundColor: Color(AppConstants.errorColor),
        ),
      );
      return;
    }

    setState(() {
      scannedData = qrData;
    });

    // Process the QR data similar to the camera scanner
    _processScannedData(qrData);
  }

  void _processScannedData(String data) {
    if (data.startsWith('CHECKPOINT_')) {
      _handleCheckpointScan(data);
    } else if (data.startsWith('PATROL_')) {
      _handlePatrolScan(data);
    } else {
      _handleGenericScan(data);
    }
  }

  void _handleCheckpointScan(String data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Checkpoint Scanned'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Checkpoint ID: ${data.replaceFirst('CHECKPOINT_', '')}'),
            const SizedBox(height: 8),
            Text('Time: ${DateTime.now().toString().substring(0, 19)}'),
            const SizedBox(height: 8),
            const Text('Status: Completed'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _qrController.clear();
              setState(() => scannedData = null);
            },
            child: const Text('Continue Patrol'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Return to dashboard
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Checkpoint logged successfully'),
                  backgroundColor: Color(AppConstants.successColor),
                ),
              );
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _handlePatrolScan(String data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Patrol Route Scanned'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Route ID: ${data.replaceFirst('PATROL_', '')}'),
            const SizedBox(height: 8),
            const Text('Action: Start Patrol'),
            const SizedBox(height: 8),
            Text('Time: ${DateTime.now().toString().substring(0, 19)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _qrController.clear();
              setState(() => scannedData = null);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Patrol started successfully'),
                  backgroundColor: Color(AppConstants.successColor),
                ),
              );
            },
            child: const Text('Start Patrol'),
          ),
        ],
      ),
    );
  }

  void _handleGenericScan(String data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code Processed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Scanned Content:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                data,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _qrController.clear();
              setState(() => scannedData = null);
            },
            child: const Text('Scan Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _qrController.dispose();
    super.dispose();
  }
}
