import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cell_tower.dart';
import '../models/dead_zone.dart';

class DeadZoneService extends ChangeNotifier {
  static final DeadZoneService _instance = DeadZoneService._internal();
  factory DeadZoneService() => _instance;
  DeadZoneService._internal();

  static const String _storageKey = 'signalscout_dead_zones';
  List<DeadZone> _deadZones = [];

  List<DeadZone> get deadZones => List.unmodifiable(_deadZones);

  Future<void> init() async {
    await _load();
  }

  Future<void> addDeadZone({
    required String title,
    required double latitude,
    required double longitude,
    required CarrierType carrier,
    required int signalBars,
    required String notes,
  }) async {
    final newEntry = DeadZone(
      id: 'dz_${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim().isEmpty ? 'Dead Spot ${latitude.toStringAsFixed(3)}, ${longitude.toStringAsFixed(3)}' : title.trim(),
      latitude: latitude,
      longitude: longitude,
      carrier: carrier,
      signalBars: signalBars,
      notes: notes,
      timestamp: DateTime.now(),
    );

    _deadZones.insert(0, newEntry);
    await _save();
    notifyListeners();
  }

  Future<void> deleteDeadZone(String id) async {
    _deadZones.removeWhere((dz) => dz.id == id);
    await _save();
    notifyListeners();
  }

  Future<void> clearAll() async {
    _deadZones.clear();
    await _save();
    notifyListeners();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final List list = jsonDecode(raw);
        _deadZones = list.map((e) => DeadZone.fromJson(e)).toList();
      } else {
        // Pre-populate with a couple of realistic backcountry dead spots for immediate out-of-the-box utility
        _deadZones = [
          DeadZone(
            id: 'dz_init_1',
            title: 'Franconia Notch Shadow Zone',
            latitude: 44.1720,
            longitude: -71.6850,
            carrier: CarrierType.verizon,
            signalBars: 0,
            notes: 'Deep granite gorge canyon blocks 700MHz line-of-sight. Need booster at Profile Lake parking.',
            timestamp: DateTime.now().subtract(const Duration(days: 3)),
          ),
          DeadZone(
            id: 'dz_init_2',
            title: 'Tuckerman Ravine Headwall',
            latitude: 44.2620,
            longitude: -71.2980,
            carrier: CarrierType.att,
            signalBars: 1,
            notes: 'Mountain mass shields summit repeater. Intermittent SOS only.',
            timestamp: DateTime.now().subtract(const Duration(days: 7)),
          ),
        ];
        await _save();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading dead zones: $e');
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_deadZones.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('Error saving dead zones: $e');
    }
  }
}
