import 'package:flutter/material.dart';

import 'design_system/colors.dart';
import 'presentation/pages/add_task_page.dart';
import 'presentation/pages/dashboard_page.dart';
import 'presentation/pages/task_detail_page.dart';
import 'presentation/pages/task_list_page.dart';

void main() {
  runApp(const TaskApp());
}

class TaskApp extends StatelessWidget {
  const TaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tugas Besar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const DashboardPage(),
        '/tasks': (_) => const TaskListPage(),
        '/task-detail': (_) => const TaskDetailPage(),
        '/add-task': (_) => const AddTaskPage(),
      },
    );
  }
}
