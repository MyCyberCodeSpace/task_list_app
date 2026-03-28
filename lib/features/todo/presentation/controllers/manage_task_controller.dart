import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_list_app/features/todo/domain/enum/task_status_enum.dart';
import 'package:task_list_app/features/todo/domain/model/todo_model.dart';
import 'package:task_list_app/features/todo/presentation/bloc/task_bloc.dart';
import 'package:task_list_app/features/todo/presentation/bloc/task_event.dart';

class ManageTaskController extends ChangeNotifier {
  final TaskBloc taskBloc;
  final TodoModel task;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final DateFormat formatter = DateFormat.yMd();

  late String inputTitle;
  late String inputDescription;
  late TaskStatus selectStatus;
  late String selectCategory;
  DateTime? selectedDate;
  File? selectedMedia;
  late String mediaUrl;

  ManageTaskController({required this.taskBloc, required this.task}) {
    _initializeValues();
  }

  void _initializeValues() {
    inputTitle = task.title;
    inputDescription = task.description;
    selectStatus = TaskStatus.fromLabel(task.status);
    selectCategory = task.categoryId;
    selectedDate = task.dueDate;
    mediaUrl = task.mediaUrl;
  }

  void setTitle(String value) {
    inputTitle = value;
  }

  void setDescription(String value) {
    inputDescription = value;
  }

  void setStatus(TaskStatus status) {
    selectStatus = status;
    notifyListeners();
  }

  void setCategory(String categoryId) {
    selectCategory = categoryId;
    notifyListeners();
  }

  void setDate(DateTime? date) {
    selectedDate = date;
    notifyListeners();
  }

  void setMedia(File? media) {
    selectedMedia = media;
  }

  Future<DateTime?> presentDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 2, now.month, now.day);
    final lastDate = DateTime(now.year + 2, now.month, now.day);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      setDate(pickedDate);
    }

    return pickedDate;
  }

  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  void saveForm() {
    formKey.currentState?.save();
  }

  bool hasSelectedDate() {
    return selectedDate != null;
  }

  void updateTask() {
    if (!validateForm()) return;

    saveForm();

    taskBloc.add(
      TaskUpdateTaskEvent(
        id: task.id,
        title: inputTitle,
        description: inputDescription,
        dueDate: selectedDate!,
        status: selectStatus.label,
        categoryId: selectCategory,
        mediaUrl: task.mediaUrl,
        mediaFile: selectedMedia,
      ),
    );
  }

  void deleteTask() {
    taskBloc.add(TaskDeleteTasksEvent(task));
  }

  String? validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter at least one letter.';
    }
    return null;
  }

  String? validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter at least one letter.';
    }
    return null;
  }
}
