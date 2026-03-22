import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_list_app/core/ui_helpers/main_alert_dialog.dart';
import 'package:task_list_app/features/category/presentation/bloc/category_bloc.dart';
import 'package:task_list_app/features/category/presentation/bloc/category_state.dart';
import 'package:task_list_app/features/category/presentation/controller/category_list_controller.dart';
import 'package:task_list_app/core/widgets/main_circular_progress.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  final controller = CategoryListController();

  @override
  void initState() {
    super.initState();
    controller.init(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CategoryBloc, CategoryState>(
      listener: (context, state) {
        if (state is CategoryErroState) {
          showMyDialog(context, 'Oppss...', state.erroMessage);
        }
      },

      builder: (context, state) {
        if (state is CategoryLoadingState) {
          return MainCircularProgress();
        } else if (state is CategoryLoadedListState) {
          final categoryList = state.categoryList;
          if (categoryList.isEmpty) {
            return Center(
              child: Text(
                "Looks like you don’t have any \ncategory yet. Let’s add one!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: state.categoryList.length,
              itemBuilder: (ctx, index) {
                final item = state.categoryList[index];
                return Dismissible(
                  key: ValueKey(item),
                  onDismissed: (direction) {
                    controller.deleteItem(item);
                  },
                  child: GestureDetector(
                    onTap: () {
                      controller.showUpdateBottomSheet(context, item);
                    },
                    child: SizedBox(
                      height: 100,
                      width: 200,
                      child: Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),

                        color: index % 2 == 0
                            ? Theme.of(
                                context,
                              ).colorScheme.surfaceBright
                            : Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(item.categoryName),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        } else {
          return Text('Oppss.. some erro here!');
        }
      },
    );
  }
}
