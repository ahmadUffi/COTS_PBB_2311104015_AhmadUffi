class Task {
  final int id;
  final String title;
  final String course;
  final DateTime deadline;
  final String status; // BERJALAN, SELESAI, TERLAMBAT
  final String note;
  final bool isDone;

  Task({
    required this.id,
    required this.title,
    required this.course,
    required this.deadline,
    required this.status,
    required this.note,
    required this.isDone,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      title: json['title'] as String,
      course: json['course'] as String,
      deadline: DateTime.parse(json['deadline'] as String),
      status: (json['status'] as String).toUpperCase(),
      note: (json['note'] ?? '') as String,
      isDone: json['is_done'] as bool? ?? false,
    );
  }

  Task copyWith({
    String? title,
    String? course,
    DateTime? deadline,
    String? status,
    String? note,
    bool? isDone,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      course: course ?? this.course,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      note: note ?? this.note,
      isDone: isDone ?? this.isDone,
    );
  }
}
