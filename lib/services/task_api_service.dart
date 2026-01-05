import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/supabase_config.dart';
import '../models/task.dart';

class TaskApiService {
  final http.Client _client;

  TaskApiService({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> get _headers => {
    'apikey': SupabaseConfig.anonKey,
    'Authorization': 'Bearer ${SupabaseConfig.anonKey}',
    'Content-Type': 'application/json',
  };

  Future<List<Task>> getTasks({String? status}) async {
    final uri = Uri.parse('${SupabaseConfig.baseUrl}/rest/v1/tasks').replace(
      queryParameters: {
        'select': '*',
        if (status != null) 'status': 'eq.$status',
      },
    );

    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data tugas (${response.statusCode})');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Task> addTask(TaskInput input) async {
    final uri = Uri.parse('${SupabaseConfig.baseUrl}/rest/v1/tasks');

    final response = await _client.post(
      uri,
      headers: {..._headers, 'Prefer': 'return=representation'},
      body: jsonEncode(input.toJson()),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Gagal menambah tugas (${response.statusCode})');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return Task.fromJson(data.first as Map<String, dynamic>);
  }

  Future<Task> updateTask(int id, Map<String, dynamic> patch) async {
    final uri = Uri.parse(
      '${SupabaseConfig.baseUrl}/rest/v1/tasks',
    ).replace(queryParameters: {'id': 'eq.$id'});

    final response = await _client.patch(
      uri,
      headers: {..._headers, 'Prefer': 'return=representation'},
      body: jsonEncode(patch),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mengubah tugas (${response.statusCode})');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return Task.fromJson(data.first as Map<String, dynamic>);
  }
}

class TaskInput {
  final String title;
  final String course;
  final DateTime deadline;
  final String status; // BERJALAN / SELESAI / TERLAMBAT
  final String note;
  final bool isDone;

  TaskInput({
    required this.title,
    required this.course,
    required this.deadline,
    required this.status,
    required this.note,
    required this.isDone,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'course': course,
    'deadline': deadline.toIso8601String().split('T').first,
    'status': status,
    'note': note,
    'is_done': isDone,
  };
}
