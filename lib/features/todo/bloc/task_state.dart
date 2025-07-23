import 'package:task_list_app/features/todo/model/todo_model.dart';

abstract class TaskStateController {}

class TaskInitialState extends TaskStateController {}

class TaskLoadingState extends TaskStateController {}

class TaskSuccessMessageState extends TaskStateController{
  final String sucessMessage;
  TaskSuccessMessageState(this.sucessMessage);
}

class TaskErrorState extends TaskStateController {
  final String erroMessage;
  TaskErrorState(this.erroMessage);
}

class TaskLoadedListState extends TaskStateController {
  final List<TodoModel> tasks;
  TaskLoadedListState(this.tasks);
}

class TaskLoadedFilteredListState extends TaskStateController {
  final List<TodoModel> tasks;
  TaskLoadedFilteredListState(this.tasks);
}

class TaskOpenTaskScreenState extends TaskStateController {
  final TodoModel task;
  TaskOpenTaskScreenState(this.task);
}
