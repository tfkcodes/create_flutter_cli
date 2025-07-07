/// Returns a simple GetX controller template for managing app state.
String getxTemplate() => '''
import 'package:get/get.dart';

/// A simple GetX controller for counter management
class CounterController extends GetxController {
  /// Observable counter value
  var count = 0.obs;

  /// Increments the counter
  void increment() {
    count.value++;
  }

  /// Resets the counter
  void reset() {
    count.value = 0;
  }
}
''';
