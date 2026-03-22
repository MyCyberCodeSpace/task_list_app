import 'dart:io';

import 'package:task_list_app/features/todo/domain/model/todo_model.dart';

typedef CreateTask = Future<void> Function({
  required String title,
  required String description,
  required String status,
  required DateTime dueDate,
  required String categoryId,
  File? mediaFile,
});

typedef UpdateTask = Future<void> Function({
  required String id,
  required String title,
  required String description,
  required String status,
  required DateTime dueDate,
  required String categoryId,
  required String mediaUrl,
  File? mediaFile,
});

typedef DeleteTask = Future<void> Function({required TodoModel task});

typedef LoadUserTasks = Future<List<TodoModel>> Function();

typedef LoadUserFilteredTasks = Future<List<TodoModel>> Function(
  String searchTerm,
);

typedef GetCategoryNameById = Future<String> Function(String categoryId);
