import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationPreset {
  final String id;
  final String name;
  final String region;
  final double latitude;
  final double longitude;
  final double elevationMeters;

  const LocationPreset({
    required this.id,
    required this.name,
    required this.region,
    required this.latitude,
    required this.longitude,
    required this.elevationMeters,
  });
}

class LocationService extends ChangeNotifier {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  double _latitude = 42.2626; // Default: Central MA
  double _longitude = -71.8023;
  double _altitudeMeters = 150.0;
  double _accuracyMeters = 5.0;
  bool _isSimulated = true;
  String _activeLocationName = 'Central MA (Default)';
  bool _isStreamingLive = false;
  StreamSubscription<Position>? _positionSub;

  double get latitude => _latitude;
  double get longitude => _longitude;
  double get altitudeMeters => _altitudeMeters;
  double get accuracyMeters => _accuracyMeters;
  bool get isSimulated => _isSimulated;
  String get activeLocationName => _activeLocationName;
  bool get isStreamingLive => _isStreamingLive;

  static const List<LocationPreset> presets = [
    LocationPreset(
      id: 'worcester_ma',
      name: 'Worcester / Central MA',
      region: 'Massachusetts',
      latitude: 42.2626,
      longitude: -71.8023,
      elevationMeters: 146.0,
    ),
    LocationPreset(
      id: 'shrewsbury_ma',
      name: 'Shrewsbury Route 9',
      region: 'Massachusetts',
      latitude: 42.2850,
      longitude: -71.7200,
      elevationMeters: 160.0,
    ),
    LocationPreset(
      id: 'mt_washington_nh',
      name: 'Mt. Washington Base / Tuckerman',
      region: 'White Mountains, NH',
      latitude: 44.2560,
      longitude: -71.2530,
      elevationMeters: 620.0,
    ),
    LocationPreset(
      id: 'crawford_notch_nh',
      name: 'Crawford Notch Backcountry',
      region: 'White Mountains, NH',
      latitude: 44.2050,
      longitude: -71.4050,
      elevationMeters: 550.0,
    ),
    LocationPreset(
      id: 'cape_cod_dunes',
      name: 'Cape Cod National Seashore',
      region: 'Wellfleet / Truro, MA',
      latitude: 41.9750,
      longitude: -70.0450,
      elevationMeters: 15.0,
    ),
    LocationPreset(
      id: 'adirondacks_ny',
      name: 'Adirondack High Peaks Trailhead',
      region: 'Keene Valley, NY',
      latitude: 44.1850,
      longitude: -73.8150,
      elevationMeters: 310.0,
    ),
    LocationPreset(
      id: 'shenandoah_va',
      name: 'Shenandoah Big Meadows',
      region: 'Blue Ridge, VA',
      latitude: 38.5200,
      longitude: -78.4350,
      elevationMeters: 1070.0,
    ),
  ];

  Future<void> init() async {
    // Attempt to silently pre-warm live GPS, falling back to simulated preset
    try {
      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.always || perm == LocationPermission.whileInUse) {
        await enableLiveGps();
      }
    } catch (e) {
      debugPrint('Location pre-warm note: $e');
    }
  }

  void applyPreset(LocationPreset preset) {
    _positionSub?.cancel();
    _isStreamingLive = false;
    _isSimulated = true;
    _latitude = preset.latitude;
    _longitude = preset.longitude;
    _altitudeMeters = preset.elevationMeters;
    _accuracyMeters = 3.0;
    _activeLocationName = preset.name;
    notifyListeners();
  }

  Future<bool> enableLiveGps() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      final position = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 8),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;
      _altitudeMeters = position.altitude;
      _accuracyMeters = position.accuracy;
      _isSimulated = false;
      _activeLocationName = 'Live GPS Lock';
      _isStreamingLive = true;
      notifyListeners();

      _positionSub?.cancel();
      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ).listen((pos) {
        _latitude = pos.latitude;
        _longitude = pos.longitude;
        _altitudeMeters = pos.altitude;
        _accuracyMeters = pos.accuracy;
        notifyListeners();
      });

      return true;
    } catch (e) {
      debugPrint('Error enabling live GPS: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }
}
