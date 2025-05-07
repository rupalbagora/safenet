import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'face_detection_service.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path/path.dart' as path;

class FaceCaptureScreen extends StatefulWidget {
  @override
  _FaceCaptureScreenState createState() => _FaceCaptureScreenState();
}

class _FaceCaptureScreenState extends State<FaceCaptureScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isProcessing = false;
  String? _errorMessage;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableLandmarks: true,
      enableTracking: true,
      minFaceSize: 0.15,
    ),
  );

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('No cameras available');
      }

      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (!mounted) return;

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error initializing camera: $e';
      });
      print('Error initializing camera: $e');
    }
  }

  Future<void> _captureAndVerify() async {
    if (_isProcessing || _controller == null || !_isInitialized) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final XFile image = await _controller!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      
      final List<Face> faces = await _faceDetector.processImage(inputImage);
      
      if (faces.isEmpty) {
        setState(() {
          _errorMessage = 'No face detected. Please try again.';
          _isProcessing = false;
        });
        return;
      }

      if (faces.length > 1) {
        setState(() {
          _errorMessage = 'Multiple faces detected. Please ensure only one face is visible.';
          _isProcessing = false;
        });
        return;
      }

      final face = faces.first;
      
      // Check face quality
      if (!_isFaceQualityGood(face)) {
        setState(() {
          _errorMessage = 'Please ensure your face is clearly visible and well-lit.';
          _isProcessing = false;
        });
        return;
      }

      // Save the image
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = 'face_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = path.join(directory.path, fileName);
      
      await File(image.path).copy(filePath);

      if (!mounted) return;

      Navigator.pop(context, {
        'success': true,
        'imagePath': filePath,
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error capturing image: $e';
        _isProcessing = false;
      });
      print('Error capturing image: $e');
    }
  }

  bool _isFaceQualityGood(Face face) {
    // Check if face is too small
    if (face.boundingBox.width < 100 || face.boundingBox.height < 100) {
      return false;
    }

    // Check if face is too close to edges
    if (face.boundingBox.left < 50 ||
        face.boundingBox.top < 50 ||
        face.boundingBox.right > _controller!.value.previewSize!.width - 50 ||
        face.boundingBox.bottom > _controller!.value.previewSize!.height - 50) {
      return false;
    }

    // Check if face is too tilted
    if (face.headEulerAngleY != null && (face.headEulerAngleY! < -20 || face.headEulerAngleY! > 20)) {
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Face Verification'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                  });
                  _initializeCamera();
                },
                child: Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Face Verification'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _isProcessing ? null : () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          CameraPreview(_controller!),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _captureAndVerify,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isProcessing
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Capture',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Processing...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}