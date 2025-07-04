import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../bloc/patrol_bloc.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({Key? key}) : super(key: key);

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  MobileScannerController? controller;
  bool _isScanning = true;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (_isScanning && scanData.code != null) {
        _handleScanResult(scanData.code!);
      }
    });
  }

  void _handleScanResult(String qrCode) {
    setState(() {
      _isScanning = false;
    });

    // Pause camera
    controller?.pauseCamera();

    // Process the QR code
    context.read<PatrolBloc>().add(CheckpointScanRequested(qrCode));

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Checkpoint Scanned'),
          ],
        ),
        content: Text('QR Code: $qrCode\n\nCheckpoint has been recorded successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to patrol page
            },
            child: const Text('Done'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              setState(() {
                _isScanning = true;
              });
              controller?.resumeCamera();
            },
            child: const Text('Scan Another'),
          ),
        ],
      ),
    );
  }

  void _toggleFlash() async {
    await controller?.toggleFlash();
    setState(() {});
  }

  void _flipCamera() async {
    await controller?.flipCamera();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: FutureBuilder<bool?>(
              future: controller?.getFlashStatus(),
              builder: (context, snapshot) {
                return Icon(
                  snapshot.data == true ? Icons.flash_on : Icons.flash_off,
                );
              },
            ),
            onPressed: _toggleFlash,
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: _flipCamera,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: Theme.of(context).colorScheme.primary,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: 250,
                  ),
                ),
                
                // Scanning indicator
                if (_isScanning)
                  const Positioned(
                    bottom: 100,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.qr_code_scanner,
                            color: Colors.white,
                            size: 32,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Position QR code within the frame',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.black,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Scan checkpoint QR code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Hold your camera steady and point it at the QR code',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  // Manual input option
                  TextButton.icon(
                    onPressed: () {
                      _showManualInputDialog();
                    },
                    icon: const Icon(Icons.keyboard, color: Colors.white),
                    label: const Text(
                      'Enter code manually',
                      style: TextStyle(color: Colors.white),
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

  void _showManualInputDialog() {
    final TextEditingController textController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter QR Code'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'QR Code',
            hintText: 'Enter checkpoint QR code',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final code = textController.text.trim();
              if (code.isNotEmpty) {
                Navigator.pop(context);
                _handleScanResult(code);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
