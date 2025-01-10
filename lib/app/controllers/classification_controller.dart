import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pytorch_lite/pytorch_lite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ondevice_ml/app/config/model_config.dart';
import 'package:ondevice_ml/app/controllers/zeroshot_controller.dart';

class ClassificationController extends GetxController {
  static const String tag = 'ClassificationController';
  static ClassificationModel? _cachedModel;
  static List<String>? _cachedLabels;

  final _model = Rxn<ClassificationModel>();
  final _labels = RxList<String>([]);
  final _image = Rxn<File>();
  final _prediction = RxString('');
  final _isLoading = RxBool(false);
  final _modelLoaded = RxBool(false);
  final _modelLoadingStatus = RxString('Not started');
  final _processingStatus = RxString('');

  File? get image => _image.value;
  String get prediction => _prediction.value;
  bool get isLoading => _isLoading.value;
  bool get modelLoaded => _modelLoaded.value;
  String get modelLoadingStatus => _modelLoadingStatus.value;
  String get processingStatus => _processingStatus.value;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    debugPrint('$tag: Initializing controller');
    _loadModels();
  }

  Future<void> _loadModels() async {
    debugPrint('\n$tag: ====== STARTING MODEL LOADING ======');
    _modelLoadingStatus.value = 'Loading models...';

    try {
      // Use cached model if available
      if (_cachedModel != null && _cachedLabels != null) {
        debugPrint('$tag: Using cached model and labels');
        _model.value = _cachedModel;
        _labels.assignAll(_cachedLabels!);
        _modelLoaded.value = true;
        _modelLoadingStatus.value = 'Models loaded from cache';
        return;
      }

      final settingsController = Get.find<SettingsController>();
      final dir = await getApplicationDocumentsDirectory();

      // Check if all required models are downloaded
      final requiredModels = settingsController.classificationModels
          .where((model) => !model.isDownloaded)
          .map((model) => model.name)
          .toList();

      if (requiredModels.isNotEmpty) {
        final missingModels = requiredModels.join(", ");
        _modelLoadingStatus.value =
            'Missing models: $missingModels\nPlease download from Settings';
        _modelLoaded.value = false;
        _showMessage(
            'Please download required models from Settings:\n$missingModels',
            isError: true);
        return;
      }

      debugPrint('$tag: Loading classification model');
      _modelLoadingStatus.value = 'Loading classification model...';
      final modelFile = settingsController.classificationModels
          .firstWhere((model) => model.localPath == ModelPaths.plantClassifier);

      debugPrint('$tag: Loading labels');
      _modelLoadingStatus.value = 'Loading labels...';

      // Get the directory and labels file
      final labelsFile = File('${dir.path}/${ModelPaths.plantLabels}');

      // Read and process labels
      final labelsContent = await labelsFile.readAsString();
      _labels.value = labelsContent
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .toList();
      debugPrint('$tag: Loaded ${_labels.length} labels');

      // Load the model using absolute path
      final modelPath = '${dir.path}/${modelFile.localPath}';
      final labelsPath = '${dir.path}/${ModelPaths.plantLabels}';
      debugPrint('$tag: Loading model from: $modelPath');
      debugPrint('$tag: Loading labels from: $labelsPath');
      _model.value = await PytorchLite.loadClassificationModel(
          modelPath, 224, 224, _labels.length + 1, // Add 1 for background class
          labelPath: labelsPath,
          modelLocation: ModelLocation.path,
          labelsLocation: LabelsLocation.path);

      // Cache the model and labels
      _cachedModel = _model.value;
      _cachedLabels = _labels.toList();

      _modelLoaded.value = true;
      _modelLoadingStatus.value = 'Models loaded successfully';
      debugPrint('$tag: Models loaded successfully');
      _showMessage('Models loaded successfully');
    } catch (e, stackTrace) {
      final errorMsg = 'Failed to load models: $e';
      debugPrint('\n$tag: !!!!! MODEL LOADING ERROR !!!!');
      debugPrint('$tag: Error type: ${e.runtimeType}');
      debugPrint('$tag: Error message: $e');
      debugPrint('$tag: Stack trace:\n$stackTrace');

      _modelLoaded.value = false;
      _modelLoadingStatus.value = 'Error: $e';
      _showMessage(errorMsg, isError: true);
    }
    debugPrint('$tag: ====== MODEL LOADING COMPLETE ======\n');
  }

  Future<void> reloadModels() async {
    _modelLoaded.value = false;
    await _loadModels();
  }

  Future<void> getImage(ImageSource source) async {
    debugPrint('\n$tag: ====== STARTING IMAGE CAPTURE ======');
    _processingStatus.value = 'Selecting image...';

    try {
      File? imageFile;
      if (Get.isRegistered<ZeroShotController>()) {
        final zeroShotController = Get.find<ZeroShotController>();
        imageFile = zeroShotController.image;
      }

      if (imageFile == null) {
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: 1024, // Limit image size
          maxHeight: 1024,
          imageQuality: 85, // Compress image while maintaining quality
        );
        if (pickedFile == null) {
          debugPrint('$tag: No image selected');
          _processingStatus.value = '';
          return;
        }
        imageFile = File(pickedFile.path);
      }

      // Validate file size
      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        // 10MB limit
        _showMessage('Image size too large. Please select a smaller image.',
            isError: true);
        _processingStatus.value = '';
        return;
      }

      debugPrint(
          '$tag: Image selected: ${imageFile.path} (${fileSize ~/ 1024}KB)');
      _image.value = imageFile;
      _prediction.value = '';
      _isLoading.value = true;

      await classifyImage();
    } catch (e, stackTrace) {
      debugPrint('\n$tag: !!!!! IMAGE CAPTURE ERROR !!!!');
      debugPrint('$tag: Error type: ${e.runtimeType}');
      debugPrint('$tag: Error message: $e');
      debugPrint('$tag: Stack trace:\n$stackTrace');

      _processingStatus.value = '';
      _showMessage('Error picking image: $e', isError: true);
    }
    debugPrint('$tag: ====== IMAGE CAPTURE COMPLETE ======\n');
  }

  Future<void> classifyImage() async {
    debugPrint('\n$tag: ====== STARTING CLASSIFICATION ======');

    if (_image.value == null || _model.value == null) {
      debugPrint('$tag: Prerequisites not met:');
      debugPrint('$tag: - Image: ${_image.value != null}');
      debugPrint('$tag: - Model: ${_model.value != null}');
      _showMessage('Model or image not ready', isError: true);
      _isLoading.value = false;
      _processingStatus.value = '';
      return;
    }

    try {
      _processingStatus.value = 'Processing image...';
      debugPrint('$tag: Reading image bytes');

      late final List<int> bytes;
      try {
        bytes = await _image.value!.readAsBytes();
        if (bytes.isEmpty) {
          throw Exception('Image bytes are empty');
        }
      } catch (e) {
        debugPrint('$tag: Error reading image: $e');
        _showMessage('Error reading image. Please try again.', isError: true);
        _isLoading.value = false;
        _processingStatus.value = '';
        return;
      }

      debugPrint('$tag: Image size: ${bytes.length} bytes');

      debugPrint('$tag: Running model inference');
      _processingStatus.value = 'Running classification...';

      String prediction;
      int retryCount = 0;
      const maxRetries = 2;

      while (true) {
        try {
          prediction =
              await _model.value!.getImagePrediction(Uint8List.fromList(bytes));
          break;
        } catch (e) {
          retryCount++;
          if (retryCount > maxRetries) {
            rethrow;
          }
          debugPrint('$tag: Retry $retryCount after error: $e');
          await Future.delayed(Duration(milliseconds: 500 * retryCount));
        }
      }

      _prediction.value = prediction;
      debugPrint('$tag: Prediction: $prediction');
    } catch (e, stackTrace) {
      debugPrint('\n$tag: !!!!! CLASSIFICATION ERROR !!!!');
      debugPrint('$tag: Error type: ${e.runtimeType}');
      debugPrint('$tag: Error message: $e');
      debugPrint('$tag: Stack trace:\n$stackTrace');

      // Try to recover by reloading the model
      if (_model.value == null) {
        debugPrint('$tag: Attempting to recover by reloading model');
        await reloadModels();
      }

      _prediction.value = 'Error classifying image';
      _showMessage('Classification failed: $e', isError: true);
    } finally {
      _isLoading.value = false;
      _processingStatus.value = '';
      // Force garbage collection after processing
      debugPrint('$tag: Cleaning up resources');
    }
    debugPrint('$tag: ====== CLASSIFICATION COMPLETE ======\n');
  }

  void _showMessage(String message, {bool isError = false}) {
    Get.snackbar(
      isError ? 'Error' : 'Success',
      message,
      backgroundColor: isError ? Colors.red : Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void onClose() {
    _cachedModel = null;
    _cachedLabels = null;
    super.onClose();
  }
}
