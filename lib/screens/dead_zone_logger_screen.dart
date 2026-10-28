import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cell_tower.dart';
import '../models/dead_zone.dart';
import '../services/dead_zone_service.dart';
import '../services/location_service.dart';

class DeadZoneLoggerScreen extends StatefulWidget {
  const DeadZoneLoggerScreen({super.key});

  @override
  State<DeadZoneLoggerScreen> createState() => _DeadZoneLoggerScreenState();
}

class _DeadZoneLoggerScreenState extends State<DeadZoneLoggerScreen> {
  final DeadZoneService _deadZoneService = DeadZoneService();
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _deadZoneService.addListener(_onStateChanged);
    _locationService.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _deadZoneService.removeListener(_onStateChanged);
    _locationService.removeListener(_onStateChanged);
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
    final zones = _deadZoneService.deadZones;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DEAD-ZONE BREADCRUMB MAPPER',
                        style: TextStyle(
                          fontSize: 10.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${zones.length} Logged Spots',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (zones.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => _confirmClearAll(context),
                      icon: const Icon(Icons.delete_sweep, color: Color(0xFFEF4444), size: 16),
                      label: const Text(
                        'CLEAR ALL',
                        style: TextStyle(
                          fontSize: 10.0,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFEF4444),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // "Log Dead Spot" Action Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.signal_cellular_off, color: Color(0xFFEF4444), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CURRENT LOCATION GPS',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_locationService.latitude.toStringAsFixed(4)}, ${_locationService.longitude.toStringAsFixed(4)}',
                              style: const TextStyle(
                                fontSize: 13.0,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showLogDeadZoneDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      ),
                      icon: const Icon(Icons.bookmark_add, size: 18),
                      label: const Text(
                        'MARK DEAD SPOT HERE',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Logged Spots List
            Expanded(
              child: zones.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, color: const Color(0xFF10B981).withOpacity(0.5), size: 48),
                          const SizedBox(height: 12),
                          const Text(
                            'No dead zones logged yet',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Tap "Mark Dead Spot Here" when cell service drops to 0 bars.',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 84.0),
                      itemCount: zones.length,
                      itemBuilder: (context, i) {
                        final item = zones[i];
                        final cColor = _carrierColor(item.carrier);
                        final dateStr = DateFormat('MMM d, h:mm a').format(item.timestamp);

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.5),
                                          decoration: BoxDecoration(
                                            color: cColor.withOpacity(0.18),
                                            borderRadius: BorderRadius.circular(6.0),
                                            border: Border.all(color: cColor.withOpacity(0.6)),
                                          ),
                                          child: Text(
                                            item.carrier.displayName.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w900,
                                              color: cColor,
                                              letterSpacing: 0.6,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.5),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEF4444).withOpacity(0.18),
                                            borderRadius: BorderRadius.circular(6.0),
                                          ),
                                          child: Text(
                                            item.signalBars == 0 ? '0 BARS • BLACKOUT' : '1 BAR • SOS ONLY',
                                            style: const TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFFEF4444),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8), size: 18),
                                      color: const Color(0xFF1E293B),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: const BorderSide(color: Color(0xFF334155)),
                                      ),
                                      onSelected: (val) {
                                        if (val == 'delete') {
                                          _deadZoneService.deleteDeadZone(item.id);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 18),
                                              SizedBox(width: 8),
                                              Text('Delete Entry', style: TextStyle(color: Color(0xFFEF4444), fontSize: 13)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                if (item.notes.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    item.notes,
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF94A3B8),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.place_outlined, color: Color(0xFF64748B), size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${item.latitude.toStringAsFixed(4)}, ${item.longitude.toStringAsFixed(4)}',
                                      style: const TextStyle(
                                        fontSize: 11.0,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF64748B),
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      dateStr,
                                      style: const TextStyle(
                                        fontSize: 11.0,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogDeadZoneDialog(BuildContext context) {
    final titleCtrl = TextEditingController(text: 'Dead Spot at ${_locationService.activeLocationName}');
    final notesCtrl = TextEditingController();
    CarrierType chosenCarrier = CarrierType.verizon;
    int bars = 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF334155)),
          ),
          title: const Row(
            children: [
              Icon(Icons.signal_cellular_off, color: Color(0xFFEF4444), size: 22),
              SizedBox(width: 8),
              Text(
                'LOG DEAD ZONE',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: Colors.white),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Location / Landmark Name',
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                    filled: true,
                    fillColor: const Color(0xFF0B0F19),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Observed Signal Level:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildSignalOption(0, '0 Bars (No Service)', bars, () => setDlgState(() => bars = 0)),
                    const SizedBox(width: 8),
                    _buildSignalOption(1, '1 Bar (SOS Only)', bars, () => setDlgState(() => bars = 1)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Tested Carrier Network:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))),
                const SizedBox(height: 6),
                DropdownButtonFormField<CarrierType>(
                  value: chosenCarrier,
                  dropdownColor: const Color(0xFF1E293B),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    fillColor: const Color(0xFF0B0F19),
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: CarrierType.values.map((c) => DropdownMenuItem(value: c, child: Text(c.displayName))).toList(),
                  onChanged: (val) {
                    if (val != null) setDlgState(() => chosenCarrier = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Field Notes (e.g. Ridge shadow, dense woods)',
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                    filled: true,
                    fillColor: const Color(0xFF0B0F19),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL', style: TextStyle(color: Color(0xFF94A3B8))),
            ),
            ElevatedButton(
              onPressed: () async {
                await _deadZoneService.addDeadZone(
                  title: titleCtrl.text,
                  latitude: _locationService.latitude,
                  longitude: _locationService.longitude,
                  carrier: chosenCarrier,
                  signalBars: bars,
                  notes: notesCtrl.text.trim(),
                );
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              child: const Text('SAVE BREADCRUMB', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalOption(int value, String label, int selectedValue, VoidCallback onTap) {
    final isSel = value == selectedValue;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: isSel ? const Color(0xFFEF4444).withOpacity(0.2) : const Color(0xFF0B0F19),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSel ? const Color(0xFFEF4444) : const Color(0xFF334155)),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: isSel ? const Color(0xFFEF4444) : const Color(0xFF94A3B8),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Clear All Dead Zones?', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text('This will delete all saved dead spot breadcrumbs.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL', style: TextStyle(color: Color(0xFF94A3B8)))),
          ElevatedButton(
            onPressed: () {
              _deadZoneService.clearAll();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('CLEAR ALL'),
          ),
        ],
      ),
    );
  }
}
