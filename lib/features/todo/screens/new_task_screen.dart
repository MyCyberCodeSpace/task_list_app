import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task_list_app/core/ui_helpers/main_snackbar_helper.dart';
import 'package:task_list_app/features/category/bloc/category_bloc.dart';
import 'package:task_list_app/features/category/bloc/category_event.dart';
import 'package:task_list_app/features/category/bloc/category_state.dart';
import 'package:task_list_app/features/todo/bloc/task_bloc.dart';
import 'package:task_list_app/features/todo/bloc/task_event.dart';
import 'package:task_list_app/features/todo/bloc/task_state.dart';
import 'package:task_list_app/features/todo/data/status_data.dart';
import 'package:task_list_app/core/ui_helpers/main_alert_dialog.dart';
import 'package:task_list_app/core/widgets/user_media.dart';

final formatter = DateFormat.yMd();

class CreateNewTaskScreen extends StatefulWidget {
  const CreateNewTaskScreen({super.key});

  @override
  State<CreateNewTaskScreen> createState() =>
      _CreateNewTaskScreenState();
}

class _CreateNewTaskScreenState extends State<CreateNewTaskScreen> {
  late final TaskBloc taskBloc;
  late final CategoryBloc categoryBloc;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  var _inputTitle = '';
  var _inputDescription = '';
  String _selectStatus = statusList[0];
  String? _selectCategory;
  DateTime? _selectedDate;
  File? _selectedMedia;

  @override
  void initState() {
    super.initState();
    taskBloc = context.read<TaskBloc>();
    categoryBloc = context.read<CategoryBloc>();
    categoryBloc.add(CategoryLoadAllCategoriesEvent());
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
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

  void _onPressCreate() async {
    final isValidForm = _formKey.currentState!.validate();

    if (!isValidForm) {
      return;
    }
    _formKey.currentState!.save();

    if (_selectedDate == null) {
      showMyDialog(
        context,
        'Opss...',
        'Don’t forget to choose a date!',
      );
      return;
    }

    if (_selectCategory == null) {
      showMyDialog(
        context,
        'Opss...',
        'Don’t forget to choose a category!',
      );
      return;
    }

    taskBloc.add(
      TaskCreateNewTaskEvent(
        _inputTitle,
        _inputDescription,
        _selectedDate!,
        _selectStatus,
        _selectCategory!,
        _selectedMedia,
      ),
    );

    showMainSnackBar(
      context,
      'Your request has been sent. Please wait a moment\nwhile the server processes it... :)',
    );

    await Future.delayed(Duration(milliseconds: 300));
    taskBloc.add(TaskLoadAllTasksEvent());
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _selectedDate = null;
      _selectStatus = statusList[0];
      _selectCategory = null;
      _selectedMedia = null;
    });
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
                  key: _formKey,
                  child: Column(
                    children: [
                      // ##############
                      // TITLE
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            controller: _titleController,
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
                                  icon: Icon(Icons.calendar_month),
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

                          BlocBuilder<CategoryBloc, CategoryState>(
                            builder: (context, state) {
                              if (state is CategoryLoadedListState) {
                                final categoryList =
                                    state.categoryList;
                                if (categoryList.isNotEmpty) {
                                  // ignore: prefer_conditional_assignment
                                  if (_selectCategory == null) {
                                    _selectCategory =
                                        categoryList.first.id;
                                  }

                                  return DropdownButton(
                                    value: _selectCategory,
                                    items: categoryList.map((item) {
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
                            controller: _descriptionController,
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

                      SizedBox(height: 10),
                      // ##############
                      // MEDIA
                      UserImagePicker(
                        onPickImage: (image) {
                          _selectedMedia = image;
                        },
                      ),

                      SizedBox(height: 20),
                      // ##############
                      // BUTTOM
                      ElevatedButton(
                        onPressed: () {
                          _onPressCreate();
                        },
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
