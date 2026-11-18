import 'package:data_catalog/features/products/data/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses product fields and optional tags', () {
    final product = Product.fromJson({
      'id': 7,
      'title': 'Linen Shirt',
      'description': 'Lightweight linen shirt.',
      'category': 'clothing',
      'price': 34.5,
      'rating': 4.3,
      'stock': 18,
      'thumbnail': 'https://example.com/shirt.jpg',
      'tags': ['linen', 'summer'],
      'discountPercentage': 12.5,
      'brand': 'Northwind',
    });

    expect(product.id, 7);
    expect(product.title, 'Linen Shirt');
    expect(product.price, 34.5);
    expect(product.tags, ['linen', 'summer']);
    expect(product.brand, 'Northwind');
  });

  test('rejects invalid required fields', () {
    expect(
      () => Product.fromJson({
        'id': 'not-an-id',
        'title': 'Linen Shirt',
        'description': 'Lightweight linen shirt.',
        'category': 'clothing',
        'price': 34.5,
        'thumbnail': 'https://example.com/shirt.jpg',
      }),
      throwsA(isA<FormatException>()),
    );
  });
}
