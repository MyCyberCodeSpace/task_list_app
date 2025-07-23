import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task_list_app/core/ui_helpers/main_snackbar_helper.dart';
import 'package:task_list_app/core/widgets/main_circular_progress.dart';
import 'package:task_list_app/features/category/bloc/category_bloc.dart';
import 'package:task_list_app/features/category/bloc/category_state.dart';
import 'package:task_list_app/features/todo/bloc/task_bloc.dart';
import 'package:task_list_app/features/todo/bloc/task_event.dart';
import 'package:task_list_app/features/todo/bloc/task_state.dart';
import 'package:task_list_app/features/todo/data/status_data.dart';
import 'package:task_list_app/features/todo/model/todo_model.dart';
import 'package:task_list_app/core/ui_helpers/main_alert_dialog.dart';
import 'package:task_list_app/core/widgets/user_media.dart';

final formatter = DateFormat.yMd();

class ManipuleTaskScreen extends StatefulWidget {
  final TodoModel task;
  const ManipuleTaskScreen({super.key, required this.task});

  @override
  State<ManipuleTaskScreen> createState() =>
      _CreateNewTaskScreenState();
}

class _CreateNewTaskScreenState extends State<ManipuleTaskScreen> {
  late final TaskBloc taskBloc;
  final _formKey = GlobalKey<FormState>();
  var _inputTitle = '';
  var _inputDescription = '';
  String _selectStatus = statusList[0];
  String _selectCategory = '';
  DateTime? _selectedDate;
  File? _selectedMedia;
  String _mediaUrl = '';

  @override
  void initState() {
    super.initState();
    taskBloc = context.read<TaskBloc>();
    _inputTitle = widget.task.title;
    _inputDescription = widget.task.description;
    _selectStatus = widget.task.status;
    _selectCategory = widget.task.categoryId;
    _selectedDate = widget.task.dueDate;
    _mediaUrl = widget.task.mediaUrl;
  }

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firtsDate = DateTime(now.year - 2, now.month, now.day);
    final lastDate = DateTime(now.year + 2, now.month, now.day);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firtsDate,
      lastDate: lastDate,
    );

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _onPressUpdate() async {
    final isValidForm = _formKey.currentState!.validate();

    if (!isValidForm) {
      return;
    }
    _formKey.currentState!.save();

    if (_selectedDate == null) {
      showMyDialog(context, 'Opss...', 'Please select a date');
      return;
    }

    taskBloc.add(
      TaskUpdateTaskEvent(
        id: widget.task.id,
        title: _inputTitle,
        description: _inputDescription,
        dueDate: _selectedDate!,
        status: _selectStatus,
        categoryId: _selectCategory,
        mediaUrl: widget.task.mediaUrl,
        mediaFile: _selectedMedia,
      ),
    );
  }

  void _onPressDeleteItem() {
    taskBloc.add(TaskDeleteTasksEvent(widget.task));
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
                      key: _formKey,
                      child: Column(
                        children: [
                          // ##############
                          // TITLE
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                initialValue: _inputTitle,
                                decoration: InputDecoration(
                                  labelText: 'Title',
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                ),
                                keyboardType: TextInputType.text,
                                autocorrect: false,
                                textCapitalization:
                                    TextCapitalization.none,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Please enter at least one letter.';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  _inputTitle = newValue!;
                                },
                              ),
                            ),
                          ),
                          // ##############
                          // SELECTIONS
                          Row(
                            children: [
                              DropdownButton(
                                value: _selectStatus,
                                items: statusList.map((status) {
                                  return DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectStatus = value!;
                                  });
                                },
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.end,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      _selectedDate == null
                                          ? 'No date selected'
                                          : formatter.format(
                                              _selectedDate!,
                                            ),
                                    ),
                                    IconButton(
                                      onPressed: _presentDatePicker,
                                      icon: Icon(
                                        Icons.calendar_month,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // ##############
                          // CATEGORY
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Select your category:'),

                              BlocBuilder<
                                CategoryBloc,
                                CategoryState
                              >(
                                builder: (context, state) {
                                  if (state
                                      is CategoryLoadedListState) {
                                    final categoryList =
                                        state.categoryList;

                                    if (categoryList.isNotEmpty) {
                                      return DropdownButton(
                                        value: _selectCategory,
                                        items: categoryList.map((
                                          item,
                                        ) {
                                          final categoryId = item.id;
                                          final categoryName =
                                              item.categoryName;
                                          return DropdownMenuItem(
                                            value: categoryId,
                                            child: Text(categoryName),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectCategory = value!;
                                          });
                                        },
                                      );
                                    }
                                  }
                                  return Text('Empity List');
                                },
                              ),
                            ],
                          ),

                          // ##############
                          // DESCRIPTION
                          SizedBox(height: 10),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                initialValue: _inputDescription,
                                textAlignVertical:
                                    TextAlignVertical.top,
                                textAlign: TextAlign.left,
                                minLines: 8,
                                maxLines: null,
                                decoration: InputDecoration(
                                  labelText: 'Description',

                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                ),
                                keyboardType: TextInputType.multiline,
                                autocorrect: false,
                                textCapitalization:
                                    TextCapitalization.none,

                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Please enter at least one letter.';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) {
                                  _inputDescription = newValue!;
                                },
                              ),
                            ),
                          ),

                          // ##############
                          // MEDIA
                          SizedBox(height: 10),
                          UserImagePicker(
                            onPickImage: (image) {
                              _selectedMedia = image;
                            },
                            mediaUrl: _mediaUrl,
                          ),

                          // ##############
                          // BUTTOM
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,

                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _onPressDeleteItem();
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text('Delete'),
                              ),
                              SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: () {
                                  _onPressUpdate();
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(20),
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
