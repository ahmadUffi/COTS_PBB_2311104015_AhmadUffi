import 'package:flutter/material.dart';

import '../../design_system/colors.dart';
import '../../design_system/spacing.dart';
import '../../design_system/typography.dart';
import '../../services/task_api_service.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String? _selectedCourse;
  DateTime? _deadline;
  bool _isDone = false;
  final _notesController = TextEditingController();
  final _service = TaskApiService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
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
        title: Text('Tambah Tugas', style: AppTextStyles.title),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(),
              const SizedBox(height: AppSpacing.grid * 2),
              _buildCourseDropdown(),
              const SizedBox(height: AppSpacing.grid * 2),
              _buildDeadlinePicker(context),
              const SizedBox(height: AppSpacing.grid * 2),
              Row(
                children: [
                  Checkbox(
                    value: _isDone,
                    onChanged: (value) {
                      setState(() {
                        _isDone = value ?? false;
                      });
                    },
                  ),
                  const SizedBox(width: AppSpacing.grid),
                  Text('Tugas sudah selesai', style: AppTextStyles.body),
                ],
              ),
              const SizedBox(height: AppSpacing.grid * 2),
              _buildNotesField(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: AppSpacing.buttonHeight,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radius),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Batal',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.grid * 2),
            Expanded(
              child: SizedBox(
                height: AppSpacing.buttonHeight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radius),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _onSubmit,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        )
                      : Text('Simpan', style: AppTextStyles.button),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Judul Tugas', style: AppTextStyles.body),
        const SizedBox(height: AppSpacing.grid / 2),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            hintText: 'Masukkan judul tugas',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radius),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Judul tugas wajib diisi';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCourseDropdown() {
    const courses = [
      'Pemrograman Lanjut',
      'Rekayasa Perangkat Lunak',
      'Metodologi Penelitian',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mata Kuliah', style: AppTextStyles.body),
        const SizedBox(height: AppSpacing.grid / 2),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radius),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.grid),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCourse,
              hint: const Text('Pilih mata kuliah'),
              items: courses
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCourse = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeadlinePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Deadline', style: AppTextStyles.body),
        const SizedBox(height: AppSpacing.grid / 2),
        GestureDetector(
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: now,
              firstDate: DateTime(now.year - 1),
              lastDate: DateTime(now.year + 2),
            );
            if (picked != null) {
              setState(() {
                _deadline = picked;
              });
            }
          },
          child: Container(
            height: AppSpacing.inputHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.grid),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radius),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _deadline == null
                      ? 'Pilih tanggal'
                      : '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}',
                  style: AppTextStyles.body.copyWith(
                    color: _deadline == null ? AppColors.muted : AppColors.text,
                  ),
                ),
                const Icon(Icons.calendar_today, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Catatan', style: AppTextStyles.body),
        const SizedBox(height: AppSpacing.grid / 2),
        TextFormField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Catatan tambahan (opsional)',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radius),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }

  void _onSubmit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || _deadline == null || _selectedCourse == null) {
      // sederhana: wajib pilih deadline & mata kuliah juga
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua field wajib')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final input = TaskInput(
      title: _titleController.text.trim(),
      course: _selectedCourse!,
      deadline: _deadline!,
      status: _isDone ? 'SELESAI' : 'BERJALAN',
      note: _notesController.text.trim(),
      isDone: _isDone,
    );

    _service
        .addTask(input)
        .then((_) {
          if (mounted) Navigator.pop(context, true);
        })
        .catchError((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal menyimpan tugas')),
          );
        })
        .whenComplete(() {
          if (mounted) {
            setState(() {
              _isSubmitting = false;
            });
          }
        });
  }
}
