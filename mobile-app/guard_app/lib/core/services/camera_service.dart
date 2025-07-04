import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CameraService {
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  late List<CameraDescription> _cameras;
  CameraController? _controller;
  final ImagePicker _picker = ImagePicker();

  List<CameraDescription> get cameras => _cameras;
  CameraController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  Future<void> initializeCameras() async {
    try {
      _cameras = await availableCameras();
    } catch (e) {
      print('Error initializing cameras: $e');
      _cameras = [];
    }
  }

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<CameraController?> initializeCamera({
    int cameraIndex = 0,
    ResolutionPreset resolution = ResolutionPreset.high,
  }) async {
    if (_cameras.isEmpty) {
      await initializeCameras();
    }

    if (_cameras.isEmpty) {
      return null;
    }

    // Dispose previous controller if exists
    await _controller?.dispose();

    _controller = CameraController(
      _cameras[cameraIndex],
      resolution,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      return _controller;
    } catch (e) {
      print('Error initializing camera controller: $e');
      return null;
    }
  }

  Future<File?> takePicture() async {
    if (!isInitialized) {
      print('Camera not initialized');
      return null;
    }

    try {
      final XFile image = await _controller!.takePicture();
      return File(image.path);
    } catch (e) {
      print('Error taking picture: $e');
      return null;
    }
  }

  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        if (kIsWeb) {
          // For web, we'll handle this differently in the calling code
          return null;
        } else {
          return File(image.path);
        }
      }
      return null;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  Future<Uint8List?> pickImageBytesFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        return await image.readAsBytes();
      }
      return null;
    } catch (e) {
      print('Error picking image bytes from camera: $e');
      return null;
    }
  }

  Future<File?> saveImageToGallery(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = 'incident_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path = join(directory.path, fileName);
      
      final File savedImage = await imageFile.copy(path);
      return savedImage;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  Future<List<File>> getStoredImages() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final List<FileSystemEntity> files = directory.listSync();
      
      return files
          .whereType<File>()
          .where((file) => file.path.toLowerCase().endsWith('.jpg') || 
                         file.path.toLowerCase().endsWith('.png'))
          .toList();
    } catch (e) {
      print('Error getting stored images: $e');
      return [];
    }
  }

  void switchCamera() {
    if (_cameras.length < 2) return;
    
    final currentIndex = _cameras.indexOf(_controller!.description);
    final newIndex = (currentIndex + 1) % _cameras.length;
    
    initializeCamera(cameraIndex: newIndex);
  }

  void dispose() {
    _controller?.dispose();
    _controller = null;
  }
}
