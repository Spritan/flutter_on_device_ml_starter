import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/classification_controller.dart';

class ClassificationView extends GetView<ClassificationController> {
  const ClassificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Classification'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          Obx(() {
            if (controller.modelLoaded) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: controller.reloadModels,
                tooltip: 'Reload Models',
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // Model Loading Status
            Obx(() {
              final status = controller.modelLoadingStatus;
              if (status.isNotEmpty && !controller.modelLoaded) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 10),
                      Text(
                        status,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            // Image Display
            Obx(() {
              if (controller.image != null) {
                return Column(
                  children: [
                    Image.file(
                      controller.image!,
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
            // Processing Status
            Obx(() {
              final status = controller.processingStatus;
              if (status.isNotEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 10),
                      Text(
                        status,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            // Prediction Result
            Obx(() {
              if (controller.isLoading) {
                return const CircularProgressIndicator();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  controller.prediction,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Obx(() => ElevatedButton.icon(
                  onPressed: controller.modelLoaded
                      ? () => controller.getImage(ImageSource.camera)
                      : null,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Photo'),
                )),
            Obx(() => ElevatedButton.icon(
                  onPressed: controller.modelLoaded
                      ? () => controller.getImage(ImageSource.gallery)
                      : null,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Choose from Gallery'),
                )),
          ],
        ),
      ),
    );
  }
}
