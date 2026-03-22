import 'package:task_list_app/features/category/domain/model/category_model.dart';

export 'package:task_list_app/features/category/domain/typedef/category_typedef.dart';

abstract class CategoryRepository {
  Future<void> createCategory({required String categoryName});

  Future<void> updateCategory({
    required String id,
    required String newCategoryName,
  });

  Future<void> deleteCategory({required String id});

  Future<List<CategoryModel>> loadUserCategories();
}