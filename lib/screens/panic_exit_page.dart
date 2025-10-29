import 'package:get/get.dart'; // Using GetX for simple stack replacement
import 'camouflage_page.dart'; // Import your new fake screen

// REMOVED: 'package:shake/shake.dart';

// ADDED: Imports for the new sensor logic
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math'; // For the square root calculation

class PanicExitPage {
  // REPLACED: _detector with a StreamSubscription
  static StreamSubscription? _shakeSubscription;

  // ADDED: Throttling variables
  static DateTime? _lastShakeTime;
  // This threshold is now in G's, matching your old package's setting of 2.7
  static double _shakeThresholdGForce = 2.7;

  // Call this method once in your main.dart file to start listening
  static void initialize() {
    // Stop any existing listener before starting a new one
    dispose();

    // REPLACED: ShakeDetector with sensors_plus logic
    _shakeSubscription = userAccelerometerEvents.listen(
      (UserAccelerometerEvent event) {
        
        // Calculate the approximate G-force on the device
        // User acceleration (in m/s^2) is gravity-compensated.
        // We convert it to G's (1G = 9.81 m/s^2)
        double gForce = sqrt(
          (event.x * event.x) + 
          (event.y * event.y) + 
          (event.z * event.z)
        ) / 9.81; // 9.81 is the standard gravity

        // Check if the G-force exceeds the threshold
        if (gForce > _shakeThresholdGForce) {
          final now = DateTime.now();

          // Throttle to prevent multiple triggers for one shake
          // (e.g., only trigger once every 3 seconds)
          if (_lastShakeTime == null || 
              now.difference(_lastShakeTime!) > const Duration(seconds: 3)) {
            
            _lastShakeTime = now;
            
            // This is the trigger!
            triggerPanicExit();
          }
        }
      },
      onError: (e) {
        // Optional: Add logging for sensor errors
        print("PanicExitPage: Error listening to sensors: $e");
      },
      cancelOnError: true,
    );
  }

  // This is the core action (UNCHANGED)
  static void triggerPanicExit() {
    // This is the most important part.
    // Get.offAll() REMOVES all previous screens (like the report page)
    // from memory and replaces them with the CamouflageScreen.
    //
    // This ensures that even if the app is closed and re-opened,
    // it will still show the fake screen until it's fully restarted.
    Get.offAll(() => const CamouflagePage());
  }

  // You could call this if the user logs out
  static void dispose() {
    // UPDATED: This now correctly stops the listener
    _shakeSubscription?.cancel();
    _shakeSubscription = null;
    _lastShakeTime = null; // Reset throttle timer
  }
}
