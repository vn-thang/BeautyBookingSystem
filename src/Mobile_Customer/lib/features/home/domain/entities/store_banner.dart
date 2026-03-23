class StoreBanner {
  final int id;

  final String imageUrl;
  final String? title;
  final String? description;

  final int sortOrder;
  final bool isActive;

  const StoreBanner({
    required this.id,
    required this.imageUrl,
    this.title,
    this.description,
    required this.sortOrder,
    required this.isActive,
  });
}
