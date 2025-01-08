import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/controllers/classification_controller.dart';
import 'app/controllers/zeroshot_controller.dart';
import 'app/views/classification_view.dart';
import 'app/views/zeroshot_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'ML Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialBinding: BindingsBuilder(() {
        Get.put(ClassificationController());
        Get.put(ZeroShotController());
      }),
      home: const MainNavigationView(),
    );
  }
}

class MainNavigationView extends StatelessWidget {
  const MainNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    final RxInt currentIndex = 0.obs;

    return Obx(() => Scaffold(
          body: IndexedStack(
            index: currentIndex.value,
            children: const [
              ClassificationView(),
              ZeroShotView(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex.value,
            onDestinationSelected: (index) => currentIndex.value = index,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.image_search),
                label: 'Classification',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_awesome),
                label: 'Zero Shot',
              ),
            ],
          ),
        ));
  }
}
