import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_list_app/features/auth/data/auth_repository_imp.dart';
import 'package:task_list_app/features/auth/data/repository/auth_repository_local.dart';
import 'package:task_list_app/features/auth/domain/repository/auth_repository.dart';
import 'package:task_list_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:task_list_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:task_list_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:task_list_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:task_list_app/features/category/data/category_repository_imp.dart';
import 'package:task_list_app/features/category/data/repository/category_repository_local.dart';
import 'package:task_list_app/features/category/domain/repository/category_repository.dart';
import 'package:task_list_app/features/category/presentation/bloc/category_bloc.dart';
import 'package:task_list_app/features/todo/data/repository/task_repository_imp.dart';
import 'package:task_list_app/features/todo/data/repository/task_repository_local.dart';
import 'package:task_list_app/features/todo/domain/repository/task_repository.dart';
import 'package:task_list_app/features/todo/presentation/bloc/task_bloc.dart';
import 'package:task_list_app/features/todo/presentation/screens/todo_screen.dart';
import 'package:task_list_app/core/widgets/main_circular_progress.dart';
import 'package:task_list_app/firebase_options.dart';

const bool useLocalRepository = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  late final AuthRepository authRepository;
  late final TaskRepository taskRepository;
  late final CategoryRepository categoryRepository;

  if (useLocalRepository) {
    final localAuth = AuthRepositoryLocal();
    final localCategory = CategoryRepositoryLocal();
    final localTask = TaskRepositoryLocal(localCategory.categoryNamesMap);

    authRepository = localAuth;
    categoryRepository = localCategory;
    taskRepository = localTask;
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final firebaseAuth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;

    authRepository = AuthRepositoryImp(firebaseAuth);
    categoryRepository = CategoryRepositoryImp(firebaseAuth, firestore);
    taskRepository = TaskRepositoryImp(firebaseAuth, firestore, storage);
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(authRepository),
          ),
          BlocProvider(
            create: (context) => TaskBloc(taskRepository),
          ),
          BlocProvider(
            create: (context) => CategoryBloc(categoryRepository),
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