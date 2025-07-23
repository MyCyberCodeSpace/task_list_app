import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:page_transition/page_transition.dart';
import 'package:task_list_app/features/auth/bloc/auth_bloc.dart';
import 'package:task_list_app/features/auth/bloc/auth_event.dart';
import 'package:task_list_app/features/auth/bloc/auth_state.dart';
import 'package:task_list_app/features/auth/screens/auth_screen.dart';
import 'package:task_list_app/features/category/bloc/category_bloc.dart';
import 'package:task_list_app/features/category/bloc/category_event.dart';
import 'package:task_list_app/features/category/bloc/category_state.dart';
import 'package:task_list_app/features/todo/bloc/task_bloc.dart';
import 'package:task_list_app/features/todo/bloc/task_event.dart';
import 'package:task_list_app/features/todo/screens/new_task_screen.dart';
import 'package:task_list_app/features/todo/widgets/task_list.dart';
import 'package:task_list_app/core/ui_helpers/main_alert_dialog.dart';
import 'package:task_list_app/core/widgets/main_bottom_navigator.dart';

class ToDoScreen extends StatefulWidget {
  const ToDoScreen({super.key});

  @override
  State<ToDoScreen> createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  bool _openCreate = false;
  var _searchTerm = '';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController =
      TextEditingController();
  late final AuthBloc authBloc;
  late final TaskBloc taskBloc;
  late final CategoryBloc categoryBloc;

  @override
  void initState() {
    super.initState();
    authBloc = context.read<AuthBloc>();
    taskBloc = context.read<TaskBloc>();
    categoryBloc = context.read<CategoryBloc>();
  }

  void onPressedFilter() async {
    final isValidForm = _formKey.currentState!.validate();
    _formKey.currentState!.save();

    if (isValidForm) {
      taskBloc.add(TaskLoadFilteredListTasksEvent(_searchTerm));
    }
  }

  void onPressedClear() {
    setState(() {
      _searchController.clear();
      taskBloc.add(TaskLoadAllTasksEvent());
    });
  }

  void onPressedCreate() {
    setState(() {
      _openCreate = true;
    });
    categoryBloc.add(CategoryLoadAllCategoriesEvent());
  }

  @override
  Widget build(BuildContext context) {
    final currentHeight = MediaQuery.of(context).size.height;
    final currentWidth = MediaQuery.of(context).size.width;

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticatedState) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (ctx) => const AuthScreen(),
                ),
              );
            } else if (state is AuthErrorState) {
              showMyDialog(
                context,
                'Authentication error',
                state.erroMessage,
              );
            }
          },
        ),
        BlocListener<CategoryBloc, CategoryState>(
          listener: (context, state) {
            if (state is CategoryLoadedListState) {
              final categoryList = state.categoryList;
              if (_openCreate) {
                if (categoryList.isNotEmpty) {
                  _openCreate = false;
                  Navigator.of(context)
                      .push(
                        PageTransition(
                          type: PageTransitionType.rightToLeft,
                          childBuilder: (ctx) =>
                              CreateNewTaskScreen(),
                        ),
                      ).then((i){
                        taskBloc.add(TaskLoadAllTasksEvent());
                      });
                } else {
                  showMyDialog(
                    context,
                    'Opss..',
                    'You must create a category before adding a task',
                  );
                }
              }
            }
          },
        ),
      ],

      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'TaskBoard',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                authBloc.add(AuthLogoutRequestedEvent());
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Form(
                      key: _formKey,
                      child: Expanded(
                        child: TextFormField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'search by word',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Please enter at least one letter.';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _searchTerm = newValue!;
                          },
                        ),
                      ),
                    ),

                    IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: onPressedClear,
                    ),

                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: onPressedFilter,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  onPressedCreate();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text('Create'),
              ),

              SizedBox(height: 10),

              Expanded(
                child: Card(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant,
                  child: SizedBox(
                    height: currentHeight * 0.6,
                    width: currentWidth * 0.9,
                    child: TaskList(),
                  ),
                ),
              ),
            ],
          ),
        ),

        bottomNavigationBar: MainBottomNavigator(
          selectedPageIndex: 0,
        ),
      ),
    );
  }
}
