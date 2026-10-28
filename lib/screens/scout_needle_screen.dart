import 'package:flutter/material.dart';
import '../models/cell_tower.dart';
import '../services/compass_service.dart';
import '../services/location_service.dart';
import '../services/tower_database_service.dart';
import '../widgets/azimuth_needle_hud.dart';
import '../widgets/carrier_filter_chips.dart';
import '../widgets/hud_metric_bar.dart';

class ScoutNeedleScreen extends StatefulWidget {
  const ScoutNeedleScreen({super.key});

  @override
  State<ScoutNeedleScreen> createState() => _ScoutNeedleScreenState();
}

class _ScoutNeedleScreenState extends State<ScoutNeedleScreen> {
  final TowerDatabaseService _towerService = TowerDatabaseService();
  final LocationService _locationService = LocationService();
  final CompassService _compassService = CompassService();

  @override
  void initState() {
    super.initState();
    _towerService.addListener(_onStateChanged);
    _locationService.addListener(_onStateChanged);
    _compassService.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _towerService.removeListener(_onStateChanged);
    _locationService.removeListener(_onStateChanged);
    _compassService.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  Color _carrierColor(CarrierType carrier) {
    switch (carrier) {
      case CarrierType.verizon:
        return const Color(0xFFEF4444);
      case CarrierType.att:
        return const Color(0xFF38BDF8);
      case CarrierType.tmobile:
        return const Color(0xFFEC4899);
      case CarrierType.other:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userLat = _locationService.latitude;
    final userLon = _locationService.longitude;

    // Nearest tower or locked target
    final lockedTower = _towerService.lockedTarget;
    final nearestEntry = _towerService.getNearestTower(
      userLat: userLat,
      userLon: userLon,
    );

    final activeTower = lockedTower ?? nearestEntry?.tower;

    double distanceMeters = 0.0;
    double targetBearing = 0.0;

    if (activeTower != null) {
      distanceMeters = TowerDatabaseService.calculateDistanceMeters(
        userLat,
        userLon,
        activeTower.latitude,
        activeTower.longitude,
      );
      targetBearing = TowerDatabaseService.calculateBearingDegrees(
        userLat,
        userLon,
        activeTower.latitude,
        activeTower.longitude,
      );
    }

    final double deviceHeading = _compassService.heading;
    final int estimatedRssi =
        TowerDatabaseService.estimateRssiDbm(distanceMeters);
    final String signalQuality =
        TowerDatabaseService.signalQualityLabel(estimatedRssi);

    Color signalColor = const Color(0xFF10B981);
    if (estimatedRssi < -115) {
      signalColor = const Color(0xFFEF4444);
    } else if (estimatedRssi < -98) {
      signalColor = const Color(0xFFF59E0B);
    }

    final String distanceStr = distanceMeters < 1000
        ? '${distanceMeters.toStringAsFixed(0)} m'
        : '${(distanceMeters / 1609.344).toStringAsFixed(1)} mi';

    const cardinals = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW', 'N'];
    final cardinalIdx = ((targetBearing + 22.5) / 45.0).floor() % 8;
    final String cardinal = cardinals[cardinalIdx];

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 8.0, bottom: 94.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header & Location Selector
              _buildLocationStatusBar(context),

              const SizedBox(height: 4),

              // Carrier Filter Chips
              CarrierFilterChips(
                selectedCarrier: _towerService.activeCarrierFilter,
                onCarrierSelected: (carrier) {
                  _towerService.setCarrierFilter(carrier);
                  // Update nearest tower matching carrier
                  final nearest = _towerService.getNearestTower(
                    userLat: userLat,
                    userLon: userLon,
                    carrierFilter: carrier,
                  );
                  if (nearest != null) {
                    _towerService.lockTarget(nearest.tower);
                  }
                },
              ),

              const SizedBox(height: 6),

              // Tactical Needle HUD
              AzimuthNeedleHud(
                deviceHeading: deviceHeading,
                targetBearing: targetBearing,
                distanceMeters: distanceMeters,
                hasTarget: activeTower != null,
                carrierName: activeTower?.carrier.displayName ?? 'NO TARGET',
                carrierColor: activeTower != null
                    ? _carrierColor(activeTower.carrier)
                    : const Color(0xFF64748B),
              ),

              // 3-Column Metric Overview Bar
              HudMetricBar(
                azimuthText:
                    '${targetBearing.toStringAsFixed(0).padLeft(3, '0')}°',
                azimuthSub: cardinal,
                distanceText: distanceStr,
                distanceSub: '${(distanceMeters / 1000).toStringAsFixed(1)} km',
                signalDbmText: '$estimatedRssi dBm',
                signalQualityText: signalQuality,
                signalColor: signalColor,
              ),

              const SizedBox(height: 8),

              // Active Locked Target Info Card
              if (activeTower != null)
                _buildActiveTowerCard(
                    context, activeTower, distanceStr, targetBearing, cardinal),

              // Compass Hardware Simulation / Adjuster (helps on emulator/Mac)
              if (!_compassService.hasHardwareCompass) _buildHeadingSlider(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationStatusBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          Icon(
            _locationService.isSimulated ? Icons.tune : Icons.gps_fixed,
            color: _locationService.isSimulated
                ? const Color(0xFFF59E0B)
                : const Color(0xFF10B981),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'OBSERVER POSITION',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _locationService.activeLocationName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.0,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _showLocationPresetPicker(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: const Color(0xFF0B0F19),
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.5)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'CHANGE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF38BDF8),
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.unfold_more, color: Color(0xFF38BDF8), size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTowerCard(
    BuildContext context,
    CellTower tower,
    String distanceStr,
    double bearing,
    String cardinal,
  ) {
    final color = _carrierColor(tower.carrier);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF334155), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withValues(alpha: 0.6)),
                ),
                child: Text(
                  tower.carrier.displayName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Text(
                'FCC ASR ${tower.asrNumber}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tower.siteName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${tower.structureType} • ${tower.heightAglMeters}m AGL (${(tower.heightAglMeters * 3.28).toStringAsFixed(0)}ft)',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6.0,
            children: [
              for (final b in tower.bands)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B0F19),
                    borderRadius: BorderRadius.circular(4.0),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Text(
                    b,
                    style: const TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF38BDF8),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeadingSlider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'COMPASS HEADING SIMULATOR',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: Color(0xFF94A3B8),
                ),
              ),
              Text(
                '${_compassService.heading.toStringAsFixed(0)}°',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF38BDF8),
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF38BDF8),
              thumbColor: const Color(0xFF38BDF8),
              inactiveTrackColor: const Color(0xFF334155),
              trackHeight: 3.0,
            ),
            child: Slider(
              value: _compassService.heading,
              min: 0,
              max: 360,
              onChanged: (val) {
                _compassService.setManualHeading(val);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLocationPresetPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SELECT OBSERVER LOCATION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Color(0xFF94A3B8), size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFF334155)),
              ListTile(
                leading:
                    const Icon(Icons.my_location, color: Color(0xFF10B981)),
                title: const Text('Live GPS Device Position',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                subtitle: const Text('Use phone internal GPS sensors',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                onTap: () async {
                  final messenger = ScaffoldMessenger.maybeOf(context);
                  Navigator.pop(ctx);
                  final ok = await _locationService.enableLiveGps();
                  if (!ok && mounted && messenger != null) {
                    messenger.showSnackBar(
                      const SnackBar(
                          content:
                              Text('GPS permission needed or not available.')),
                    );
                  }
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
                child: Text(
                  'BACKCOUNTRY & RURAL SIMULATION PRESETS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: LocationService.presets.length,
                  itemBuilder: (context, i) {
                    final p = LocationService.presets[i];
                    final isSel = _locationService.activeLocationName == p.name;
                    return ListTile(
                      leading: Icon(
                        Icons.terrain,
                        color: isSel
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF64748B),
                      ),
                      title: Text(
                        p.name,
                        style: TextStyle(
                          color: isSel ? const Color(0xFF38BDF8) : Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        '${p.region} • ${p.elevationMeters.toStringAsFixed(0)}m AMSL',
                        style: const TextStyle(
                            color: Color(0xFF94A3B8), fontSize: 11),
                      ),
                      trailing: isSel
                          ? const Icon(Icons.check,
                              color: Color(0xFF38BDF8), size: 18)
                          : null,
                      onTap: () {
                        _locationService.applyPreset(p);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
