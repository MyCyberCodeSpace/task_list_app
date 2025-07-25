import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_list_app/features/category/bloc/category_event.dart';
import 'package:task_list_app/features/category/bloc/category_state.dart';
import 'package:task_list_app/features/category/repository/category_repository.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CategoryBloc(this._firebaseAuth) : super(CategoryInitialState()) {
    on<CategoryCreateNewCategoryEvent>((event, emit) async {
      emit(CategoryLoadingState());
      try {
        final repository = CategoryRepository(
          _firebaseAuth,
          _firestore,
        );
        await repository.createCategory(
          categoryName: event.categoryName,
        );
      } catch (e) {
        emit(CategoryErroState('Erro creating new category: $e'));
      }
    });

    on<CategoryUpdateCategoryEvent>((event, emit) async {
      emit(CategoryLoadingState());
      try {
        final repository = CategoryRepository(
          _firebaseAuth,
          _firestore,
        );
        await repository.updateCategory(
          id: event.categoryId,
          newCategoryName: event.categoryNewContent,
        );
      } catch (e) {
        emit(CategoryErroState('Erro updating category: $e'));
      }
    });

    on<CategoryLoadAllCategoriesEvent>((event, emit) async {
      emit(CategoryLoadingState());
      try {
        final repository = CategoryRepository(
          _firebaseAuth,
          _firestore,
        );
        final categoryList = await repository.loadUserCategories();
        emit(CategoryLoadedListState(categoryList));
      } catch (e) {
        emit(CategoryErroState('Erro removing category: $e'));
      }
    });

    on<CategoryDeleteCategoryEvent>((event, emit) async {
      emit(CategoryLoadingState());
      try {
        final repository = CategoryRepository(
          _firebaseAuth,
          _firestore,
        );
        await repository.deleteCategory(id: event.categoryId);
      } catch (e) {
        emit(CategoryErroState('Erro removing category: $e'));
      }
    });

  }
}
