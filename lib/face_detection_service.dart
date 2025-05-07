import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

class FaceDetectionService {
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      enableClassification: true,
      performanceMode: FaceDetectorMode.accurate,
    ),
  );

  Future<void> initialize() async {
    // Initialization is handled by ML Kit automatically
  }

  Future<Map<String, dynamic>?> processImage(img.Image image) async {
    try {
      // Convert image to InputImage format
      final bytes = img.encodePng(image);
      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.bgra8888,
          bytesPerRow: image.width * 4,
        ),
      );

      // Detect faces
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        return null;
      }

      // Get the first detected face
      final face = faces.first;

      // Check face quality
      if (!_isFaceQualityGood(image, face)) {
        return null;
      }

      return {
        'boundingBox': face.boundingBox,
        'headEulerAngleY': face.headEulerAngleY,
        'headEulerAngleZ': face.headEulerAngleZ,
        'leftEyeOpenProbability': face.leftEyeOpenProbability,
        'rightEyeOpenProbability': face.rightEyeOpenProbability,
        'smilingProbability': face.smilingProbability,
      };
    } catch (e) {
      print('Error processing image: $e');
      return null;
    }
  }

  bool _isFaceQualityGood(img.Image image, Face face) {
    // Check face size
    final faceWidth = face.boundingBox.width;
    final faceHeight = face.boundingBox.height;
    final minSize = image.width * 0.2; // Face should be at least 20% of image width

    if (faceWidth < minSize || faceHeight < minSize) {
      return false;
    }

    // Check face angle
    if ((face.headEulerAngleY ?? 0).abs() > 20 || 
        (face.headEulerAngleZ ?? 0).abs() > 20) {
      return false;
    }

    // Check eyes open
    if ((face.leftEyeOpenProbability ?? 0) < 0.5 || 
        (face.rightEyeOpenProbability ?? 0) < 0.5) {
      return false;
    }

    return true;
  }

  void dispose() {
    _faceDetector.close();
  }
} 