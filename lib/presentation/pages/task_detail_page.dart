import 'package:flutter/material.dart';

import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';
import '../../design_system/typography.dart';
import '../../models/task.dart';
import '../widget/task_status_chip.dart';
import '../../services/task_api_service.dart';

class TaskDetailPage extends StatefulWidget {
  const TaskDetailPage({super.key});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  bool _isDone = false;
  final _service = TaskApiService();
  late TextEditingController _noteController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final task = ModalRoute.of(context)?.settings.arguments as Task?;
    if (task != null) {
      _isDone = task.isDone;
      _noteController.text = task.note;
    }
  }

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = ModalRoute.of(context)?.settings.arguments as Task?;

    if (task == null) {
      return const Scaffold(body: Center(child: Text('Task tidak ditemukan')));
    }

    final statusChip = switch (task.status) {
      'SELESAI' => TaskStatusChip.selesai(),
      'TERLAMBAT' => TaskStatusChip.terlambat(),
      _ => TaskStatusChip.berjalan(),
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.text,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Detail Tugas', style: AppTextStyles.title),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {
              // nanti bisa diarahkan ke edit
            },
            child: Text(
              'Edit',
              style: AppTextStyles.body.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: AppTextStyles.section),
                  const SizedBox(height: AppSpacing.grid),
                  Text(task.course, style: AppTextStyles.caption),
                  const SizedBox(height: AppSpacing.grid),
                  Text(
                    'Deadline',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.grid / 2),
                  Text(_formatDate(task.deadline), style: AppTextStyles.body),
                  const SizedBox(height: AppSpacing.grid * 1.5),
                  Row(
                    children: [
                      Text(
                        'Status',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.grid * 2),
                      statusChip,
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.grid * 3),
            Text('Penyelesaian', style: AppTextStyles.section),
            const SizedBox(height: AppSpacing.grid * 1.5),
            Row(
              children: [
                Checkbox(
                  value: _isDone,
                  onChanged: (value) async {
                    final newValue = value ?? false;
                    setState(() {
                      _isDone = newValue;
                    });
                    // update ke backend: toggle selesai / belum
                    final patch = newValue
                        ? {'is_done': true, 'status': 'SELESAI'}
                        : {'is_done': false, 'status': 'BERJALAN'};
                    await _service.updateTask(task.id, patch);
                  },
                ),
                const SizedBox(width: AppSpacing.grid),
                Expanded(
                  child: Text(
                    'Tugas sudah selesai\nCentang jika tugas sudah final.',
                    style: AppTextStyles.body,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.grid * 3),
            Text('Catatan', style: AppTextStyles.section),
            const SizedBox(height: AppSpacing.grid * 1.5),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radius),
              ),
              child: TextField(
                controller: _noteController,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Tidak ada catatan.',
                ),
                style: AppTextStyles.body,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(AppSpacing.cardPadding),
        child: SizedBox(
          height: AppSpacing.buttonHeight,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radius),
              ),
            ),
            onPressed: () async {
              final route = ModalRoute.of(context);
              if (route == null) return;
              final task = route.settings.arguments as Task;
              await _service.updateTask(task.id, {
                'note': _noteController.text.trim(),
              });
              if (!mounted) return;
              Navigator.pop(context, true);
            },
            child: Text('Simpan Perubahan', style: AppTextStyles.button),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
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
