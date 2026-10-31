import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TacticalAppLegalConfig {
  final String appName;
  final String tagline;
  final String version;
  final String cautionTitle;
  final String cautionBody;
  final String dataSource;
  final List<String> bulletPoints;
  final Color accentColor;

  const TacticalAppLegalConfig({
    required this.appName,
    required this.tagline,
    this.version = '1.0.0+1',
    required this.cautionTitle,
    required this.cautionBody,
    required this.dataSource,
    required this.bulletPoints,
    this.accentColor = const Color(0xFF38BDF8), // Cyan
  });
}

const signalScoutLegal = TacticalAppLegalConfig(
  appName: 'SignalScout',
  tagline: 'Cell Tower & Dead-Zone Scout with Booster Aiming Needle',
  accentColor: Color(0xFF38BDF8), // Cyan
  cautionTitle: 'ESTIMATED PROPAGATION MODELING',
  cautionBody:
      'Tower coordinates, azimuth pointing angles, and carrier allocations are modeled from public FCC records and OpenCellID databases. Propagation metrics are mathematical line-of-sight estimates that do not account for terrain shadowing, dense foliage, building attenuation, or live network outages. NEVER rely on this application for guaranteed emergency 911 access.',
  dataSource: 'Sources: FCC Public Databases & OpenCellID (ODbL License).',
  bulletPoints: [
    'Antenna pointing vectors represent direct geometric line-of-sight approximations.',
    'Dead-zone breadcrumbs are logged locally on-device based on GNSS and cellular modem reports.',
    'SignalScout is an independent utility and is not affiliated with, endorsed by, or sponsored by the FCC or any cellular carrier.',
    'The developer assumes no liability for missed calls, connectivity failures, or emergency communication delays.',
  ],
);

class TacticalLegalSheet extends StatelessWidget {
  final TacticalAppLegalConfig config;
  final bool isFirstRunGate;
  final VoidCallback? onAcknowledge;

  const TacticalLegalSheet({
    super.key,
    required this.config,
    this.isFirstRunGate = false,
    this.onAcknowledge,
  });

  /// Call this on app launch to show only once
  static Future<void> checkFirstRun(
    BuildContext context,
    TacticalAppLegalConfig config,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final hasAgreed = prefs.getBool('legal_acknowledged_${config.appName}') ?? false;
    if (!hasAgreed && context.mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (ctx) => TacticalLegalSheet(
          config: config,
          isFirstRunGate: true,
          onAcknowledge: () async {
            await prefs.setBool('legal_acknowledged_${config.appName}', true);
            if (ctx.mounted) Navigator.of(ctx).pop();
          },
        ),
      );
    }
  }

  /// Call this from any Info icon or 3-dots menu
  static void show(BuildContext context, TacticalAppLegalConfig config) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TacticalLegalSheet(config: config),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = config.accentColor;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Color(0xFF0B0F19),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Color(0xFF334155), width: 1.5),
          left: BorderSide(color: Color(0xFF334155), width: 1.5),
          right: BorderSide(color: Color(0xFF334155), width: 1.5),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: accent.withOpacity(0.5)),
                  ),
                  child: Icon(Icons.shield_outlined, color: accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.appName.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 2.0,
                        ),
                      ),
                      Text(
                        'v${config.version} // LEGAL & ADVISORY',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isFirstRunGate)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8)),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
              ],
            ),
          ),

          const Divider(color: Color(0xFF1E293B), height: 1),

          // Scrollable Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 1. High-Risk Caution Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF59E0B), width: 1.5), // Amber
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 20),
                          SizedBox(width: 8),
                          Text(
                            'SAFETY ADVISORY',
                            style: TextStyle(
                              color: Color(0xFFF59E0B),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 1.5,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        config.cautionTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        config.cautionBody,
                        style: const TextStyle(
                          color: Color(0xFFCBD5E1),
                          fontSize: 12,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Terms & Liability Bullets
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151E2E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TERMS OF USE // LIMITATION OF LIABILITY',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1.2,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...config.bulletPoints.map(
                        (bp) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 4, right: 8),
                                child: Icon(Icons.circle, color: accent, size: 6),
                              ),
                              Expanded(
                                child: Text(
                                  bp,
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Data Attribution
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cell_tower, color: Color(0xFF64748B), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          config.dataSource,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // First-run confirmation button
          if (isFirstRunGate)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                border: Border(top: BorderSide(color: Color(0xFF1E293B))),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onAcknowledge,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: const Color(0xFF0B0F19),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'I UNDERSTAND & ACKNOWLEDGE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
