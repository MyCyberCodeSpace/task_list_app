import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_list_app/core/ui_helpers/main_snackbar_helper.dart';
import 'package:task_list_app/core/widgets/main_circular_progress.dart';
import 'package:task_list_app/features/category/presentation/bloc/category_bloc.dart';
import 'package:task_list_app/features/category/presentation/bloc/category_state.dart';
import 'package:task_list_app/features/todo/presentation/bloc/task_bloc.dart';
import 'package:task_list_app/features/todo/presentation/bloc/task_state.dart';
import 'package:task_list_app/features/todo/domain/enum/task_status_enum.dart';
import 'package:task_list_app/features/todo/domain/model/todo_model.dart';
import 'package:task_list_app/core/ui_helpers/main_alert_dialog.dart';
import 'package:task_list_app/core/widgets/user_media.dart';
import 'package:task_list_app/features/todo/presentation/controllers/manage_task_controller.dart';


class ManipuleTaskScreen extends StatefulWidget {
  final TodoModel task;
  const ManipuleTaskScreen({super.key, required this.task});

  @override
  State<ManipuleTaskScreen> createState() => _CreateNewTaskScreenState();
}

class _CreateNewTaskScreenState extends State<ManipuleTaskScreen> {
  late final ManageTaskController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ManageTaskController(
      taskBloc: context.read<TaskBloc>(),
      task: widget.task,
    );
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  void _onPressUpdate() {
    if (!_controller.hasSelectedDate()) {
      showMyDialog(context, 'Opss...', 'Please select a date');
      return;
    }
    _controller.updateTask();
  }

  void _onPressDeleteItem() {
    _controller.deleteTask();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskBloc, TaskStateController>(
      listener: (context, state) {
        if (state is TaskSuccessMessageState) {
          showMainSnackBar(context, state.sucessMessage);
          Navigator.of(context).pop();
        } else if (state is TaskErrorState) {
          showMyDialog(context, 'Oppss...', state.erroMessage);
        }
      },
      builder: (context, state) {
        if (state is TaskLoadingState) {
          return Scaffold(
            appBar: AppBar(title: Text('Manage Task')),
            body: MainCircularProgress(),
          );
        } else if (state is TaskSuccessMessageState ||
            state is TaskOpenTaskScreenState) {
          return Scaffold(
            appBar: AppBar(title: Text('Manage Task')),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Form(
                      key: _controller.formKey,
                      child: Column(
                        children: [

                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                initialValue: _controller.inputTitle,
                                decoration: InputDecoration(
                                  labelText: 'Title',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                ),
                                keyboardType: TextInputType.text,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                validator: _controller.validateTitle,
                                onSaved: (value) => _controller.setTitle(value!),
                              ),
                            ),
                          ),

                          Row(
                            children: [
                              DropdownButton(
                                value: _controller.selectStatus,
                                items: TaskStatus.values.map((status) {
                                  return DropdownMenuItem(
                                    value: status,
                                    child: Text(status.label),
                                  );
                                }).toList(),
                                onChanged: (value) => _controller.setStatus(value!),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      _controller.selectedDate == null
                                          ? 'No date selected'
                                          : _controller.formatter.format(_controller.selectedDate!),
                                    ),
                                    IconButton(
                                      onPressed: () => _controller.presentDatePicker(context),
                                      icon: Icon(Icons.calendar_month),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Select your category:'),
                              BlocBuilder<CategoryBloc, CategoryState>(
                                builder: (context, state) {
                                  if (state is CategoryLoadedListState) {
                                    final categoryList = state.categoryList;
                                    if (categoryList.isNotEmpty) {
                                      return DropdownButton(
                                        value: _controller.selectCategory,
                                        items: categoryList.map((item) {
                                          return DropdownMenuItem(
                                            value: item.id,
                                            child: Text(item.categoryName),
                                          );
                                        }).toList(),
                                        onChanged: (value) => _controller.setCategory(value!),
                                      );
                                    }
                                  }
                                  return Text('Empity List');
                                },
                              ),
                            ],
                          ),

                          SizedBox(height: 10),

                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                initialValue: _controller.inputDescription,
                                textAlignVertical: TextAlignVertical.top,
                                textAlign: TextAlign.left,
                                minLines: 8,
                                maxLines: null,
                                decoration: InputDecoration(
                                  labelText: 'Description',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                ),
                                keyboardType: TextInputType.multiline,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                validator: _controller.validateDescription,
                                onSaved: (value) => _controller.setDescription(value!),
                              ),
                            ),
                          ),

                          SizedBox(height: 10),

                          UserImagePicker(
                            onPickImage: (image) => _controller.setMedia(image),
                            mediaUrl: _controller.mediaUrl,
                          ),

                          SizedBox(height: 20),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _onPressDeleteItem,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text('Delete'),
                              ),
                              SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: _onPressUpdate,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text('Update'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(title: Text('Manage Task')),
            body: MainCircularProgress(),
          );
        }
      },
    );
  }
}
