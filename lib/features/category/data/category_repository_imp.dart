import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_list_app/features/category/domain/model/category_model.dart';
import 'package:task_list_app/features/category/domain/repository/category_repository.dart';
import 'package:task_list_app/features/todo/domain/model/todo_model.dart';

class CategoryRepositoryImp extends CategoryRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  CategoryRepositoryImp(this.auth, this.firestore);

  @override
  Future<void> createCategory({required String categoryName}) async {
    final user = auth.currentUser;

    await firestore
        .collection('categories')
        .doc(user!.uid)
        .collection('user_categories')
        .add({
          'categoryName': categoryName,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  @override
  Future<void> updateCategory({
    required String id,
    required String newCategoryName,
  }) async {
    final user = auth.currentUser;

    await firestore
      .collection('categories')
      .doc(user!.uid)              
      .collection('user_categories')
      .doc(id) 
      .update({'categoryName': newCategoryName});
  }

  @override
  Future<void> deleteCategory({required String id}) async {
    final user = auth.currentUser;

    final snapshot = await firestore
        .collection('tasks')
        .doc(user!.uid)
        .collection('user_tasks')
        .get();

    final List<TodoModel> currentTasks = [];
    final docsList = snapshot.docs;
    for (var doc in docsList) {
      final data = doc.data();
      currentTasks.add(
        TodoModel(
          id: doc.id,
          title: data['title'],
          description: data['description'],
          dueDate: DateTime.parse(data['dueDate']),
          status: data['status'],
          categoryId: data['categoryId'],
          categoryName: data['categoryName'],
          mediaUrl: data['mediaUrl'],
        ),
      );
    }

    bool exist = currentTasks.any((item) => item.categoryId == id);
    if (exist) {
      throw Exception(
        'Before deleting a category, you must remove it from all tasks that use it.',
      );
    } else {
      await firestore
          .collection('categories')
          .doc(user.uid)
          .collection('user_categories')
          .doc(id)
          .delete();
    }
  }

  @override
  Future<List<CategoryModel>> loadUserCategories() async {
    final user = auth.currentUser;
    final snapshot = await firestore
        .collection('categories')
        .doc(user!.uid)
        .collection('user_categories')
        .get();

    final List<CategoryModel> categoryList = [];
    final docsList = snapshot.docs;
    for (var doc in docsList) {
      final data = doc.data();
      categoryList.add(
        CategoryModel(id: doc.id, categoryName: data['categoryName']),
      );
    }
    return categoryList;
  }
}
