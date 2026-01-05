import 'package:flutter/material.dart';

import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';
import '../../design_system/typography.dart';
import '../../models/task.dart';
import 'task_status_chip.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;

  const TaskCard({super.key, required this.task, this.onTap});

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = task.status.toUpperCase();
    final statusChip = switch (normalizedStatus) {
      'SELESAI' => TaskStatusChip.selesai(),
      'TERLAMBAT' => TaskStatusChip.terlambat(),
      _ => TaskStatusChip.berjalan(), // default: BERJALAN / lainnya
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radius),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A0F172A),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.grid / 2),
                      Text(task.course, style: AppTextStyles.caption),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.grid * 2),
                statusChip,
              ],
            ),
            const SizedBox(height: AppSpacing.grid * 1.5),
            Text(
              'Deadline: ${_formatDate(task.deadline)}',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Format sederhana: 18 Jan 2026
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }
}
