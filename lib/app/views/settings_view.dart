import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:ondevice_ml/app/controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  Widget _buildModelCard(ModelConfig model) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              model.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Obx(() => model.isDownloaded
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                )
                              : const SizedBox.shrink()),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Type: ${model.type}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                            model.isDownloaded
                                ? 'Status: Downloaded'
                                : 'Status: Not Downloaded',
                            style: TextStyle(
                              color: model.isDownloaded
                                  ? Colors.green
                                  : Colors.grey[600],
                              fontSize: 14,
                              fontWeight: model.isDownloaded
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          )),
                    ],
                  ),
                ),
                Obx(() => model.isDownloaded
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () => controller.downloadModel(model),
                            color: Colors.blue,
                            tooltip: 'Redownload',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => controller.deleteModel(model),
                            color: Colors.red,
                            tooltip: 'Delete',
                          ),
                        ],
                      )
                    : const SizedBox.shrink()),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              if (model.isDownloaded || controller.isDownloading) {
                return const SizedBox.shrink();
              }
              return ElevatedButton.icon(
                onPressed: () => controller.downloadModel(model),
                icon: const Icon(Icons.download),
                label: const Text('Download'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 36),
                ),
              );
            }),
            if (controller.isDownloading &&
                controller.downloadStatus.contains(model.name))
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.downloadStatus,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: controller.cancelDownload,
                        color: Colors.red,
                        tooltip: 'Cancel download',
                        iconSize: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: controller.downloadProgress,
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Zero-Shot Detection Models',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Obx(() => Column(
                  children: controller.zeroshotModels
                      .map((model) => _buildModelCard(model))
                      .toList(),
                )),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Classification Models',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Obx(() => Column(
                  children: controller.classificationModels
                      .map((model) => _buildModelCard(model))
                      .toList(),
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
