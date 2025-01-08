import 'dart:io';
import 'package:get/get.dart';
import 'zeroshot_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pytorch_lite/pytorch_lite.dart';
import 'package:path_provider/path_provider.dart';

class ClassificationController extends GetxController {
  static ClassificationController get to => Get.find();
  static const String tag = 'ClassificationController';

  final _model = Rxn<ClassificationModel>();
  final _image = Rxn<File>();
  final _prediction = RxString('');
  final _isLoading = RxBool(false);
  final _modelLoaded = RxBool(false);
  final _modelLoadingStatus = RxString('Not started');
  final _processingStatus = RxString('');

  // Getters
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
    _loadModel();
  }

  Future<void> _loadModel() async {
    debugPrint('\n$tag: ====== STARTING MODEL LOADING ======');
    _modelLoadingStatus.value = 'Loading model...';

    try {
      debugPrint('$tag: Checking assets directory');
      _modelLoadingStatus.value = 'Checking model files...';

      // Verify model file exists
      try {
        final modelFile = await _getAssetFile('assets/models/model.pt');
        debugPrint('$tag: Model file size: ${await modelFile.length()} bytes');
      } catch (e) {
        throw Exception('Model file not found: $e');
      }

      // Verify and read labels file
      debugPrint('$tag: Reading labels file');
      _modelLoadingStatus.value = 'Reading labels...';

      late final int labelCount;
      try {
        final labelsFile = await _getAssetFile('assets/labels/labels.txt');
        final labels = await labelsFile.readAsLines();
        labelCount = labels.where((line) => line.trim().isNotEmpty).length + 1;
        debugPrint('$tag: Found $labelCount labels');
      } catch (e) {
        throw Exception('Failed to read labels file: $e');
      }

      // Load the model
      debugPrint('$tag: Loading PyTorch model');
      _modelLoadingStatus.value = 'Initializing model...';

      final model = await PytorchLite.loadClassificationModel(
        'assets/models/model.pt',
        224,
        224,
        labelCount,
        labelPath: 'assets/labels/labels.txt',
      );

      _model.value = model;
      _modelLoaded.value = true;
      _modelLoadingStatus.value = 'Model loaded successfully';
      debugPrint('$tag: Model loaded successfully');
      _showMessage('Model loaded successfully');
    } catch (e, stackTrace) {
      final errorMsg = 'Failed to load model: $e';
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

  Future<File> _getAssetFile(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${assetPath.split('/').last}');
      await tempFile.writeAsBytes(bytes);

      return tempFile;
    } catch (e) {
      throw Exception('Asset not found: $assetPath');
    }
  }

  Future<void> getImage(ImageSource source) async {
    debugPrint('\n$tag: ====== STARTING IMAGE CAPTURE ======');
    _processingStatus.value = 'Selecting image...';

    try {
      File? imageFile;
      if (Get.isRegistered<ZeroShotController>()) {
        // Try to get image from ZeroShot controller first
        final zeroShotController = Get.find<ZeroShotController>();
        imageFile = zeroShotController.image;
      }

      // If no image from ZeroShot, get from source
      if (imageFile == null) {
        final XFile? pickedFile = await _picker.pickImage(source: source);
        if (pickedFile == null) {
          debugPrint('$tag: No image selected');
          _processingStatus.value = '';
          return;
        }
        imageFile = File(pickedFile.path);
      }

      debugPrint('$tag: Image selected: ${imageFile.path}');
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
      final bytes = await _image.value!.readAsBytes();
      debugPrint('$tag: Image size: ${bytes.length} bytes');

      debugPrint('$tag: Running model inference');
      _processingStatus.value = 'Running classification...';
      final prediction = await _model.value!.getImagePrediction(bytes);
      debugPrint('$tag: Got prediction: $prediction');

      _prediction.value = 'Prediction: $prediction';
      _isLoading.value = false;
      _processingStatus.value = '';
    } catch (e, stackTrace) {
      debugPrint('\n$tag: !!!!! CLASSIFICATION ERROR !!!!');
      debugPrint('$tag: Error type: ${e.runtimeType}');
      debugPrint('$tag: Error message: $e');
      debugPrint('$tag: Stack trace:\n$stackTrace');

      _prediction.value = 'Error classifying image';
      _isLoading.value = false;
      _processingStatus.value = '';
      _showMessage('Classification failed: $e', isError: true);
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
}
