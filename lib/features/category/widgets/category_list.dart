import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_list_app/core/ui_helpers/main_alert_dialog.dart';
import 'package:task_list_app/features/category/bloc/category_bloc.dart';
import 'package:task_list_app/features/category/bloc/category_event.dart';
import 'package:task_list_app/features/category/bloc/category_state.dart';
import 'package:task_list_app/features/category/model/category_model.dart';
import 'package:task_list_app/core/widgets/main_circular_progress.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  late final CategoryBloc categoryBloc;
  String _inputNewCategoryName = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    categoryBloc = context.read<CategoryBloc>();
    categoryBloc.add(CategoryLoadAllCategoriesEvent());
  }

  void _deleteItem(CategoryModel item) async {
    categoryBloc.add(CategoryDeleteCategoryEvent(item.id));
    await Future.delayed(Duration(milliseconds: 300));
    categoryBloc.add(CategoryLoadAllCategoriesEvent());
  }

  void _uploadItem(CategoryModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
              child: Form(
                key: _formKey, 
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: Text(
                            item.categoryName,
                            style: Theme.of(
                              context,
                            ).textTheme.titleLarge,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.close, size: 16),
                            onPressed: () {
                              Navigator.of(
                                context,
                              ).pop();
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    TextFormField(
                      initialValue: item.categoryName,
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                      ),
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter at least one letter.';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _inputNewCategoryName = value;
                      },
                    ),
                    const SizedBox(height: 80),
                    ElevatedButton(
                      onPressed: () {
                        final isValidForm = _formKey.currentState!
                            .validate();
                        if (!isValidForm) {
                          return;
                        } else {
                          categoryBloc.add(
                            CategoryUpdateCategoryEvent(
                              item.id,
                              _inputNewCategoryName,
                            ),
                          );
                          categoryBloc.add(
                            CategoryLoadAllCategoriesEvent(),
                          );
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Update'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _deleteItem(item);
                        Navigator.of(context).pop();
                      },
                      child: const Text('Delete'),
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
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
                    _deleteItem(item);
                  },
                  child: GestureDetector(
                    onTap: () {
                      _uploadItem(item);
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
