import 'dart:io';

import 'package:task_list_app/features/todo/domain/model/todo_model.dart';

export 'package:task_list_app/features/todo/domain/typedef/task_typedef.dart';

abstract class TaskRepository {
  Future<void> createTask({
    required String title,
    required String description,
    required String status,
    required DateTime dueDate,
    required String categoryId,
    File? mediaFile,
  });

  Future<void> updateTask({
    required String id,
    required String title,
    required String description,
    required String status,
    required DateTime dueDate,
    required String categoryId,
    required String mediaUrl,
    File? mediaFile,
  });

  Future<void> deleteTask({required TodoModel task});

  Future<List<TodoModel>> loadUserTasks();

  Future<List<TodoModel>> loadUserFilteredTasks(String searchTerm);

  Future<String> getCategoryNameById(String categoryId);
}
