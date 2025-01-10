# OnDevice ML - Plant Analysis App

A Flutter application that performs on-device machine learning for plant analysis using both traditional classification and zero-shot learning approaches.

## Features

- **Dual ML Approach**:
  - Traditional Classification: Plant species identification
  - Zero-shot Learning: Flexible image analysis with custom prompts
  - On-device processing for privacy and speed

- **Key Capabilities**:
  - Image capture from camera or gallery
  - Automatic image optimization
  - Real-time plant classification
  - Custom analysis queries
  - Model management and downloads

## Detailed Architecture

### 1. Core Components

- **Controllers**:
  - `ClassificationController`: Manages plant classification workflow
    - Model loading and caching
    - Image processing pipeline
    - Classification inference
  - `ZeroShotController`: Handles flexible image analysis
    - CLIP model coordination
    - Custom prompt processing
    - Zero-shot inference
  - `SettingsController`: Manages app configuration
    - Model download management
    - Storage management
    - Configuration persistence

- **Views**:
  - `MainLayout`: Navigation and layout orchestration
  - `ClassificationView`: Plant species identification UI
  - `ZeroShotView`: Custom analysis interface
  - `SettingsView`: Model and configuration management
  - `CompleteWorkflowView`: Combined analysis workflow

### 2. ML Pipeline

#### Traditional Classification Flow:
```
Image Input → Preprocessing → PyTorch Model → Species Prediction
│
├─ Preprocessing:
│  ├─ Size validation (≤10MB)
│  ├─ Resolution adjustment (1024x1024)
│  └─ Quality optimization (85%)
│
└─ Model Pipeline:
   ├─ Model loading (cached)
   ├─ Inference
   └─ Result processing
```

#### Zero-Shot Analysis Flow:
```
Image Input → CLIP Image Encoder → Feature Vector
                                      │
Custom Prompt → Text Encoder → Feature Vector
                                      │
                              Similarity Matching
                                      │
                              Analysis Result
```

### 3. Data Management

- **Model Storage**:
  ```
  AppDocuments/
  ├── CLIPImageEncoder.tflite
  ├── CLIPTextEncoder.tflite
  ├── tokenized_prompts.pb
  ├── model.pt
  └── labels.txt
  ```

- **State Management**:
  ```dart
  // Reactive States (GetX)
  _model: Rxn<ClassificationModel>    // ML model state
  _labels: RxList<String>            // Classification labels
  _image: Rxn<File>                  // Current image
  _prediction: RxString              // Model prediction
  _isLoading: RxBool                // Processing state
  ```

### 4. Error Handling & Recovery

- **Hierarchical Error Management**:
  1. Image Processing Errors
     - Size validation
     - Format validation
     - Compression errors
  2. Model Errors
     - Loading failures
     - Inference errors
     - Resource exhaustion
  3. System Errors
     - Memory constraints
     - Storage issues
     - Permission problems

- **Recovery Strategies**:
  ```
  Error Detection → Retry Logic → Fallback Options → User Feedback
  ```

### 5. Performance Optimizations

- **Memory Management**:
  - Model caching with static references
  - Image compression pipeline
  - Resource cleanup in finally blocks
  - Garbage collection hints

- **Processing Pipeline**:
  ```
  Input Validation → Size Check → Compression → Processing → Cleanup
  ```

- **Caching Strategy**:
  ```dart
  // Static Cache
  static ClassificationModel? _cachedModel;
  static List<String>? _cachedLabels;
  
  // Cache Management
  if (_cachedModel != null) {
    return _cachedModel;  // Avoid reload
  }
  ```

## Workflow Examples

### 1. Plant Classification

```dart
// User Flow
1. Select/Capture Image
2. Automatic Processing:
   - Size validation
   - Compression
   - Model inference
3. Display Results

// Error Recovery
try {
  await classifyImage();
} catch (e) {
  // Retry logic
  // Model reload if needed
  // User feedback
}
```

### 2. Zero-Shot Analysis

```dart
// Analysis Flow
1. Image Input
2. Custom Prompt Entry
3. Parallel Processing:
   - Image encoding
   - Text encoding
4. Similarity Computation
5. Result Ranking
```

## Architecture

- **State Management**: GetX for reactive state and dependency injection
- **ML Models**:
  - PyTorch Lite for classification
  - TensorFlow Lite for zero-shot learning
  - CLIP model for flexible image analysis

## Project Structure
```
lib/
├── app/
│   ├── bindings/      # Dependency injection
│   ├── config/        # App configuration
│   ├── controllers/   # Business logic
│   ├── models/        # Data models
│   └── views/         # UI components
├── generated/         # Generated code
└── main.dart         # Entry point
```

## Setup

1. **Prerequisites**:
   - Flutter SDK ^3.5.4
   - Dart SDK ^3.5.4
   - Android Studio / VS Code with Flutter extensions

2. **Installation**:
   ```bash
   git clone [repository-url]
   cd ondevice_ml
   flutter pub get
   ```

3. **Run the App**:
   ```bash
   flutter run
   ```

## Dependencies

```yaml
dependencies:
  pytorch_lite: ^4.3.2
  tflite_flutter: ^0.11.0
  get: ^4.6.6
  image_picker: ^1.0.7
  camera: ^0.11.0+2
  # See pubspec.yaml for complete list
```

## Performance Optimizations

- Model caching for faster loading
- Image compression and size validation
- Memory management and resource cleanup
- Error recovery mechanisms

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
