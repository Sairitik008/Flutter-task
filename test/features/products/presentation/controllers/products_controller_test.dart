import 'package:data_catalog/core/errors/app_exception.dart';
import 'package:data_catalog/features/products/data/models/product.dart';
import 'package:data_catalog/features/products/data/repositories/product_repository.dart';
import 'package:data_catalog/features/products/presentation/controllers/products_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'filters by title, category, and tags without changing source data',
    () async {
      final controller = ProductsController(
        repository: _FakeProductRepository([_tote, _mug]),
      );
      await controller.loadProducts();

      controller.setSearchQuery('travel');
      expect(controller.visibleProducts, [_tote]);

      controller.setSearchQuery('home');
      expect(controller.visibleProducts, [_mug]);
      expect(controller.products, [_tote, _mug]);
      controller.dispose();
    },
  );

  test('exposes load errors and can recover after a retry', () async {
    final repository = _FakeProductRepository([
      _tote,
    ], failure: const AppException('Service unavailable.'));
    final controller = ProductsController(repository: repository);

    await controller.loadProducts();
    expect(controller.state, ProductsLoadState.error);
    expect(controller.errorMessage, 'Service unavailable.');

    repository.failure = null;
    await controller.loadProducts();
    expect(controller.state, ProductsLoadState.success);
    expect(controller.products, [_tote]);
    controller.dispose();
  });
}

const _tote = Product(
  id: 1,
  title: 'Orchard Tote',
  description: 'A durable everyday carry bag.',
  category: 'Accessories',
  price: 42.5,
  rating: 4.7,
  stock: 12,
  thumbnail: 'https://example.com/tote.jpg',
  tags: ['travel', 'canvas'],
  discountPercentage: 0,
);

const _mug = Product(
  id: 2,
  title: 'Stoneware Cup',
  description: 'A handmade cup.',
  category: 'Home',
  price: 18,
  rating: 4.5,
  stock: 20,
  thumbnail: 'https://example.com/cup.jpg',
  tags: ['ceramic'],
  discountPercentage: 0,
);

class _FakeProductRepository implements ProductRepository {
  _FakeProductRepository(this.products, {this.failure});

  final List<Product> products;
  AppException? failure;

  @override
  Future<List<Product>> fetchProducts() async {
    final currentFailure = failure;
    if (currentFailure != null) throw currentFailure;
    return products;
  }
}
