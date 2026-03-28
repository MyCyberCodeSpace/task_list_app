import 'package:flutter/material.dart';

enum TaskStatus {
  toDo('To Do', Colors.green),
  inProgress('In Progress', Colors.yellow),
  done('Done', Colors.blue);

  final String label;
  final Color color;

  const TaskStatus(this.label, this.color);

  static TaskStatus fromLabel(String label) {
    return TaskStatus.values.firstWhere((s) => s.label == label);
  }
}