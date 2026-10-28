import 'package:flutter/material.dart';
import '../models/cell_tower.dart';

class TowerCard extends StatelessWidget {
  final CellTower tower;
  final double? distanceMeters;
  final double? bearingDegrees;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback? onDelete;

  const TowerCard({
    super.key,
    required this.tower,
    this.distanceMeters,
    this.bearingDegrees,
    required this.isSelected,
    required this.onSelect,
    this.onDelete,
  });

  Color get carrierColor {
    switch (tower.carrier) {
      case CarrierType.verizon:
        return const Color(0xFFEF4444); // Red
      case CarrierType.att:
        return const Color(0xFF38BDF8); // Cyan
      case CarrierType.tmobile:
        return const Color(0xFFEC4899); // Magenta
      case CarrierType.other:
        return const Color(0xFFF59E0B); // Amber
    }
  }

  String get formattedDistance {
    if (distanceMeters == null) return '-- mi';
    if (distanceMeters! < 1000) {
      return '${distanceMeters!.toStringAsFixed(0)} m';
    }
    final miles = distanceMeters! / 1609.344;
    return '${miles.toStringAsFixed(1)} mi';
  }

  String get compassCardinal {
    if (bearingDegrees == null) return '--';
    const cardinals = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW', 'N'];
    final index = ((bearingDegrees! + 22.5) / 45.0).floor() % 8;
    final cardinal = cardinals[index];
    return '${bearingDegrees!.toStringAsFixed(0)}° $cardinal';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF334155),
          width: isSelected ? 1.8 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: onSelect,
          onLongPress: onSelect,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Micro Carrier Badge & Selected Tag & 3-Dots Popup
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Carrier Pill Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 3.0),
                          decoration: BoxDecoration(
                            color: carrierColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6.0),
                            border: Border.all(
                                color: carrierColor.withValues(alpha: 0.6),
                                width: 1.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: carrierColor,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                tower.carrier.displayName.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                  color: carrierColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7.0, vertical: 3.0),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6.0),
                              border: Border.all(
                                  color: const Color(0xFF10B981), width: 1.0),
                            ),
                            child: const Text(
                              'AIM LOCKED',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF10B981),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Clean 3-Dots Popup Menu (no row clutter)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert,
                          color: Color(0xFF94A3B8), size: 20),
                      color: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFF334155)),
                      ),
                      onSelected: (val) {
                        if (val == 'aim') {
                          onSelect();
                        } else if (val == 'fcc') {
                          _showFccDialog(context);
                        } else if (val == 'delete' && onDelete != null) {
                          onDelete!();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'aim',
                          child: Row(
                            children: [
                              Icon(Icons.near_me,
                                  color: Color(0xFF38BDF8), size: 18),
                              SizedBox(width: 10),
                              Text('Aim Needle Here',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'fcc',
                          child: Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Color(0xFF94A3B8), size: 18),
                              SizedBox(width: 10),
                              Text('FCC / ASR Details',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13)),
                            ],
                          ),
                        ),
                        if (tower.isCustom && onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline,
                                    color: Color(0xFFEF4444), size: 18),
                                SizedBox(width: 10),
                                Text('Remove Tower',
                                    style: TextStyle(
                                        color: Color(0xFFEF4444),
                                        fontSize: 13)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Site Name (maxLines: 2, ellipsis to prevent wrapping squish)
                Text(
                  tower.siteName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),

                const SizedBox(height: 8),

                // Distance & Bearing Telemetry Subtitle Row
                Row(
                  children: [
                    const Icon(Icons.navigation_outlined,
                        color: Color(0xFF38BDF8), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      formattedDistance,
                      style: const TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '•   $compassCardinal',
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                        fontFamily: 'monospace',
                      ),
                    ),
                    const Spacer(),
                    Expanded(
                      flex: 0,
                      child: Text(
                        'ASR ${tower.asrNumber}',
                        style: const TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Structure & Frequency Band Badges
                Wrap(
                  spacing: 6.0,
                  runSpacing: 4.0,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7.0, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B0F19),
                        borderRadius: BorderRadius.circular(4.0),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Text(
                        '${tower.heightAglMeters.toStringAsFixed(0)}m AGL • ${tower.structureType}',
                        style: const TextStyle(
                          fontSize: 10.0,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    for (final band in tower.bands.take(2))
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6.0, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0B0F19),
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Text(
                          band,
                          style: const TextStyle(
                            fontSize: 10.0,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF38BDF8),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFccDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF334155)),
        ),
        title: Row(
          children: [
            Icon(Icons.cell_tower, color: carrierColor, size: 22),
            const SizedBox(width: 8),
            const Text(
              'FCC ASR RECORD',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogRow('Site Name:', tower.siteName),
            _buildDialogRow('Carrier:', tower.carrier.displayName),
            _buildDialogRow('ASR / Registration:', tower.asrNumber),
            _buildDialogRow('Licensee:', tower.licensee),
            _buildDialogRow('Tower Height (AGL):',
                '${tower.heightAglMeters} m (${(tower.heightAglMeters * 3.28084).toStringAsFixed(0)} ft)'),
            _buildDialogRow(
                'Ground Elevation:', '${tower.elevationAmslMeters} m AMSL'),
            _buildDialogRow('Structure:', tower.structureType),
            _buildDialogRow('Coordinates:',
                '${tower.latitude.toStringAsFixed(5)}, ${tower.longitude.toStringAsFixed(5)}'),
            const SizedBox(height: 8),
            const Text(
              'Supported Bands:',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 4),
            Text(
              tower.bands.join('\n'),
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF38BDF8),
                  height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CLOSE',
                style: TextStyle(
                    color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
