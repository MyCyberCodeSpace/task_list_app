import 'package:task_list_app/features/category/domain/model/category_model.dart';
import 'package:task_list_app/features/category/domain/repository/category_repository.dart';

class CategoryRepositoryLocal extends CategoryRepository {
  final List<CategoryModel> _categories = [];
  int _nextId = 1;

  CategoryRepositoryLocal() {
    _seedData();
  }

  void _seedData() {
    _categories.addAll([
      CategoryModel(id: '${_nextId++}', categoryName: 'Study'),
      CategoryModel(id: '${_nextId++}', categoryName: 'Personal'),
      CategoryModel(id: '${_nextId++}', categoryName: 'Work'),
    ]);
  }

  Map<String, String> get categoryNamesMap {
    return {for (var c in _categories) c.id: c.categoryName};
  }

  @override
  Future<void> createCategory({required String categoryName}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _categories.add(
      CategoryModel(id: '${_nextId++}', categoryName: categoryName),
    );
  }

  @override
  Future<void> updateCategory({
    required String id,
    required String newCategoryName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _categories.indexWhere((c) => c.id == id);
    if (index == -1) throw Exception('Category not found');
    _categories[index] = CategoryModel(id: id, categoryName: newCategoryName);
  }

  @override
  Future<void> deleteCategory({required String id}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _categories.removeWhere((c) => c.id == id);
  }

  @override
  Future<List<CategoryModel>> loadUserCategories() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_categories);
  }
}
