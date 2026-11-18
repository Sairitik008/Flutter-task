class Product {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.rating,
    required this.stock,
    required this.thumbnail,
    required this.tags,
    required this.discountPercentage,
    this.brand,
  });

  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double rating;
  final int stock;
  final String thumbnail;
  final List<String> tags;
  final double discountPercentage;
  final String? brand;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _requiredInt(json, 'id'),
      title: _requiredString(json, 'title'),
      description: _requiredString(json, 'description'),
      category: _requiredString(json, 'category'),
      price: _requiredDouble(json, 'price'),
      rating: _optionalDouble(json, 'rating'),
      stock: _optionalInt(json, 'stock'),
      thumbnail: _requiredString(json, 'thumbnail'),
      tags: _optionalStringList(json, 'tags'),
      discountPercentage: _optionalDouble(json, 'discountPercentage'),
      brand: _optionalString(json, 'brand'),
    );
  }

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Product field "$key" must be a non-empty string.');
    }
    return value;
  }

  static String? _optionalString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is! String) {
      throw FormatException('Product field "$key" must be a string.');
    }
    return value;
  }

  static int _requiredInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! int) {
      throw FormatException('Product field "$key" must be an integer.');
    }
    return value;
  }

  static int _optionalInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return 0;
    if (value is! num || value % 1 != 0) {
      throw FormatException('Product field "$key" must be an integer.');
    }
    return value.toInt();
  }

  static double _requiredDouble(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! num) {
      throw FormatException('Product field "$key" must be a number.');
    }
    return value.toDouble();
  }

  static double _optionalDouble(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return 0;
    if (value is! num) {
      throw FormatException('Product field "$key" must be a number.');
    }
    return value.toDouble();
  }

  static List<String> _optionalStringList(
    Map<String, dynamic> json,
    String key,
  ) {
    final value = json[key];
    if (value == null) return const [];
    if (value is! List || value.any((item) => item is! String)) {
      throw FormatException('Product field "$key" must be a list of strings.');
    }
    return List<String>.unmodifiable(value.cast<String>());
  }
}
