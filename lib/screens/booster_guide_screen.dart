import 'package:flutter/material.dart';

class BoosterGuideScreen extends StatelessWidget {
  const BoosterGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0, bottom: 94.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'TACTICAL FIELD MANUAL',
                style: TextStyle(
                  fontSize: 10.0,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Booster Aiming & RF Guide',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),

              // Section 1: Directional Yagi / LPDA Aiming
              _buildGuideCard(
                icon: Icons.explore,
                iconColor: const Color(0xFF38BDF8),
                badgeText: 'STEP-BY-STEP',
                title: 'Aiming Directional Booster Antennas',
                content:
                    '1. Select your carrier (Verizon, AT&T, T-Mobile) in SignalScout.\n'
                    '2. Lock onto the nearest tower with line-of-sight.\n'
                    '3. Hold phone flat along the rear boom of your Yagi/LPDA antenna.\n'
                    '4. Rotate antenna until the SignalScout HUD needle flashes green (AIM LOCKED ±5°).\n'
                    '5. CRITICAL: Cellular amplifiers (weBoost, SureCall) require 30 to 45 seconds for Automatic Gain Control (AGC) to stabilize. Never sweep continuously.',
              ),

              const SizedBox(height: 12),

              // Section 2: Frequency Bands & Backcountry Propagation
              _buildGuideCard(
                icon: Icons.waves,
                iconColor: const Color(0xFF10B981),
                badgeText: 'RF PROPAGATION',
                title: 'Low-Band vs Mid-Band in Deep Woods',
                content:
                    '• Low-Band (600–700 MHz): Bands 12, 13, 14 (FirstNet), and 71.\n'
                    '  These long wavelengths bend around ridges and punch through dense pine/hardwood canopies. Essential for camping and rural fringes (up to 20+ miles).\n\n'
                    '• Mid-Band (1.9–2.1 GHz): Bands 2, 4, 66.\n'
                    '  Delivers faster data speeds, but foliage attenuation reduces usable range to under 5–8 miles.\n\n'
                    '• High/C-Band (3.5–3.7 GHz): Band n77.\n'
                    '  Requires strict optical line-of-sight; fails behind mountain ridgelines.',
              ),

              const SizedBox(height: 12),

              // Section 3: Preventing Amplifier Oscillation
              _buildGuideCard(
                icon: Icons.shield,
                iconColor: const Color(0xFFF59E0B),
                badgeText: 'CRITICAL SETUP',
                title: 'Antenna Separation & Oscillation',
                content:
                    'If your indoor booster antenna and outdoor donor antenna are too close, feedback loops (oscillation) occur, causing the booster to shut down its transmitters:\n\n'
                    '• Maintain at least 20 feet of horizontal separation or 15 feet of vertical height delta between the exterior Yagi and interior whip/panel.\n'
                    '• Ensure the back of the directional antenna points away from the camper/vehicle interior.',
              ),

              const SizedBox(height: 12),

              // Section 4: FCC ASR Registrations
              _buildGuideCard(
                icon: Icons.cell_tower,
                iconColor: const Color(0xFFEC4899),
                badgeText: 'FCC COMPLIANCE',
                title: 'FCC Antenna Structure Registration (ASR)',
                content:
                    'The FCC requires all communications towers taller than 200 feet AGL (or within flight safety paths) to register with an Antenna Structure Registration (ASR) number.\n\n'
                    '• SignalScout stores ASR registry numbers directly offline.\n'
                    '• In the field, look for a 7-digit embossed metal placard attached to the compound security gate.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideCard({
    required IconData icon,
    required Color iconColor,
    required String badgeText,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7.0),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B0F19),
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFFCBD5E1),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
