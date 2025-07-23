import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_list_app/features/todo/screens/todo_screen.dart';
import 'package:task_list_app/features/auth/bloc/auth_bloc.dart';
import 'package:task_list_app/features/auth/bloc/auth_event.dart';
import 'package:task_list_app/features/auth/bloc/auth_state.dart';
import 'package:task_list_app/core/ui_helpers/main_alert_dialog.dart';
import 'package:task_list_app/core/widgets/main_circular_progress.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  late final AuthBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = context.read<AuthBloc>();
  }

  var _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  var _enteredEmail = '';
  var _enteredPassword = '';

  void _submit() {
    final isValidForm = _formKey.currentState!.validate();

    if (isValidForm) {
      _formKey.currentState!.save();

      if (_isLogin) {
        bloc.add(
          AuthLoginRequestedEvent(_enteredEmail, _enteredPassword),
        );
      } else {
        bloc.add(
          AuthCreateAccountEvent(_enteredEmail, _enteredPassword),
        );
      }
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        bloc: bloc,
        listener: (context, state) {
          if (state is AuthAuthenticatedState) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (ctx) => const ToDoScreen()),
            );
          } else if (state is AuthErrorState) {
            showMyDialog(
              context,
              'Authentication error',
              state.erroMessage,
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoadingState) {
            return MainCircularProgress();
          } else if (state is AuthUnauthenticatedState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Weelcome',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  Text(
                    "Control your progress",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w200,
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.all(20),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // ##############
                            // EMAIL
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Email Address',
                              ),
                              keyboardType:
                                  TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization:
                                  TextCapitalization.none,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !value.contains('@')) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                              onSaved: (newValue) =>
                                  _enteredEmail = newValue!,
                            ),
                            // ##############
                            // PASSWORD
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Password',
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().length < 6) {
                                  return 'Password must be at least 6 characters long.';
                                }
                                return null;
                              },
                              onSaved: (newValue) =>
                                  _enteredPassword = newValue!,
                            ),
                            // ##############
                            // BUTTONS
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _submit,
                              child: Text(
                                _isLogin ? 'Login' : 'Signup',
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(
                                _isLogin
                                    ? 'Create an account'
                                    : 'I already have an account',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return Container();
        },
      ),
    );
  }
}
