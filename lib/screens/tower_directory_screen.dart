import 'package:flutter/material.dart';
import '../models/cell_tower.dart';
import '../services/location_service.dart';
import '../services/tower_database_service.dart';
import '../widgets/carrier_filter_chips.dart';
import '../widgets/tower_card.dart';

class TowerDirectoryScreen extends StatefulWidget {
  final Function(int) onNavigateToTab;

  const TowerDirectoryScreen({super.key, required this.onNavigateToTab});

  @override
  State<TowerDirectoryScreen> createState() => _TowerDirectoryScreenState();
}

class _TowerDirectoryScreenState extends State<TowerDirectoryScreen> {
  final TowerDatabaseService _towerService = TowerDatabaseService();
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _towerService.addListener(_onStateChanged);
    _locationService.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _towerService.removeListener(_onStateChanged);
    _locationService.removeListener(_onStateChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final userLat = _locationService.latitude;
    final userLon = _locationService.longitude;

    final nearbyEntries = _towerService.getNearbyTowers(
      userLat: userLat,
      userLon: userLon,
      carrierFilter: _towerService.activeCarrierFilter,
      maxRadiusMeters: 500000.0, // 500km scope
    );

    // Filter by search query if typed
    final filteredEntries = nearbyEntries.where((entry) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return entry.tower.siteName.toLowerCase().contains(q) ||
          entry.tower.asrNumber.toLowerCase().contains(q) ||
          entry.tower.carrier.displayName.toLowerCase().contains(q) ||
          entry.tower.structureType.toLowerCase().contains(q);
    }).toList();

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
                        'FCC & OPENCELLID DIRECTORY',
                        style: TextStyle(
                          fontSize: 10.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${filteredEntries.length} Towers Found',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddTowerDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: const Color(0xFF38BDF8),
                      elevation: 0,
                      side: const BorderSide(
                          color: Color(0xFF38BDF8), width: 1.2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    icon: const Icon(Icons.add_location_alt, size: 16),
                    label: const Text('CUSTOM',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5)),
                  ),
                ],
              ),
            ),

            // Search Box
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText:
                        'Search by site name, ASR number, or structure...',
                    hintStyle:
                        const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    prefixIcon: const Icon(Icons.search,
                        color: Color(0xFF64748B), size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: Color(0xFF64748B), size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
            ),

            // Carrier Filter Chips
            CarrierFilterChips(
              selectedCarrier: _towerService.activeCarrierFilter,
              onCarrierSelected: (carrier) {
                _towerService.setCarrierFilter(carrier);
              },
            ),

            // Tower Cards List (with bottom scroll clearance padding 84)
            Expanded(
              child: filteredEntries.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cell_tower,
                              color: Color(0xFF64748B), size: 48),
                          SizedBox(height: 12),
                          Text(
                            'No cell towers found',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Try clearing the carrier filter or adjusting search keywords.',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 4.0, bottom: 84.0),
                      itemCount: filteredEntries.length,
                      itemBuilder: (context, i) {
                        final entry = filteredEntries[i];
                        final isSelected =
                            _towerService.lockedTarget?.id == entry.tower.id;

                        return TowerCard(
                          tower: entry.tower,
                          distanceMeters: entry.distanceMeters,
                          bearingDegrees: entry.bearingDegrees,
                          isSelected: isSelected,
                          onSelect: () {
                            _towerService.lockTarget(entry.tower);
                            // Switch back to Scout tab to view needle pointing right at this tower!
                            widget.onNavigateToTab(0);
                          },
                          onDelete: entry.tower.isCustom
                              ? () => _towerService
                                  .deleteCustomTower(entry.tower.id)
                              : null,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTowerDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final asrCtrl = TextEditingController();
    final latCtrl = TextEditingController(
        text: _locationService.latitude.toStringAsFixed(4));
    final lonCtrl = TextEditingController(
        text: _locationService.longitude.toStringAsFixed(4));
    final heightCtrl = TextEditingController(text: '45');
    CarrierType chosenCarrier = CarrierType.verizon;

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
              Icon(Icons.add_location_alt, color: Color(0xFF38BDF8), size: 22),
              SizedBox(width: 8),
              Text(
                'RECORD CUSTOM TOWER',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    color: Colors.white),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildField(nameCtrl, 'Site Name (e.g. Backcountry Repeater)'),
                const SizedBox(height: 10),
                _buildField(asrCtrl, 'FCC ASR or Identifier'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                        child: _buildField(latCtrl, 'Latitude', isNum: true)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: _buildField(lonCtrl, 'Longitude', isNum: true)),
                  ],
                ),
                const SizedBox(height: 10),
                _buildField(heightCtrl, 'Tower Height AGL (meters)',
                    isNum: true),
                const SizedBox(height: 12),
                const Text('Carrier Provider:',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF94A3B8))),
                const SizedBox(height: 6),
                DropdownButtonFormField<CarrierType>(
                  initialValue: chosenCarrier,
                  dropdownColor: const Color(0xFF1E293B),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    fillColor: const Color(0xFF0B0F19),
                    filled: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF334155))),
                  ),
                  items: CarrierType.values
                      .map((c) => DropdownMenuItem(
                          value: c, child: Text(c.displayName)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDlgState(() => chosenCarrier = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL',
                  style: TextStyle(color: Color(0xFF94A3B8))),
            ),
            ElevatedButton(
              onPressed: () async {
                final lat =
                    double.tryParse(latCtrl.text) ?? _locationService.latitude;
                final lon =
                    double.tryParse(lonCtrl.text) ?? _locationService.longitude;
                final height = double.tryParse(heightCtrl.text) ?? 45.0;

                final tower = CellTower(
                  id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                  asrNumber: asrCtrl.text.trim().isEmpty
                      ? 'CUSTOM'
                      : asrCtrl.text.trim(),
                  carrier: chosenCarrier,
                  siteName: nameCtrl.text.trim().isEmpty
                      ? 'Custom Rural Tower'
                      : nameCtrl.text.trim(),
                  latitude: lat,
                  longitude: lon,
                  heightAglMeters: height,
                  elevationAmslMeters: 200.0,
                  bands: ['LTE B13 (700MHz)', 'LTE B66'],
                  structureType: 'Custom Mast',
                  licensee: 'Field User Custom Station',
                  isCustom: true,
                );

                final navigator = Navigator.of(context);
                await _towerService.addCustomTower(tower);
                if (!mounted) return;
                navigator.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: const Color(0xFF0B0F19),
              ),
              child: const Text('SAVE TOWER',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint,
      {bool isNum = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNum
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
        filled: true,
        fillColor: const Color(0xFF0B0F19),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
      ),
    );
  }
}
