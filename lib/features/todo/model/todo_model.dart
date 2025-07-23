
class TodoModel {
  String id;
  String title;
  String description;
  String status;
  DateTime dueDate;
  String categoryId;
  String categoryName;
  String mediaUrl;

  TodoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.categoryId,
    required this.categoryName,
    required this.mediaUrl,
  });
}