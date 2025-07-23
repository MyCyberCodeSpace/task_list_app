import 'package:flutter/material.dart';
import 'package:task_list_app/features/todo/data/status_data.dart';
import 'package:task_list_app/features/todo/model/todo_model.dart';

class TaskListView extends StatelessWidget {
  final List<TodoModel> tasks;
  final void Function(TodoModel) deleteItem;
  final void Function(TodoModel) onPressOpenTask;
  const TaskListView({
    super.key,
    required this.tasks,
    required this.deleteItem,
    required this.onPressOpenTask,
  });
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (ctx, index) {
        final item = tasks[index];
        return Dismissible(
          key: ValueKey(item),
          onDismissed: (direction) {
            deleteItem(item);
          },
          child: GestureDetector(
            onTap: () {
              onPressOpenTask(item);
            },
            child: Card(
              margin: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
              color: index % 2 == 0
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceBright,
              child: Padding(
                padding: EdgeInsetsGeometry.all(8),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: Theme.of(
                                context,
                              ).textTheme.bodyLarge!.fontSize,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusMapColor[item.status],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.status,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            item.description,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                        SizedBox(width: 20),
                        Text(item.categoryName),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
