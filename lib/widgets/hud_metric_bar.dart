import 'package:flutter/material.dart';

class HudMetricBar extends StatelessWidget {
  final String azimuthText;
  final String azimuthSub;
  final String distanceText;
  final String distanceSub;
  final String signalDbmText;
  final String signalQualityText;
  final Color signalColor;

  const HudMetricBar({
    super.key,
    required this.azimuthText,
    required this.azimuthSub,
    required this.distanceText,
    required this.distanceSub,
    required this.signalDbmText,
    required this.signalQualityText,
    required this.signalColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: const Color(0xFF334155), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricColumn(
              title: 'AZIMUTH',
              value: azimuthText,
              subtitle: azimuthSub,
              valueColor: const Color(0xFF38BDF8),
            ),
          ),
          Container(
            width: 1,
            height: 38,
            color: const Color(0xFF334155),
          ),
          Expanded(
            child: _buildMetricColumn(
              title: 'DISTANCE',
              value: distanceText,
              subtitle: distanceSub,
              valueColor: Colors.white,
            ),
          ),
          Container(
            width: 1,
            height: 38,
            color: const Color(0xFF334155),
          ),
          Expanded(
            child: _buildMetricColumn(
              title: 'EST. SIGNAL',
              value: signalDbmText,
              subtitle: signalQualityText,
              valueColor: signalColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn({
    required String title,
    required String value,
    required String subtitle,
    required Color valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 10.0,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w900,
            color: valueColor,
            fontFamily: 'monospace',
          ),
        ),
        const SizedBox(height: 1),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10.0,
            fontWeight: FontWeight.w600,
            color: valueColor.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}
