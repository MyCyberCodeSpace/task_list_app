import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_list_app/features/auth/bloc/auth_bloc.dart';
import 'package:task_list_app/features/auth/bloc/auth_event.dart';
import 'package:task_list_app/features/auth/bloc/auth_state.dart';
import 'package:task_list_app/features/auth/screens/auth_screen.dart';
import 'package:task_list_app/features/category/bloc/category_bloc.dart';
import 'package:task_list_app/features/todo/bloc/task_bloc.dart';
import 'package:task_list_app/features/todo/screens/todo_screen.dart';
import 'package:task_list_app/core/widgets/main_circular_progress.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((fn) {
    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(FirebaseAuth.instance),
          ),
          BlocProvider(
            create: (context) => TaskBloc(FirebaseAuth.instance),
          ),
          BlocProvider(
            create: (context) => CategoryBloc(FirebaseAuth.instance),
          ),
        ],

        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthCheckStatusRequestedEvent());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 3, 167, 47),
          //brightness: Brightness.dark,
        ),
      ),
      home: BlocListener<AuthBloc, AuthState>(
        bloc: context.read<AuthBloc>(),
        listener: (context, state) {
          if (state is AuthLoadingState) {
            MainCircularProgress();
          } else if (state is AuthAuthenticatedState) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (ctx) => ToDoScreen()),
            );
          } else if (state is AuthUnauthenticatedState ||
              state is AuthErrorState ||
              state is AuthInitialState) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (ctx) => AuthScreen()),
            );
          }
        },
        child: const AuthScreen(),
      ),
    );
  }
}