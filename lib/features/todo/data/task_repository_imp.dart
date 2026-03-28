import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;
import 'package:task_list_app/features/todo/domain/model/todo_model.dart';
import 'package:task_list_app/features/todo/domain/repository/task_repository.dart';

class TaskRepositoryImp extends TaskRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  TaskRepositoryImp(this.auth, this.firestore, this.storage);

  @override
  Future<void> createTask({
    required String title,
    required String description,
    required String status,
    required DateTime dueDate,
    required String categoryId,
    File? mediaFile,
  }) async {
    final user = auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    var mediaUrl = '';
    if (mediaFile != null) {
      final fileName = p.basename(mediaFile.path);
      final ref = storage.ref().child('user_images/${user.uid}/$fileName');
      await ref.putFile(mediaFile);
      mediaUrl = await ref.getDownloadURL();
    }

    final updatedCategoryName = await getCategoryNameById(categoryId);

    await firestore
        .collection('tasks')
        .doc(user.uid)
        .collection('user_tasks')
        .add({
          'title': title,
          'description': description,
          'status': status,
          'dueDate': dueDate.toIso8601String(),
          'categoryId': categoryId,
          'categoryName': updatedCategoryName,
          'mediaUrl': mediaUrl,
          'userId': user.uid,
        });
  }

  @override
  Future<void> updateTask({
    required String id,
    required String title,
    required String description,
    required String status,
    required DateTime dueDate,
    required String categoryId,
    required String mediaUrl,
    File? mediaFile,
  }) async {
    final user = auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final updatedCategoryName = await getCategoryNameById(categoryId);
    String updatedMediaUrl = mediaUrl;

    if (mediaFile != null) {
      final fileName = p.basename(mediaFile.path);
      final ref = storage.ref().child('user_images/${user.uid}/$fileName');
      await ref.putFile(mediaFile);
      updatedMediaUrl = await ref.getDownloadURL();

      if (mediaUrl != '') {
        try {
          await storage.refFromURL(mediaUrl).delete();
        } catch (e) {
          throw Exception('Error deleting previous image: $e');
        }
      }
    }

    await firestore
        .collection('tasks')
        .doc(user.uid)
        .collection('user_tasks')
        .doc(id)
        .update({
          'title': title,
          'description': description,
          'status': status,
          'dueDate': dueDate.toIso8601String(),
          'categoryId': categoryId,
          'categoryName': updatedCategoryName,
          'mediaUrl': updatedMediaUrl,
          'userId': user.uid,
        });
  }

  @override
  Future<void> deleteTask({required TodoModel task}) async {
    final user = auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await firestore
        .collection('tasks')
        .doc(user.uid)
        .collection('user_tasks')
        .doc(task.id)
        .delete();

    final mediaUrl = task.mediaUrl;
    if (mediaUrl != '') {
      try {
        await storage.refFromURL(mediaUrl).delete();
      } catch (e) {
        throw Exception('Error deleting previous image: $e');
      }
    }
  }

  @override
  Future<List<TodoModel>> loadUserTasks() async {
    final user = auth.currentUser;
    final snapshot = await firestore
        .collection('tasks')
        .doc(user!.uid)
        .collection('user_tasks')
        .get();

    final List<TodoModel> tasks = [];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final updatedCategoryName = await getCategoryNameById(
        data['categoryId'],
      );
      tasks.add(
        TodoModel(
          id: doc.id,
          title: data['title'],
          description: data['description'],
          dueDate: DateTime.parse(data['dueDate']),
          status: data['status'],
          categoryId: data['categoryId'],
          categoryName: updatedCategoryName,
          mediaUrl: data['mediaUrl'],
        ),
      );
    }
    return tasks;
  }

  @override
  Future<List<TodoModel>> loadUserFilteredTasks(String searchTerm) async {
    final user = auth.currentUser;
    final snapshot = await firestore
        .collection('tasks')
        .doc(user!.uid)
        .collection('user_tasks')
        .get();

    searchTerm = searchTerm.toLowerCase();
    final List<TodoModel> tasks = [];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final updatedCategoryName = await getCategoryNameById(
        data['categoryId'],
      );

      final titleContains = data['title']
          .toString()
          .toLowerCase()
          .contains(searchTerm);
      final descriptionContains = data['description']
          .toString()
          .toLowerCase()
          .contains(searchTerm);
      final statusContains = data['status']
          .toString()
          .toLowerCase()
          .contains(searchTerm);
      final updatedCategoryNameContains = updatedCategoryName
          .toLowerCase()
          .contains(searchTerm);

      if (titleContains ||
          descriptionContains ||
          statusContains ||
          updatedCategoryNameContains) {
        tasks.add(
          TodoModel(
            id: doc.id,
            title: data['title'],
            description: data['description'],
            dueDate: DateTime.parse(data['dueDate']),
            status: data['status'],
            categoryId: data['categoryId'],
            categoryName: updatedCategoryName,
            mediaUrl: data['mediaUrl'],
          ),
        );
      }
    }
    return tasks;
  }

  @override
  Future<String> getCategoryNameById(String categoryId) async {
    final user = auth.currentUser;
    if (user == null) return 'Unknown';

    final snapshot = await firestore
        .collection('categories')
        .doc(user.uid)
        .collection('user_categories')
        .doc(categoryId)
        .get();

    if (snapshot.exists) {
      final data = snapshot.data();
      if (data != null) return data['categoryName'];
    }
    return 'Unknown';
  }
}
