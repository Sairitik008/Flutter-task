import 'package:data_catalog/app.dart';
import 'package:data_catalog/core/errors/app_exception.dart';
import 'package:data_catalog/features/products/data/models/product.dart';
import 'package:data_catalog/features/products/data/repositories/product_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('loads products, filters results, and opens product details', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      DataCatalogApp(
        repository: _FakeProductRepository(products: [_product]),
        startAuthenticated: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Orchard Tote'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'accessories');
    await tester.pump();
    expect(find.text('Orchard Tote'), findsOneWidget);

    await tester.tap(find.text('Orchard Tote'));
    await tester.pumpAndSettle();
    expect(find.text('About this item'), findsOneWidget);
    expect(find.text('A durable everyday carry bag.'), findsOneWidget);
  });

  testWidgets('shows an error and recovers when the user retries', (
    tester,
  ) async {
    final repository = _FakeProductRepository(
      products: [_product],
      failure: const AppException('No internet connection.'),
    );
    await tester.pumpWidget(
      DataCatalogApp(repository: repository, startAuthenticated: true),
    );
    await tester.pumpAndSettle();

    expect(find.text("Couldn't load products"), findsOneWidget);
    expect(find.text('No internet connection.'), findsOneWidget);

    repository.failure = null;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Orchard Tote'), findsOneWidget);
  });
}

const _product = Product(
  id: 1,
  title: 'Orchard Tote',
  description: 'A durable everyday carry bag.',
  category: 'Accessories',
  price: 42.5,
  rating: 4.7,
  stock: 12,
  thumbnail: 'https://example.com/product.jpg',
  tags: ['travel', 'canvas'],
  discountPercentage: 10,
  brand: 'Field Co.',
);

class _FakeProductRepository implements ProductRepository {
  _FakeProductRepository({required this.products, this.failure});

  final List<Product> products;
  AppException? failure;

  @override
  Future<List<Product>> fetchProducts() async {
    final currentFailure = failure;
    if (currentFailure != null) throw currentFailure;
    return products;
  }
}
