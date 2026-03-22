import 'package:flutter/material.dart';
import 'package:task_list_app/features/category/presentation/controller/category_controller.dart';
import 'package:task_list_app/features/category/presentation/widgets/category_list.dart';
import 'package:task_list_app/core/widgets/main_bottom_navigator.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final controller = CategoryController();

  @override
  void initState() {
    super.initState();
    controller.init(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentHeight = MediaQuery.of(context).size.height;
    final currentWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Category Board',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),

      body: Center(
        child: Column(
          children: [
            Spacer(),
            Card(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              child: SizedBox(
                height: currentHeight * 0.65,
                width: currentWidth * 0.9,
                child: CategoryList(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                controller.onPressedCreate(context);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('Create'),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),

      bottomNavigationBar: MainBottomNavigator(selectedPageIndex: 1),
    );
  }
}
