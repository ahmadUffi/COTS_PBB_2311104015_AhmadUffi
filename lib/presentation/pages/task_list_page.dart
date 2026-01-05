import 'package:flutter/material.dart';

import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';
import '../../design_system/typography.dart';
import '../../models/task.dart';
import '../../services/task_api_service.dart';
import '../widget/task_card.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  String _filter = 'Semua';
  String _searchQuery = '';
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: AppColors.text,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Daftar Tugas', style: AppTextStyles.title),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add),
            color: AppColors.primary,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.cardPadding,
            ),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.grid * 2),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari tugas atau mata kuliah...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radius),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.grid * 2),
                Row(
                  children: [
                    _FilterChip(
                      label: 'Semua',
                      selected: _filter == 'Semua',
                      onTap: () => _changeFilter('Semua'),
                    ),
                    const SizedBox(width: AppSpacing.grid),
                    _FilterChip(
                      label: 'Berjalan',
                      selected: _filter == 'Berjalan',
                      onTap: () => _changeFilter('Berjalan'),
                    ),
                    const SizedBox(width: AppSpacing.grid),
                    _FilterChip(
                      label: 'Selesai',
                      selected: _filter == 'Selesai',
                      onTap: () => _changeFilter('Selesai'),
                    ),
                    const SizedBox(width: AppSpacing.grid),
                    _FilterChip(
                      label: 'Terlambat',
                      selected: _filter == 'Terlambat',
                      onTap: () => _changeFilter('Terlambat'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.grid * 2),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.cardPadding,
              ),
              child: FutureBuilder<List<Task>>(
                future: _futureTasks,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Terjadi kesalahan',
                        style: AppTextStyles.body,
                      ),
                    );
                  }

                  var tasks = snapshot.data ?? [];
                  // Terapkan filter status dari API (BERJALAN/SELESAI/TERLAMBAT)
                  if (_filter == 'Berjalan') {
                    tasks = tasks.where((t) => t.status == 'BERJALAN').toList();
                  } else if (_filter == 'Selesai') {
                    tasks = tasks.where((t) => t.status == 'SELESAI').toList();
                  } else if (_filter == 'Terlambat') {
                    tasks = tasks
                        .where((t) => t.status == 'TERLAMBAT')
                        .toList();
                  }

                  // Terapkan filter pencarian berdasarkan judul / mata kuliah
                  if (_searchQuery.isNotEmpty) {
                    tasks = tasks.where((t) {
                      final title = t.title.toLowerCase();
                      final course = t.course.toLowerCase();
                      final note = t.note.toLowerCase();
                      return title.contains(_searchQuery) ||
                          course.contains(_searchQuery) ||
                          note.contains(_searchQuery);
                    }).toList();
                  }

                  return ListView.separated(
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.grid * 1.5),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskCard(
                        task: task,
                        onTap: () async {
                          final result = await Navigator.pushNamed(
                            context,
                            '/task-detail',
                            arguments: task,
                          );
                          if (result == true && mounted) {
                            setState(() {
                              _futureTasks = _service.getTasks();
                            });
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/add-task');
          if (result == true && mounted) {
            setState(() {
              _futureTasks = _service.getTasks();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _changeFilter(String value) {
    setState(() {
      _filter = value;
    });
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.grid * 2,
          vertical: AppSpacing.grid / 1.5,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radius * 2),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: selected ? Colors.white : AppColors.muted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// dummy list dihapus karena sekarang data berasal dari Supabase
