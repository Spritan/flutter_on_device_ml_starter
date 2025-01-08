import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/zeroshot_controller.dart';
import '../controllers/classification_controller.dart';

class CompleteWorkflowView extends StatelessWidget {
  const CompleteWorkflowView({super.key});

  @override
  Widget build(BuildContext context) {
    final zeroShotController = Get.find<ZeroShotController>();
    final classificationController = Get.find<ClassificationController>();

    Future<void> processImage(ImageSource source) async {
      // First, run zero-shot detection
      await zeroShotController.getImage(source);

      // If zero-shot detection is successful, proceed with classification
      if (zeroShotController.result && zeroShotController.image != null) {
        await classificationController.getImage(source);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Analysis Workflow'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Model Loading Status
            Obx(() {
              if (!zeroShotController.modelLoaded ||
                  !classificationController.modelLoaded) {
                final status = !zeroShotController.modelLoaded
                    ? zeroShotController.modelLoadingStatus
                    : classificationController.modelLoadingStatus;

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
              final currentImage =
                  zeroShotController.image ?? classificationController.image;
              if (currentImage != null) {
                return Column(
                  children: [
                    Image.file(
                      currentImage,
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
              final zeroShotStatus = zeroShotController.processingStatus;
              final classificationStatus =
                  classificationController.processingStatus;
              final status = zeroShotStatus.isNotEmpty
                  ? zeroShotStatus
                  : classificationStatus;

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

            // Results Display
            Obx(() {
              if (zeroShotController.image != null) {
                // Don't show result while processing
                if (zeroShotController.isLoading) {
                  return const SizedBox.shrink();
                }

                if (!zeroShotController.result) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No plants or plant parts detected in the image',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else if (!classificationController.isLoading &&
                    classificationController.prediction.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Plant detected!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          classificationController.prediction,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                } else if (zeroShotController.result) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Plant detected! Analyzing...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
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
                  onPressed: (zeroShotController.modelLoaded &&
                          classificationController.modelLoaded &&
                          !zeroShotController.isLoading &&
                          !classificationController.isLoading)
                      ? () => processImage(ImageSource.camera)
                      : null,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Photo'),
                )),
            Obx(() => ElevatedButton.icon(
                  onPressed: (zeroShotController.modelLoaded &&
                          classificationController.modelLoaded &&
                          !zeroShotController.isLoading &&
                          !classificationController.isLoading)
                      ? () => processImage(ImageSource.gallery)
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
