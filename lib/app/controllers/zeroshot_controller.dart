import 'dart:io';
import 'dart:math' show sqrt;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:ondevice_ml/generated/clip_tf/tokenized_prompts.pb.dart';

// Extension to help with tensor reshaping
extension Float32ListReshape on Float32List {
  Float32List reshape(List<int> shape) {
    assert(length == shape.reduce((a, b) => a * b),
        'Shape dimensions must match array length');
    return this;
  }
}

class ZeroShotController extends GetxController {
  static ZeroShotController get to => Get.find();
  static const String tag = 'ZeroShotController';

  // Model paths
  static const String imageEncoderPath =
      'assets/models/CLIPImageEncoder.tflite';
  static const String textEncoderPath = 'assets/models/CLIPTextEncoder.tflite';
  static const String promptsPath = 'assets/models/tokenized_prompts.pb';

  final _imageEncoder = Rxn<Interpreter>();
  final _textEncoder = Rxn<Interpreter>();
  final _image = Rxn<File>();
  final _result = RxBool(false);
  final _similarities = RxList([]);
  final _isLoading = RxBool(false);
  final _modelLoaded = RxBool(false);
  final _modelLoadingStatus = RxString('Not started');
  final _processingStatus = RxString('');

  // Getters
  File? get image => _image.value;
  bool get result => _result.value;
  List get similarities => _similarities;
  bool get isLoading => _isLoading.value;
  bool get modelLoaded => _modelLoaded.value;
  String get modelLoadingStatus => _modelLoadingStatus.value;
  String get processingStatus => _processingStatus.value;

  final ImagePicker _picker = ImagePicker();
  static const double _threshold = 0.27;

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
      debugPrint('$tag: Loading image encoder from $imageEncoderPath');
      _modelLoadingStatus.value = 'Loading image encoder...';
      final imageEncoderFile = await _getAssetFile(imageEncoderPath);
      _imageEncoder.value = Interpreter.fromFile(imageEncoderFile);
      _imageEncoder.value!.allocateTensors();

      debugPrint('$tag: Loading text encoder from $textEncoderPath');
      _modelLoadingStatus.value = 'Loading text encoder...';
      final textEncoderFile = await _getAssetFile(textEncoderPath);
      _textEncoder.value = Interpreter.fromFile(textEncoderFile);
      _textEncoder.value!.allocateTensors();

