import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:task_list_app/core/ui_helpers/main_alert_dialog.dart';
import 'package:task_list_app/core/ui_helpers/main_snackbar_helper.dart';
import 'package:task_list_app/features/todo/presentation/bloc/task_bloc.dart';
import 'package:task_list_app/features/todo/presentation/bloc/task_state.dart';
import 'package:task_list_app/features/todo/presentation/controller/task_list_controller.dart';
import 'package:task_list_app/features/todo/presentation/screens/manage_task_screen.dart';
import 'package:task_list_app/core/widgets/main_circular_progress.dart';
import 'package:task_list_app/features/todo/presentation/widgets/task_list_widget.dart';

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  final controller = TaskListController();

  @override
  void initState() {
    super.initState();
    controller.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskBloc, TaskStateController>(
      listener: (context, state) {
        if (state is TaskOpenTaskScreenState) {
          Navigator.of(context).push(
            PageTransition(
              type: PageTransitionType.rightToLeft,
              childBuilder: (ctx) =>
                  ManipuleTaskScreen(task: state.task),
            ),
          )
          .then((i) {
            controller.reloadTasks();
          });
        } else if (state is TaskSuccessMessageState) {
          showMainSnackBar(context, state.sucessMessage);
        } else if (state is TaskErrorState) {
          showMyDialog(context, 'Oppss...', state.erroMessage);
        }
      },

      builder: (context, state) {
        if (state is TaskLoadingState) {
          return MainCircularProgress();
        } else if (state is TaskLoadedFilteredListState) {
          final tasksFilteredList = state.tasks;
          if (tasksFilteredList.isEmpty) {
            return Center(
              child: Text(
                "Hmm... couldn’t find anything\n with that filter.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            );
          } else {
            return TaskListWidget(
              deleteItem: controller.onPressDeleteItem,
              onPressOpenTask: controller.onPressOpenTask,
              tasks: tasksFilteredList,
            );
          }
        } else if (state is TaskLoadedListState) {
          final tasksList = state.tasks;
          if (tasksList.isEmpty) {
            return Center(
              child: Text(
                "Looks like you don’t have any \ntasks yet. Let’s add one!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            );
          } else {
            return TaskListWidget(
              deleteItem: controller.onPressDeleteItem,
              onPressOpenTask: controller.onPressOpenTask,
              tasks: tasksList,
            );
          }
        }

        return Container();
      },
    );
  }
}
