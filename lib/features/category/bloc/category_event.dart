import 'package:task_list_app/features/category/model/category_model.dart';

abstract class CategoryEvent {}

class CategoryCreateNewCategoryEvent extends CategoryEvent {
  final String categoryName;
  CategoryCreateNewCategoryEvent(this.categoryName);
}

class CategoryUpdateCategoryEvent extends CategoryEvent {
  final String categoryId;
  final String categoryNewContent;
  CategoryUpdateCategoryEvent(
    this.categoryId,
    this.categoryNewContent,
  );
}

class CategoryDeleteCategoryEvent extends CategoryEvent {
  final String categoryId;
  CategoryDeleteCategoryEvent(this.categoryId);
}

class CategoryLoadAllCategoriesEvent extends CategoryEvent {}

class CategoryOpenCategoryEvent extends CategoryEvent {
  final CategoryModel category;
  CategoryOpenCategoryEvent(this.category);
}
