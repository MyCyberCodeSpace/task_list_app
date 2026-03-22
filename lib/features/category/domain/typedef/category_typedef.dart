import 'package:task_list_app/features/category/domain/model/category_model.dart';

typedef CreateCategory = Future<void> Function({required String categoryName});

typedef UpdateCategory = Future<void> Function({
  required String id,
  required String newCategoryName,
});

typedef DeleteCategory = Future<void> Function({required String id});

typedef LoadUserCategories = Future<List<CategoryModel>> Function();
