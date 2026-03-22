import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_list_app/features/todo/domain/repository/task_repository.dart';
import 'package:task_list_app/features/todo/presentation/bloc/task_event.dart';
import 'package:task_list_app/features/todo/presentation/bloc/task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskStateController> {
  final TaskRepository _repository;

  TaskBloc(this._repository) : super(TaskInitialState()) {
    
    on<TaskCreateNewTaskEvent>((event, emit) async {
      emit(TaskLoadingState());
      try {
        await _repository.createTask(
          title: event.title,
          description: event.description,
          status: event.status,
          dueDate: event.dueDate,
          categoryId: event.categoryId,
          mediaFile: event.mediaUrl,
        );
        emit(TaskSuccessMessageState("Congrets... you created a new task!"));
      } catch (e) {
        emit(TaskErrorState('Erro creating new task: $e'));
      }
    });


    on<TaskUpdateTaskEvent>((event, emit) async {
      emit(TaskLoadingState());
      try {
        await _repository.updateTask(
          id: event.id,
          title: event.title,
          description: event.description,
          status: event.status,
          dueDate: event.dueDate,
          categoryId: event.categoryId,
          mediaFile: event.mediaFile,
          mediaUrl: event.mediaUrl,
        );
        emit(TaskSuccessMessageState("Congrets... you updated a task!"));
      } catch (e) {
        emit(TaskErrorState('Erro creating new task: $e'));
      }
    });


    on<TaskLoadAllTasksEvent>((event, emit) async {
      emit(TaskLoadingState());
      try {
        final tasks = await _repository.loadUserTasks();
        emit(TaskLoadedListState(tasks));
      } catch (e) {
        emit(TaskErrorState('Erro loading database - Tasks: $e'));
      }
    });

    on<TaskDeleteTasksEvent>((event, emit) async {
      emit(TaskLoadingState());
      try {
        await _repository.deleteTask(task: event.task);
        emit(TaskSuccessMessageState("Congrets... you delete this task"));
        add(TaskLoadAllTasksEvent());
      } catch (e) {
        emit(TaskErrorState('Erro in removing item: $e'));
      }
    });

    on<TaskOpenTaskEvent>((event, emit) {
      emit(TaskOpenTaskScreenState(event.item));
    });

    on<TaskLoadFilteredListTasksEvent>((event, emit) async {
      emit(TaskLoadingState());
      try {
        final tasks = await _repository.loadUserFilteredTasks(event.searchTerm);
        emit(TaskLoadedFilteredListState(tasks));
      } catch (e) {
        emit(TaskErrorState('Erro loading database filtered - Tasks: $e'));
      }
    });
  }
}
