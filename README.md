# SafeNet Face Detection and Gender Classification

This application uses TensorFlow Lite models for face detection and gender classification.

## Model Setup

### Option 1: Using the Download Script

1. Make sure you have `curl` installed on your system
2. Run the download script:
```bash
chmod +x scripts/download_models.sh
./scripts/download_models.sh
```

### Option 2: Manual Download

1. Create an `assets` directory in your project root if it doesn't exist
2. Download the models manually:

#### Face Detection Model
Download the MediaPipe BlazeFace model:
```bash
curl -L "https://storage.googleapis.com/mediapipe-models/face_detection/blaze_face_short_range/float16/1/blaze_face_short_range.tflite" -o assets/face_detection.tflite
```

#### Gender Classification Model
Download the MobileNetV2 model:
```bash
curl -L "https://tfhub.dev/tensorflow/lite-model/mobilenet_v2_100_224/1/metadata/2?lite-format=tflite" -o assets/Gender.tflite
```

## Model Information

### Face Detection Model (BlazeFace)
- Model: MediaPipe BlazeFace
- Input size: 128x128
- Output: Face bounding boxes and landmarks
- Performance: Optimized for mobile devices
- License: Apache 2.0

### Gender Classification Model (MobileNetV2)
- Model: MobileNetV2
- Input size: 224x224
- Output: Binary classification (Male/Female)
- Performance: Optimized for mobile devices
- License: Apache 2.0

## Alternative Models

If you need different models, here are some alternatives:

### Face Detection Alternatives:
1. MobileNet SSD:
```bash
curl -L "https://tfhub.dev/tensorflow/lite-model/ssd_mobilenet_v1/1/metadata/2?lite-format=tflite" -o assets/face_detection.tflite
```

2. EfficientDet:
```bash
curl -L "https://tfhub.dev/tensorflow/lite-model/efficientdet/lite2/detection/metadata/1?lite-format=tflite" -o assets/face_detection.tflite
```

### Gender Classification Alternatives:
1. EfficientNet:
```bash
curl -L "https://tfhub.dev/tensorflow/lite-model/efficientnet/lite0/classification/2?lite-format=tflite" -o assets/Gender.tflite
```

2. ResNet:
```bash
curl -L "https://tfhub.dev/tensorflow/lite-model/resnet_50/classification/1?lite-format=tflite" -o assets/Gender.tflite
```

## Model Customization

If you need to train your own models:

1. For face detection:
   - Use TensorFlow Object Detection API
   - Train on a face detection dataset (e.g., WIDER FACE)
   - Convert to TFLite format

2. For gender classification:
   - Use TensorFlow Image Classification
   - Train on a gender classification dataset
   - Convert to TFLite format

## Troubleshooting

If you encounter issues with the models:

1. Verify model compatibility:
```bash
tflite_convert --output_file=assets/face_detection.tflite --saved_model_dir=path_to_model
```

2. Check model metadata:
```bash
tflite_metadata_show assets/face_detection.tflite
```

3. Test model inference:
```bash
tflite_benchmark --graph=assets/face_detection.tflite
```

## License

The models are provided under the Apache 2.0 license. Please check the specific license terms for each model you use.
