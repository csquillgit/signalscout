enum CarrierType {
  verizon,
  att,
  tmobile,
  other;

  String get displayName {
    switch (this) {
      case CarrierType.verizon:
        return 'Verizon';
      case CarrierType.att:
        return 'AT&T';
      case CarrierType.tmobile:
        return 'T-Mobile';
      case CarrierType.other:
        return 'UScellular / Other';
    }
  }

  String get shortName {
    switch (this) {
      case CarrierType.verizon:
        return 'VZW';
      case CarrierType.att:
        return 'ATT';
      case CarrierType.tmobile:
        return 'T-MO';
      case CarrierType.other:
        return 'OTHER';
    }
  }
}

class CellTower {
  final String id;
  final String asrNumber; // FCC Antenna Structure Registration # or OpenCellID Cell ID
  final CarrierType carrier;
  final String siteName;
  final double latitude;
  final double longitude;
  final double heightAglMeters; // Height Above Ground Level in meters
  final double elevationAmslMeters; // Elevation Above Mean Sea Level
  final List<String> bands; // e.g., ["LTE B13 (700)", "LTE B4/B66", "5G n77"]
  final String structureType; // "Monopole", "Self-Support Lattice", "Guyed Tower", "Rooftop"
  final String licensee;
  final bool isCustom;

  const CellTower({
    required this.id,
    required this.asrNumber,
    required this.carrier,
    required this.siteName,
    required this.latitude,
    required this.longitude,
    required this.heightAglMeters,
    required this.elevationAmslMeters,
    required this.bands,
    required this.structureType,
    required this.licensee,
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'asrNumber': asrNumber,
        'carrier': carrier.name,
        'siteName': siteName,
        'latitude': latitude,
        'longitude': longitude,
        'heightAglMeters': heightAglMeters,
        'elevationAmslMeters': elevationAmslMeters,
        'bands': bands,
        'structureType': structureType,
        'licensee': licensee,
        'isCustom': isCustom,
      };

  factory CellTower.fromJson(Map<String, dynamic> json) => CellTower(
        id: json['id'] as String,
        asrNumber: json['asrNumber'] as String,
        carrier: CarrierType.values.firstWhere(
          (c) => c.name == json['carrier'],
          orElse: () => CarrierType.other,
        ),
        siteName: json['siteName'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        heightAglMeters: (json['heightAglMeters'] as num).toDouble(),
        elevationAmslMeters: (json['elevationAmslMeters'] as num).toDouble(),
        bands: List<String>.from(json['bands'] as List),
        structureType: json['structureType'] as String,
        licensee: json['licensee'] as String,
        isCustom: json['isCustom'] as bool? ?? false,
      );
}
