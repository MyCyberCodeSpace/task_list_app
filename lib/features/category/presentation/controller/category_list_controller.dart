import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_list_app/features/category/domain/model/category_model.dart';
import 'package:task_list_app/features/category/presentation/bloc/category_bloc.dart';
import 'package:task_list_app/features/category/presentation/bloc/category_event.dart';

class CategoryListController {
  late final CategoryBloc categoryBloc;
  String _inputNewCategoryName = '';
  final formKey = GlobalKey<FormState>();

  CategoryListController();

  void init(BuildContext context) {
    categoryBloc = context.read<CategoryBloc>();
    categoryBloc.add(CategoryLoadAllCategoriesEvent());
  }

  void deleteItem(CategoryModel item) async {
    categoryBloc.add(CategoryDeleteCategoryEvent(item.id));
    await Future.delayed(Duration(milliseconds: 300));
    categoryBloc.add(CategoryLoadAllCategoriesEvent());
  }

  void showUpdateBottomSheet(BuildContext context, CategoryModel item) {
    _inputNewCategoryName = '';

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
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: Text(
                            item.categoryName,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.close, size: 16),
                            onPressed: () {
                              Navigator.of(context).pop();
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
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
                        final isValidForm = formKey.currentState!.validate();
                        if (!isValidForm) {
                          return;
                        } else {
                          categoryBloc.add(
                            CategoryUpdateCategoryEvent(
                              item.id,
                              _inputNewCategoryName,
                            ),
                          );
                          categoryBloc.add(CategoryLoadAllCategoriesEvent());
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Update'),
                    ),

                    ElevatedButton(
                      onPressed: () {
                        deleteItem(item);
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
}
