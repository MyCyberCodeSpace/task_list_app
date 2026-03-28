import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_list_app/features/todo/domain/model/todo_model.dart';
import 'package:task_list_app/features/todo/presentation/bloc/task_bloc.dart';
import 'package:task_list_app/features/todo/presentation/bloc/task_event.dart';

class TaskListController {
  late final TaskBloc taskBloc;

  TaskListController();

  void init(BuildContext context) {
    taskBloc = context.read<TaskBloc>();
    taskBloc.add(TaskLoadAllTasksEvent());
  }

  void onPressOpenTask(TodoModel task) {
    taskBloc.add(TaskOpenTaskEvent(task));
  }

  void onPressDeleteItem(TodoModel item) {
    taskBloc.add(TaskDeleteTasksEvent(item));
  }

  void reloadTasks() {
    taskBloc.add(TaskLoadAllTasksEvent());
  }
}
