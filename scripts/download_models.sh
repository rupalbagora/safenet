#!/bin/bash

# Create assets directory if it doesn't exist
mkdir -p assets

# Download face detection model (MediaPipe BlazeFace)
echo "Downloading face detection model..."
curl -L "https://storage.googleapis.com/mediapipe-models/face_detection/blaze_face_short_range/float16/1/blaze_face_short_range.tflite" -o assets/face_detection.tflite

# Download gender classification model
echo "Downloading gender classification model..."
curl -L "https://tfhub.dev/tensorflow/lite-model/mobilenet_v2_100_224/1/metadata/2?lite-format=tflite" -o assets/Gender.tflite

echo "Models downloaded successfully!"
echo "Please verify the models are in the assets directory:"
ls -l assets/ 