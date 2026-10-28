import 'package:flutter/material.dart';
import '../models/cell_tower.dart';

class CarrierFilterChips extends StatelessWidget {
  final CarrierType? selectedCarrier;
  final ValueChanged<CarrierType?> onCarrierSelected;

  const CarrierFilterChips({
    super.key,
    required this.selectedCarrier,
    required this.onCarrierSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          _buildChip(
            label: 'ALL CARRIERS',
            isSelected: selectedCarrier == null,
            activeColor: const Color(0xFF38BDF8),
            onTap: () => onCarrierSelected(null),
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'VERIZON',
            isSelected: selectedCarrier == CarrierType.verizon,
            activeColor: const Color(0xFFEF4444), // Verizon Red
            onTap: () => onCarrierSelected(CarrierType.verizon),
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'AT&T',
            isSelected: selectedCarrier == CarrierType.att,
            activeColor: const Color(0xFF38BDF8), // AT&T Cyan/Blue
            onTap: () => onCarrierSelected(CarrierType.att),
          ),
          const SizedBox(width: 8),
          _buildChip(
            label: 'T-MOBILE',
            isSelected: selectedCarrier == CarrierType.tmobile,
            activeColor: const Color(0xFFEC4899), // T-Mobile Magenta
            onTap: () => onCarrierSelected(CarrierType.tmobile),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 7.0),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.18) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFF334155),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.25),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? activeColor : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: isSelected ? activeColor : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
