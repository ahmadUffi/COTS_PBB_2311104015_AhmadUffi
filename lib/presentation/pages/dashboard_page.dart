import 'package:flutter/material.dart';

import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';
import '../../design_system/typography.dart';
import '../../models/task.dart';
import '../../services/task_api_service.dart';
import '../widget/task_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _service = TaskApiService();
  late Future<List<Task>> _futureTasks;

  @override
  void initState() {
    super.initState();
    _futureTasks = _service.getTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: Text('Tugas Besar', style: AppTextStyles.title),
        actions: [
          TextButton(
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/tasks');
              if (result == true && mounted) {
                setState(() {
                  _futureTasks = _service.getTasks();
                });
              }
            },
            child: Text(
              'Daftar Tugas',
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
        child: FutureBuilder<List<Task>>(
          future: _futureTasks,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Something went wrong', style: AppTextStyles.body),
              );
            }

            final tasks = snapshot.data ?? [];
            final totalTasks = tasks.length;
            final completedTasks = tasks
                .where((t) => t.status == 'SELESAI')
                .length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _DashboardStatCard(
                      label: 'Total Tugas',
                      value: totalTasks.toString(),
                    ),
                    const SizedBox(width: AppSpacing.grid * 2),
                    _DashboardStatCard(
                      label: 'Selesai',
                      value: completedTasks.toString(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.grid * 3),
                Text('Tugas Terdekat', style: AppTextStyles.section),
                const SizedBox(height: AppSpacing.grid * 2),
                Expanded(
                  child: ListView.separated(
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.grid * 1.5),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskCard(
                        task: task,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/task-detail',
                            arguments: task,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
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
              final result = await Navigator.pushNamed(context, '/add-task');
              if (result == true && mounted) {
                setState(() {
                  _futureTasks = _service.getTasks();
                });
              }
            },
            child: Text('Tambah Tugas', style: AppTextStyles.button),
          ),
        ),
      ),
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  final String label;
  final String value;

  const _DashboardStatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTextStyles.title),
            const SizedBox(height: AppSpacing.grid / 2),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
