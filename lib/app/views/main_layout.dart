import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'classification_view.dart';
import 'zeroshot_view.dart';
import 'complete_workflow_view.dart';

class MainLayout extends StatelessWidget {
  MainLayout({super.key});

  final RxInt _currentIndex = 0.obs;

  final List<Widget> _pages = [
    const CompleteWorkflowView(),
    const ZeroShotView(),
    const ClassificationView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => _pages[_currentIndex.value]),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: _currentIndex.value,
          onDestinationSelected: (index) => _currentIndex.value = index,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.auto_awesome),
              label: 'Complete Workflow',
            ),
            NavigationDestination(
              icon: Icon(Icons.camera),
              label: 'Zero Shot',
            ),
            NavigationDestination(
              icon: Icon(Icons.image_search),
              label: 'Classification',
            ),
          ],
        ),
      ),
    );
  }
}
