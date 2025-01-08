import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/zeroshot_controller.dart';

class ZeroShotView extends GetView<ZeroShotController> {
  const ZeroShotView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zero Shot Detection'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
            // Detection Result
            Obx(() {
              if (!controller.isLoading && controller.image != null) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Detection Result: ${controller.result ? "True" : "False"}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: controller.result ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (controller.similarities.isNotEmpty) ...[
                        const Text(
                          'Similarities:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          controller.similarities
                              .map((s) => s.toStringAsFixed(4))
                              .join(', '),
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
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
