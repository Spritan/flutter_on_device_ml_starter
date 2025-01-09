import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ondevice_ml/app/config/model_config.dart';

class ModelConfig {
  final String name;
  String url;
  final String localPath;
  final String type;
  final _isDownloaded = false.obs;

  bool get isDownloaded => _isDownloaded.value;
  set isDownloaded(bool value) => _isDownloaded.value = value;

  ModelConfig({
    required this.name,
    required this.url,
    required this.localPath,
    required this.type,
    bool isDownloaded = false,
  }) {
    _isDownloaded.value = isDownloaded;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
        'localPath': localPath,
        'type': type,
        'isDownloaded': _isDownloaded.value,
      };

  factory ModelConfig.fromJson(Map<String, dynamic> json) => ModelConfig(
        name: json['name'],
        url: json['url'],
        localPath: json['localPath'],
        type: json['type'],
        isDownloaded: json['isDownloaded'] ?? false,
      );
}

class SettingsController extends GetxController {
  static const String tag = 'SettingsController';
  final _storage = GetStorage();

  // Available models with reactive lists
  final _zeroshotModels = <ModelConfig>[].obs;
  final _classificationModels = <ModelConfig>[].obs;
  final _isDownloading = false.obs;
  final _downloadProgress = 0.0.obs;
  final _downloadStatus = ''.obs;
  http.Client? _currentDownloadClient;
  String? _currentDownloadingModel;

  List<ModelConfig> get zeroshotModels => _zeroshotModels;
  List<ModelConfig> get classificationModels => _classificationModels;
  bool get isDownloading => _isDownloading.value;
  double get downloadProgress => _downloadProgress.value;
  String get downloadStatus => _downloadStatus.value;

  @override
  void onInit() {
    super.onInit();
    _initializeModels();
    _loadConfigs();
    _verifyDownloadedFiles();
  }

  void _initializeModels() {
    // Initialize zero-shot models
    _zeroshotModels.value = ModelConfigs.getZeroShotConfigs()
        .map((config) => ModelConfig(
              name: config['name']!,
              url: config['url']!,
              localPath: config['localPath']!,
              type: config['type']!,
            ))
        .toList();

    // Initialize classification models
    _classificationModels.value = ModelConfigs.getClassificationConfigs()
        .map((config) => ModelConfig(
              name: config['name']!,
              url: config['url']!,
              localPath: config['localPath']!,
              type: config['type']!,
            ))
        .toList();
  }

  void _loadConfigs() {
    try {
      final storedZeroshotConfigs = _storage.read('zeroshot_models');
      final storedClassificationConfigs =
          _storage.read('classification_models');

      if (storedZeroshotConfigs != null) {
        for (var i = 0; i < _zeroshotModels.length; i++) {
          final stored = (storedZeroshotConfigs as List)[i];
          _zeroshotModels[i].isDownloaded = stored['isDownloaded'] ?? false;
        }
      }

      if (storedClassificationConfigs != null) {
        for (var i = 0; i < _classificationModels.length; i++) {
          final stored = (storedClassificationConfigs as List)[i];
          _classificationModels[i].isDownloaded =
              stored['isDownloaded'] ?? false;
        }
      }
    } catch (e) {
      debugPrint('Error loading configs: $e');
    }
  }

  Future<void> _verifyDownloadedFiles() async {
    try {
      final dir = await getApplicationDocumentsDirectory();

      // Verify zero-shot models
      for (var model in _zeroshotModels) {
        final file = File('${dir.path}/${model.localPath}');
        final exists = await file.exists();
        model.isDownloaded = exists;
        if (exists) {
          debugPrint('$tag: Found ${model.name} at: ${file.path}');
        }
      }
      _zeroshotModels.refresh();

      // Verify classification models
      for (var model in _classificationModels) {
        final file = File('${dir.path}/${model.localPath}');
        final exists = await file.exists();
        model.isDownloaded = exists;
        if (exists) {
          debugPrint('$tag: Found ${model.name} at: ${file.path}');
        }
      }
      _classificationModels.refresh();

      _saveConfigs();
    } catch (e) {
      debugPrint('Error verifying files: $e');
    }
  }

