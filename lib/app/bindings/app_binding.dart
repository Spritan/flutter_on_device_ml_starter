import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../controllers/classification_controller.dart';
import '../controllers/zeroshot_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SettingsController(), permanent: true);
    Get.put(ZeroShotController(), permanent: true);
    Get.put(ClassificationController(), permanent: true);
  }
}
