import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/controllers/classification_controller.dart';
import 'app/controllers/zeroshot_controller.dart';
import 'app/views/main_layout.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize controllers
  Get.put(ZeroShotController());
  Get.put(ClassificationController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Plant Analysis',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: MainLayout(),
    );
  }
}
