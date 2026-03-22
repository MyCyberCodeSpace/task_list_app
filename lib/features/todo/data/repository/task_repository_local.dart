import 'dart:io';

import 'package:task_list_app/features/todo/domain/model/todo_model.dart';
import 'package:task_list_app/features/todo/domain/repository/task_repository.dart';

class TaskRepositoryLocal extends TaskRepository {
  final List<TodoModel> _tasks = [];
  final Map<String, String> _categoryNames;
  int _nextId = 1;

  TaskRepositoryLocal(this._categoryNames) {
    _seedData();
  }

  void _seedData() {
    final categories = _categoryNames.entries.toList();
    final cat1 = categories.isNotEmpty ? categories[0] : null;
    final cat2 = categories.length > 1 ? categories[1] : null;

    _tasks.addAll([
      TodoModel(
        id: '${_nextId++}',
        title: 'Study Flutter Clean Architecture',
        description: 'Review domain, data, and presentation layers.',
        dueDate: DateTime.now().add(const Duration(days: 2)),
        status: 'To Do',
        categoryId: cat1?.key ?? '1',
        categoryName: cat1?.value ?? 'Study',
        mediaUrl: '',
      ),
      TodoModel(
        id: '${_nextId++}',
        title: 'Buy groceries',
        description: 'Milk, bread, eggs, fruits, and vegetables.',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        status: 'In Progress',
        categoryId: cat2?.key ?? '2',
        categoryName: cat2?.value ?? 'Personal',
        mediaUrl: '',
      ),
      TodoModel(
        id: '${_nextId++}',
        title: 'Fix login screen layout',
        description: 'The Expanded widget is incorrectly placed inside a Form.',
        dueDate: DateTime.now(),
        status: 'Done',
        categoryId: cat1?.key ?? '1',
        categoryName: cat1?.value ?? 'Study',
        mediaUrl: '',
      ),
      TodoModel(
        id: '${_nextId++}',
        title: 'Write unit tests',
        description: 'Add tests for repository and bloc layers.',
        dueDate: DateTime.now().add(const Duration(days: 5)),
        status: 'To Do',
        categoryId: cat1?.key ?? '1',
        categoryName: cat1?.value ?? 'Study',
        mediaUrl: '',
      ),
      TodoModel(
        id: '${_nextId++}',
        title: 'Plan weekend trip',
        description: 'Search for hotels and activities nearby.',
        dueDate: DateTime.now().add(const Duration(days: 10)),
        status: 'To Do',
        categoryId: cat2?.key ?? '2',
        categoryName: cat2?.value ?? 'Personal',
        mediaUrl: '',
      ),
    ]);
  }

  @override
  Future<void> createTask({
    required String title,
    required String description,
    required String status,
    required DateTime dueDate,
    required String categoryId,
    File? mediaFile,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final categoryName = await getCategoryNameById(categoryId);

    _tasks.add(
      TodoModel(
        id: '${_nextId++}',
        title: title,
        description: description,
        dueDate: dueDate,
        status: status,
        categoryId: categoryId,
        categoryName: categoryName,
        mediaUrl: mediaFile?.path ?? '',
      ),
    );
  }

  @override
  Future<void> updateTask({
    required String id,
    required String title,
    required String description,
    required String status,
    required DateTime dueDate,
    required String categoryId,
    required String mediaUrl,
    File? mediaFile,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _tasks.indexWhere((t) => t.id == id);
    if (index == -1) throw Exception('Task not found');

    final categoryName = await getCategoryNameById(categoryId);

    _tasks[index] = TodoModel(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      status: status,
      categoryId: categoryId,
      categoryName: categoryName,
      mediaUrl: mediaFile?.path ?? mediaUrl,
    );
  }

  @override
  Future<void> deleteTask({required TodoModel task}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _tasks.removeWhere((t) => t.id == task.id);
  }

  @override
  Future<List<TodoModel>> loadUserTasks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_tasks);
  }

  @override
  Future<List<TodoModel>> loadUserFilteredTasks(String searchTerm) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final term = searchTerm.toLowerCase();
    return _tasks.where((t) {
      return t.title.toLowerCase().contains(term) ||
          t.description.toLowerCase().contains(term) ||
          t.status.toLowerCase().contains(term) ||
          t.categoryName.toLowerCase().contains(term);
    }).toList();
  }

  @override
  Future<String> getCategoryNameById(String categoryId) async {
    return _categoryNames[categoryId] ?? 'Unknown';
  }
}
