import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_list_app/features/category/presentation/bloc/category_bloc.dart';
import 'package:task_list_app/features/category/presentation/bloc/category_event.dart';

class CategoryController {

  String _inputCategoryName = '';
  late final CategoryBloc categoryBloc;
  final _formKey = GlobalKey<FormState>();

  CategoryController();

  void init(BuildContext context) {
    categoryBloc = context.read<CategoryBloc>();
  }

  void onPressedCreate(BuildContext context) {
    
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
                            'New Category',
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
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    TextFormField(
                      initialValue: _inputCategoryName,
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
                        _inputCategoryName = value;
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
                            CategoryCreateNewCategoryEvent(
                              _inputCategoryName,
                            ),
                          );

                          categoryBloc.add(
                            CategoryLoadAllCategoriesEvent(),
                          );

                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Save'),
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
