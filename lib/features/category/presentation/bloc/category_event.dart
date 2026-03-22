abstract class CategoryEvent {}

class CategoryCreateNewCategoryEvent extends CategoryEvent {
  final String categoryName;
  CategoryCreateNewCategoryEvent(this.categoryName);
}

class CategoryUpdateCategoryEvent extends CategoryEvent {
  final String categoryId;
  final String categoryNewContent;
  CategoryUpdateCategoryEvent(
    this.categoryId,
    this.categoryNewContent,
  );
}

class CategoryDeleteCategoryEvent extends CategoryEvent {
  final String categoryId;
  CategoryDeleteCategoryEvent(this.categoryId);
}

class CategoryLoadAllCategoriesEvent extends CategoryEvent {}
