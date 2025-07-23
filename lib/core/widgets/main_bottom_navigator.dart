import 'package:flutter/material.dart';
import 'package:task_list_app/features/category/screens/category_screen.dart';
import 'package:task_list_app/features/todo/screens/todo_screen.dart';
import 'package:page_transition/page_transition.dart';

class MainBottomNavigator extends StatefulWidget {
  final int selectedPageIndex;
  const MainBottomNavigator({
    super.key,
    required this.selectedPageIndex,
  });

  @override
  State<MainBottomNavigator> createState() =>
      _MainBottomNavigatorState();
}

class _MainBottomNavigatorState extends State<MainBottomNavigator> {
  void _setScreen(int index) {
    if (index == 0) {
      Navigator.of(context).pushReplacement(
        PageTransition(
          type: PageTransitionType.fade,
          childBuilder: (ctx) => ToDoScreen(),
        ),
      );
    } else if (index == 1) {
      Navigator.of(context).pushReplacement(
        PageTransition(
          type: PageTransitionType.fade,
          childBuilder: (ctx) => CategoryScreen(),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      useLegacyColorScheme: true,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.widgets),
          label: 'Task',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'Category',
        ),
      ],
      onTap: _setScreen,
      type: BottomNavigationBarType.fixed,
      currentIndex: widget.selectedPageIndex,
      showUnselectedLabels: true,
      selectedItemColor: Theme.of(context).colorScheme.onSurface,
      unselectedItemColor: Theme.of(
        context,
      ).colorScheme.outlineVariant,
    );
  }
}
