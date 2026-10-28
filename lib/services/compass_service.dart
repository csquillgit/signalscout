import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';

class CompassService extends ChangeNotifier {
  static final CompassService _instance = CompassService._internal();
  factory CompassService() => _instance;
  CompassService._internal();

  double _heading = 0.0; // 0..360
  double _manualOffset = 0.0;
  bool _hasHardwareCompass = false;
  StreamSubscription<CompassEvent>? _compassSub;

  double get heading => (_heading + _manualOffset) % 360.0;
  bool get hasHardwareCompass => _hasHardwareCompass;

  Future<void> init() async {
    try {
      if (FlutterCompass.events != null) {
        _compassSub = FlutterCompass.events!.listen((event) {
          if (event.heading != null) {
            _hasHardwareCompass = true;
            // Smooth or set heading
            _heading = (event.heading! + 360.0) % 360.0;
            notifyListeners();
          }
        }, onError: (e) {
          debugPrint('Compass hardware stream error: $e');
        });
      }
    } catch (e) {
      debugPrint('Compass initialization note: $e');
    }
  }

  void setManualHeading(double degrees) {
    _heading = degrees % 360.0;
    notifyListeners();
  }

  void adjustHeading(double deltaDegrees) {
    _manualOffset = (_manualOffset + deltaDegrees) % 360.0;
    notifyListeners();
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    super.dispose();
  }
}
