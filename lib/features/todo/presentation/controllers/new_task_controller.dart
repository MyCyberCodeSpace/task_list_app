import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_list_app/features/todo/domain/enum/task_status_enum.dart';
import 'package:task_list_app/features/todo/presentation/bloc/task_bloc.dart';
import 'package:task_list_app/features/todo/presentation/bloc/task_event.dart';

class NewTaskController extends ChangeNotifier {
  final TaskBloc taskBloc;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final DateFormat formatter = DateFormat.yMd();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String inputTitle = '';
  String inputDescription = '';
  String selectStatus = TaskStatus.toDo.label;
  String? selectCategory;
  DateTime? selectedDate;
  File? selectedMedia;

  NewTaskController({required this.taskBloc});

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void setTitle(String value) {
    inputTitle = value;
  }

  void setDescription(String value) {
    inputDescription = value;
  }

  void setStatus(String status) {
    selectStatus = status;
    notifyListeners();
  }

  void setCategory(String? categoryId) {
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

  bool hasSelectedCategory() {
    return selectCategory != null;
  }

  void createTask() {
    if (!validateForm()) return;

    saveForm();

    taskBloc.add(
      TaskCreateNewTaskEvent(
        inputTitle,
        inputDescription,
        selectedDate!,
        selectStatus,
        selectCategory!,
        selectedMedia,
      ),
    );
  }

  void loadAllTasks() {
    taskBloc.add(TaskLoadAllTasksEvent());
  }

  void resetForm() {
    titleController.clear();
    descriptionController.clear();
    selectedDate = null;
    selectStatus = TaskStatus.toDo.label;
    selectCategory = null;
    selectedMedia = null;
    notifyListeners();
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