      debugPrint('$tag: Loading tokenized prompts from $promptsPath');
      _modelLoadingStatus.value = 'Loading prompts...';
      await _getAssetFile(promptsPath);

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
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) {
        debugPrint('$tag: No image selected');
        _processingStatus.value = '';
        return;
      }

      debugPrint('$tag: Image selected: ${pickedFile.path}');
      _image.value = File(pickedFile.path);
      _result.value = false;
      _similarities.clear();
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

    if (_image.value == null ||
        _imageEncoder.value == null ||
        _textEncoder.value == null) {
      debugPrint('$tag: Prerequisites not met');
      _showMessage('Models or image not ready', isError: true);
      _isLoading.value = false;
      _processingStatus.value = '';
      return;
    }

    try {
      _processingStatus.value = 'Processing image...';

      // Preprocess image
      final imageInput = await _preprocessImage(_image.value!);

      // Get image embedding
      final imageEmbedding = await _getImageEmbedding(imageInput);

      // Load and process text embeddings
      final textEmbeddings = await _getTextEmbeddings();

      // Calculate similarities
      final similarities = <double>[];
      for (final textEmbedding in textEmbeddings) {
        similarities.add(_cosineSimilarity(imageEmbedding, textEmbedding));
      }

      _similarities.value = similarities;
      _result.value = similarities.any((sim) => sim > _threshold);

      debugPrint('$tag: Classification complete');
      debugPrint('$tag: Similarities: $similarities');
      debugPrint('$tag: Result: ${_result.value}');

      _isLoading.value = false;
      _processingStatus.value = '';
    } catch (e, stackTrace) {
      debugPrint('\n$tag: !!!!! CLASSIFICATION ERROR !!!!');
      debugPrint('$tag: Error type: ${e.runtimeType}');
      debugPrint('$tag: Error message: $e');
      debugPrint('$tag: Stack trace:\n$stackTrace');

      _isLoading.value = false;
      _processingStatus.value = '';
      _showMessage('Classification failed: $e', isError: true);
    }
    debugPrint('$tag: ====== CLASSIFICATION COMPLETE ======\n');
  }

  Future<List<List>> _preprocessImage(File imageFile) async {
    debugPrint('$tag: Preprocessing image');

    try {
      // Load and decode image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) throw Exception('Failed to decode image');

      final resized = img.copyResize(image, width: 224, height: 224);

      // Create 3D array [height][width][channels]
      final processedData = List.generate(
        224,
        (_) => List.generate(
          224,
          (_) => List.filled(3, 0.0),
        ),
      );

      for (var y = 0; y < 224; y++) {
        for (var x = 0; x < 224; x++) {
          final pixel = resized.getPixel(x, y);
          processedData[y][x][0] = pixel.r.toDouble() / 255.0;
          processedData[y][x][1] = pixel.g.toDouble() / 255.0;
          processedData[y][x][2] = pixel.b.toDouble() / 255.0;
        }
      }

      debugPrint('$tag: Image preprocessed to 3D array');
      debugPrint(
          '$tag: Array shape: ${processedData.length}x${processedData[0].length}x${processedData[0][0].length}');
      debugPrint('$tag: Array type: ${processedData[0][0][0].runtimeType}');
      debugPrint('$tag: _preprocessImage done');
      return [
        processedData.expand((row) => row.expand((pixel) => pixel)).toList()
      ];
    } catch (e, stackTrace) {
      debugPrint('$tag: Error preprocessing image: $e');
      debugPrint('$tag: Stack trace:\n$stackTrace');
      rethrow;
    }
  }

  Future<List> _getImageEmbedding(List<List> imageInput) async {
    debugPrint('$tag: Getting image embedding');

    try {
      debugPrint('$tag: imageInput shape: ${imageInput.shape}');
      // Create output buffer
      final outputBuffer = List.filled(512, 0.0)
          .reshape([1, 512]); // Assuming output size is 512

      final inputArrayReshaped = imageInput.reshape([1, 224, 224, 3]);
      debugPrint('$tag: Input array shape: ${inputArrayReshaped.shape}');

      // Create isolate interpreter
      final isolateInterpreter = await IsolateInterpreter.create(
          address: _imageEncoder.value!.address);

      // Run inference asynchronously
      await isolateInterpreter.run(inputArrayReshaped, outputBuffer);

      // Clean up
      await isolateInterpreter.close();

      debugPrint(
          '$tag: Generated image embedding of length ${outputBuffer.shape}');
      return outputBuffer;
    } catch (e, stackTrace) {
      debugPrint('$tag: Error getting image embedding: $e');
      debugPrint('$tag: Stack trace:\n$stackTrace');
      rethrow;
    }
  }

  Future<List<List>> _getTextEmbeddings() async {
    debugPrint('$tag: Getting text embeddings');

    try {
      // Load tokenized prompts
      final promptsFile = await _getAssetFile(promptsPath);
      final promptsBytes = await promptsFile.readAsBytes();
      final tokenizedInputs = await _parseTokenizedPrompts(promptsBytes);

      final embeddings = <List>[];

      // Create isolate interpreter
      final isolateInterpreter =
          await IsolateInterpreter.create(address: _textEncoder.value!.address);

      // Process each tokenized input
      for (final tokens in tokenizedInputs) {
        final inputBuffer = List.from(tokens);
        final outputBuffer = List.filled(512, 0.0).reshape([1, 512]);

        _textEncoder.value!.resizeInputTensor(0, [1, tokens.length]);
        _textEncoder.value!.allocateTensors();

        // Run inference asynchronously
        await isolateInterpreter.run(inputBuffer, outputBuffer);

        embeddings.add(outputBuffer.toList());
      }

      // Clean up
      await isolateInterpreter.close();

      debugPrint('$tag: Generated ${embeddings.shape} text embeddings');
      return embeddings;
    } catch (e) {
      debugPrint('$tag: Error getting text embeddings: $e');
      rethrow;
    }
  }

  Future<List<List<int>>> _parseTokenizedPrompts(Uint8List bytes) async {
    try {
      debugPrint('$tag: Parsing tokenized prompts');
      final tokenizedPrompts = TokenizedPrompts.fromBuffer(bytes);

      final result = tokenizedPrompts.prompts
          .map((prompt) => prompt.inputIds.map((id) => id.toInt()).toList())
          .toList();

      debugPrint('$tag: Parsed ${result.length} prompts');
      return result;
    } catch (e) {
      debugPrint('$tag: Error parsing tokenized prompts: $e');
      throw Exception('Failed to parse tokenized prompts: $e');
    }
  }

  double _cosineSimilarity(List a, List b) {
    // Flatten nested lists if present
    final List<double> flatA =
        a[0] is List ? (a[0] as List).cast<double>() : a.cast<double>();
    final List<double> flatB =
        b[0] is List ? (b[0] as List).cast<double>() : b.cast<double>();

    if (flatA.length != flatB.length) {
      throw Exception('Vectors must have equal length');
    }

    debugPrint('$tag: Calculating cosine similarity');
    debugPrint('$tag: Vector length: ${flatA.length}');

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < flatA.length; i++) {
      dotProduct += flatA[i] * flatB[i];
      normA += flatA[i] * flatA[i];
      normB += flatB[i] * flatB[i];
    }

    if (normA == 0 || normB == 0) {
      return 0.0; // Handle zero vectors
    }

    return dotProduct / (sqrt(normA) * sqrt(normB));
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
