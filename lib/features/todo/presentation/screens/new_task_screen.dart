import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_list_app/core/ui_helpers/main_snackbar_helper.dart';
import 'package:task_list_app/features/category/presentation/bloc/category_bloc.dart';
import 'package:task_list_app/features/category/presentation/bloc/category_event.dart';
import 'package:task_list_app/features/category/presentation/bloc/category_state.dart';
import 'package:task_list_app/features/todo/presentation/bloc/task_bloc.dart';
import 'package:task_list_app/features/todo/presentation/bloc/task_state.dart';
import 'package:task_list_app/features/todo/domain/enum/task_status_enum.dart';
import 'package:task_list_app/core/ui_helpers/main_alert_dialog.dart';
import 'package:task_list_app/core/widgets/user_media.dart';
import 'package:task_list_app/features/todo/presentation/controllers/new_task_controller.dart';

class CreateNewTaskScreen extends StatefulWidget {
  const CreateNewTaskScreen({super.key});

  @override
  State<CreateNewTaskScreen> createState() =>
      _CreateNewTaskScreenState();
}

class _CreateNewTaskScreenState extends State<CreateNewTaskScreen> {
  late final NewTaskController _controller;
  late final CategoryBloc _categoryBloc;

  @override
  void initState() {
    super.initState();
    _controller = NewTaskController(
      taskBloc: context.read<TaskBloc>(),
    );
    _categoryBloc = context.read<CategoryBloc>();
    _categoryBloc.add(CategoryLoadAllCategoriesEvent());
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

  void _onPressCreate() async {
    if (!_controller.hasSelectedDate()) {
      showMyDialog(
        context,
        'Opss...',
        'Don’t forget to choose a date!',
      );
      return;
    }

    if (!_controller.hasSelectedCategory()) {
      showMyDialog(
        context,
        'Opss...',
        'Don’t forget to choose a category!',
      );
      return;
    }

    _controller.createTask();

    showMainSnackBar(
      context,
      'Your request has been sent. Please wait a moment\nwhile the server processes it... :)',
    );

    await Future.delayed(Duration(milliseconds: 300));
    _controller.loadAllTasks();
    _controller.resetForm();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskStateController>(
      listener: (context, state) {
        if (state is TaskSuccessMessageState) {
          showMainSnackBar(context, state.sucessMessage);
        } else if (state is TaskErrorState) {
          showMyDialog(context, 'opsss...', state.erroMessage);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text('Create new taks')),
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
                            controller: _controller.titleController,
                            decoration: InputDecoration(
                              labelText: 'Title',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                            keyboardType: TextInputType.text,
                            autocorrect: false,
                            textCapitalization:
                                TextCapitalization.none,
                            validator: _controller.validateTitle,
                            onSaved: (value) =>
                                _controller.setTitle(value!),
                          ),
                        ),
                      ),

                      Row(
                        children: [
                          DropdownButton(
                            value: _controller.selectStatus,
                            items: TaskStatus.values.map((status) {
                              return DropdownMenuItem(
                                value: status.label,
                                child: Text(status.label),
                              );
                            }).toList(),
                            onChanged: (value) =>
                                _controller.setStatus(value!),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.end,
                              crossAxisAlignment:
                                  CrossAxisAlignment.center,
                              children: [
                                Text(
                                  _controller.selectedDate == null
                                      ? 'No date selected'
                                      : _controller.formatter.format(
                                          _controller.selectedDate!,
                                        ),
                                ),
                                IconButton(
                                  onPressed: () => _controller
                                      .presentDatePicker(context),
                                  icon: Icon(Icons.calendar_month),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Select your category:'),
                          BlocBuilder<CategoryBloc, CategoryState>(
                            builder: (context, state) {
                              if (state is CategoryLoadedListState) {
                                final categoryList =
                                    state.categoryList;
                                if (categoryList.isNotEmpty) {
                                  _controller.selectCategory ??=
                                      categoryList.first.id;
                                  return DropdownButton(
                                    value: _controller.selectCategory,
                                    items: categoryList.map((item) {
                                      return DropdownMenuItem(
                                        value: item.id,
                                        child: Text(
                                          item.categoryName,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) => _controller
                                        .setCategory(value),
                                  );
                                }
                              }
                              return Text('Empty List');
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: 10),

                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller:
                                _controller.descriptionController,
                            textAlignVertical: TextAlignVertical.top,
                            textAlign: TextAlign.left,
                            minLines: 8,
                            maxLines: null,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                            keyboardType: TextInputType.multiline,
                            autocorrect: false,
                            textCapitalization:
                                TextCapitalization.none,
                            validator:
                                _controller.validateDescription,
                            onSaved: (value) =>
                                _controller.setDescription(value!),
                          ),
                        ),
                      ),

                      SizedBox(height: 10),

                      UserImagePicker(
                        onPickImage: (image) =>
                            _controller.setMedia(image),
                      ),

                      SizedBox(height: 20),
                      
                      ElevatedButton(
                        onPressed: _onPressCreate,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text('Create'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
