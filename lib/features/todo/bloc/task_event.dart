import 'dart:io';
import 'package:task_list_app/features/todo/model/todo_model.dart';

abstract class TaskEvent {}

class TaskCreateNewTaskEvent extends TaskEvent {
  final String title;
  final String description;
  final String status;
  final DateTime dueDate;
  final String categoryId;
  final File? mediaUrl;

  TaskCreateNewTaskEvent(
    this.title,
    this.description,
    this.dueDate,
    this.status,
    this.categoryId,
    this.mediaUrl,
  );
}

class TaskUpdateTaskEvent extends TaskEvent {
  final String id;
  final String title;
  final String description;
  final String status;
  final DateTime dueDate;
  final String categoryId;
  final String mediaUrl;
  final File? mediaFile;

  TaskUpdateTaskEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.categoryId,
    required this.mediaUrl,
    required this.mediaFile,
  });
}

class TaskLoadAllTasksEvent extends TaskEvent {}

class TaskLoadFilteredListTasksEvent extends TaskEvent {
  String searchTerm;
  TaskLoadFilteredListTasksEvent(this.searchTerm);
}

class TaskOpenTaskEvent extends TaskEvent {
  TodoModel item;
  TaskOpenTaskEvent(this.item);
}

class TaskSuccessMessageEvent extends TaskEvent {
  String message;
  TaskSuccessMessageEvent(this.message);
}

class TaskDeleteTasksEvent extends TaskEvent {
  final TodoModel task;
  TaskDeleteTasksEvent(this.task);
}
