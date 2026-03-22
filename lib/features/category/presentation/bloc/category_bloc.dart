import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_list_app/features/category/domain/repository/category_repository.dart';
import 'package:task_list_app/features/category/presentation/bloc/category_event.dart';
import 'package:task_list_app/features/category/presentation/bloc/category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _repository;

  CategoryBloc(this._repository) : super(CategoryInitialState()) {
    on<CategoryCreateNewCategoryEvent>((event, emit) async {
      emit(CategoryLoadingState());
      try {
        await _repository.createCategory(
          categoryName: event.categoryName,
        );
      } catch (e) {
        emit(CategoryErroState('Erro creating new category: $e'));
      }
    });

    on<CategoryUpdateCategoryEvent>((event, emit) async {
      emit(CategoryLoadingState());
      try {
        await _repository.updateCategory(
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
        final categoryList = await _repository.loadUserCategories();
        emit(CategoryLoadedListState(categoryList));
      } catch (e) {
        emit(CategoryErroState('Erro removing category: $e'));
      }
    });

    on<CategoryDeleteCategoryEvent>((event, emit) async {
      emit(CategoryLoadingState());
      try {
        await _repository.deleteCategory(id: event.categoryId);
      } catch (e) {
        emit(CategoryErroState('Erro removing category: $e'));
      }
    });

  }
}
