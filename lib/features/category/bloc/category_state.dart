import 'package:task_list_app/features/category/model/category_model.dart';

abstract class CategoryState {}

class CategoryInitialState extends CategoryState {}

class CategoryLoadingState extends CategoryState {}

class CategorySuccessState extends CategoryState {}

class CategoryErroState extends CategoryState {
  final String erroMessage;
  CategoryErroState(this.erroMessage);
}

class CategoryLoadedListState extends CategoryState {
  final List<CategoryModel> categoryList;
  CategoryLoadedListState(this.categoryList);
}
