import 'cell_tower.dart';

class DeadZone {
  final String id;
  final String title;
  final double latitude;
  final double longitude;
  final CarrierType carrier;
  final int signalBars; // 0, 1, or 2 (0 = complete blackout, 1 = SOS only / unusable)
  final String notes;
  final DateTime timestamp;

  const DeadZone({
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.carrier,
    required this.signalBars,
    required this.notes,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'latitude': latitude,
        'longitude': longitude,
        'carrier': carrier.name,
        'signalBars': signalBars,
        'notes': notes,
        'timestamp': timestamp.toIso8601String(),
      };

  factory DeadZone.fromJson(Map<String, dynamic> json) => DeadZone(
        id: json['id'] as String,
        title: json['title'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        carrier: CarrierType.values.firstWhere(
          (c) => c.name == json['carrier'],
          orElse: () => CarrierType.other,
        ),
        signalBars: json['signalBars'] as int? ?? 0,
        notes: json['notes'] as String? ?? '',
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
