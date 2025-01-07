import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/controllers/classification_controller.dart';
import 'app/views/classification_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Image Classification',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialBinding: BindingsBuilder(() {
        Get.put(ClassificationController());
      }),
      home: const ClassificationView(),
    );
  }
}
