import 'package:flutter/material.dart';

import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';
import '../../design_system/typography.dart';

class TaskStatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const TaskStatusChip({super.key, required this.label, required this.color});

  factory TaskStatusChip.berjalan() {
    return const TaskStatusChip(label: 'Berjalan', color: AppColors.primary);
  }

  factory TaskStatusChip.selesai() {
    return const TaskStatusChip(label: 'Selesai', color: Color(0xFF22C55E));
  }

  factory TaskStatusChip.terlambat() {
    return const TaskStatusChip(label: 'Terlambat', color: Color(0xFFEF4444));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.grid * 2,
        vertical: AppSpacing.grid / 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radius * 2),
      ),
      child: Text(label, style: AppTextStyles.caption.copyWith(color: color)),
    );
  }
}
