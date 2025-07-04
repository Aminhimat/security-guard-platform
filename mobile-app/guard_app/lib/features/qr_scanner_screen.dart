import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../core/constants/app_constants.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController controller = MobileScannerController();
  String? scannedData;
  bool isScanning = true;
  bool flashOn = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(flashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                MobileScanner(
                  controller: controller,
                  onDetect: _onQRDetected,
                ),
                
                // Scanning overlay
                Container(
                  decoration: ShapeDecoration(
                    shape: QrScannerOverlayShape(
                      borderColor: const Color(AppConstants.primaryColor),
                      borderRadius: 10,
                      borderLength: 30,
                      borderWidth: 10,
                      cutOutSize: 300,
                    ),
                  ),
                ),
                
                // Scanning indicator
                if (isScanning)
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 400),
                        Text(
                          'Position QR code within the frame',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                children: [
                  if (scannedData != null) ...[
                    Text(
                      'Scanned Data:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        scannedData!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _processScannedData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(AppConstants.primaryColor),
                            ),
                            child: const Text(
                              'Process Data',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _resumeScanning,
                            child: const Text('Scan Again'),
                          ),
                        ),
                      ],
                    ),
                  ] else
                    const Text(
                      'Scan a QR code to get started',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRDetected(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (isScanning && barcodes.isNotEmpty && barcodes.first.rawValue != null) {
      setState(() {
        scannedData = barcodes.first.rawValue;
        isScanning = false;
      });
      controller.stop();
      _vibrate();
    }
  }

  void _toggleFlash() async {
    await controller.toggleTorch();
    setState(() {
      flashOn = !flashOn;
    });
  }

  void _processScannedData() {
    if (scannedData == null) return;

    // Check if it's a checkpoint QR code
    if (scannedData!.startsWith('CHECKPOINT_')) {
      _handleCheckpointScan();
    } else if (scannedData!.startsWith('PATROL_')) {
      _handlePatrolScan();
    } else {
      _handleGenericScan();
    }
  }

  void _handleCheckpointScan() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Checkpoint Scanned'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Checkpoint ID: ${scannedData!.replaceFirst('CHECKPOINT_', '')}'),
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
              _resumeScanning();
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

  void _handlePatrolScan() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Patrol Route Scanned'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Route ID: ${scannedData!.replaceFirst('PATROL_', '')}'),
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
              _resumeScanning();
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

  void _handleGenericScan() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR Code Scanned'),
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
                scannedData!,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resumeScanning();
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

  void _resumeScanning() {
    setState(() {
      scannedData = null;
      isScanning = true;
    });
    controller.start();
  }

  void _vibrate() {
    // TODO: Add haptic feedback
    // HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

// Custom QR Scanner Overlay Shape for mobile_scanner
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double borderLength;
  final double borderRadius;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 3.0,
    this.borderLength = 40,
    this.borderRadius = 0,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: rect.center,
            width: cutOutSize,
            height: cutOutSize,
          ),
          Radius.circular(borderRadius)));
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path path = Path()..addRect(rect);
    Path cutOut = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: rect.center,
            width: cutOutSize,
            height: cutOutSize,
          ),
          Radius.circular(borderRadius)));
    return Path.combine(PathOperation.difference, path, cutOut);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final Paint paint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    canvas.drawPath(getOuterPath(rect), paint);

    // Draw corner brackets
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final double centerX = rect.center.dx;
    final double centerY = rect.center.dy;
    final double halfSize = cutOutSize / 2;

    // Top-left corner
    Path topLeft = Path()
      ..moveTo(centerX - halfSize, centerY - halfSize + borderLength)
      ..lineTo(centerX - halfSize, centerY - halfSize)
      ..lineTo(centerX - halfSize + borderLength, centerY - halfSize);
    canvas.drawPath(topLeft, borderPaint);

    // Top-right corner
    Path topRight = Path()
      ..moveTo(centerX + halfSize - borderLength, centerY - halfSize)
      ..lineTo(centerX + halfSize, centerY - halfSize)
      ..lineTo(centerX + halfSize, centerY - halfSize + borderLength);
    canvas.drawPath(topRight, borderPaint);

    // Bottom-left corner
    Path bottomLeft = Path()
      ..moveTo(centerX - halfSize, centerY + halfSize - borderLength)
      ..lineTo(centerX - halfSize, centerY + halfSize)
      ..lineTo(centerX - halfSize + borderLength, centerY + halfSize);
    canvas.drawPath(bottomLeft, borderPaint);

    // Bottom-right corner
    Path bottomRight = Path()
      ..moveTo(centerX + halfSize - borderLength, centerY + halfSize)
      ..lineTo(centerX + halfSize, centerY + halfSize)
      ..lineTo(centerX + halfSize, centerY + halfSize - borderLength);
    canvas.drawPath(bottomRight, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
      borderLength: borderLength * t,
      borderRadius: borderRadius * t,
      cutOutSize: cutOutSize * t,
    );
  }
}