  void _saveConfigs() {
    try {
      _storage.write('zeroshot_models',
          _zeroshotModels.map((model) => model.toJson()).toList());
      _storage.write('classification_models',
          _classificationModels.map((model) => model.toJson()).toList());
    } catch (e) {
      debugPrint('Error saving configs: $e');
    }
  }

  Future<void> downloadModel(ModelConfig model) async {
    if (_isDownloading.value) {
      Get.snackbar(
        'Notice',
        'Another download is in progress',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/${model.localPath}';
      final file = File(filePath);

      if (await file.exists()) {
        model.isDownloaded = true;
        if (model.type == 'zeroshot') {
          _zeroshotModels.refresh();
        } else {
          _classificationModels.refresh();
        }
        _saveConfigs();

        Get.snackbar(
          'Notice',
          '${model.name} is already downloaded',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        return;
      }

      _isDownloading.value = true;
      _downloadProgress.value = 0;
      _downloadStatus.value = 'Starting download: ${model.name}';
      _currentDownloadingModel = model.name;

      final client = http.Client();
      _currentDownloadClient = client;
      final request = http.Request('GET', Uri.parse(model.url));
      final response = await client.send(request);

      if (response.statusCode == 200) {
        final totalBytes = response.contentLength ?? 0;
        var downloadedBytes = 0;

        final sink = file.openWrite();
        await response.stream.listen(
          (chunk) {
            sink.add(chunk);
            downloadedBytes += chunk.length;
            if (totalBytes > 0) {
              final progress = downloadedBytes / totalBytes;
              _downloadProgress.value = progress;
              final percentage = (progress * 100).toStringAsFixed(1);
              final downloadedMB =
                  (downloadedBytes / 1024 / 1024).toStringAsFixed(2);
              final totalMB = (totalBytes / 1024 / 1024).toStringAsFixed(2);
              _downloadStatus.value =
                  'Downloading ${model.name}: $percentage% ($downloadedMB MB / $totalMB MB)';
            }
          },
          onDone: () async {
            await sink.close();
            model.isDownloaded = true;
            if (model.type == 'zeroshot') {
              _zeroshotModels.refresh();
            } else {
              _classificationModels.refresh();
            }
            _saveConfigs();

            Get.snackbar(
              'Success',
              '${model.name} downloaded successfully',
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          },
          onError: (error) {
            throw Exception('Download stream error: $error');
          },
          cancelOnError: true,
        ).asFuture();

        client.close();
        _currentDownloadClient = null;
        _currentDownloadingModel = null;
      } else {
        throw Exception(
            'Failed to download model: HTTP ${response.statusCode}');
      }
    } catch (e) {
      model.isDownloaded = false;
      if (model.type == 'zeroshot') {
        _zeroshotModels.refresh();
      } else {
        _classificationModels.refresh();
      }
      _saveConfigs();

      Get.snackbar(
        'Error',
        'Failed to download ${model.name}: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      _isDownloading.value = false;
      _downloadProgress.value = 0;
      _downloadStatus.value = '';
      _currentDownloadClient = null;
      _currentDownloadingModel = null;
    }
  }

  void cancelDownload() async {
    if (_currentDownloadClient != null) {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Cancel Download'),
          content: Text(
              'Are you sure you want to cancel downloading $_currentDownloadingModel?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Yes, Cancel'),
            ),
          ],
        ),
        barrierDismissible: false,
      );

      if (result == true) {
        debugPrint(
            '\n$tag: ====== CANCELING DOWNLOAD: $_currentDownloadingModel ======');
        _currentDownloadClient?.close();
        _currentDownloadClient = null;
        _currentDownloadingModel = null;
        _isDownloading.value = false;
        _downloadProgress.value = 0;
        _downloadStatus.value = '';
        debugPrint('$tag: Download canceled');

        Get.snackbar(
          'Download Canceled',
          'The download was canceled',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  Future<void> deleteModel(ModelConfig model) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/${model.localPath}';
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
        model.isDownloaded = false;
        _saveConfigs();

        Get.snackbar(
          'Success',
          '${model.name} deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      debugPrint('Error deleting model: $e');
      Get.snackbar(
        'Error',
        'Failed to delete ${model.name}: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }
}
