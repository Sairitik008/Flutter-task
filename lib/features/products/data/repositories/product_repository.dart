import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_client.dart';
import '../models/product.dart';

abstract interface class ProductRepository {
  Future<List<Product>> fetchProducts();
}

class ApiProductRepository implements ProductRepository {
  ApiProductRepository(this._apiClient);

  static final _productsUri = Uri.https('dummyjson.com', '/products', const {
    'limit': '100',
  });

  final ApiClient _apiClient;

  @override
  Future<List<Product>> fetchProducts() async {
    final response = await _apiClient.getJson(_productsUri);
    final products = response['products'];
    if (products is! List) {
      throw const AppException(
        'The product service returned an unexpected response.',
      );
    }

    try {
      return List<Product>.unmodifiable(
        products.map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('A product entry was not an object.');
          }
          return Product.fromJson(item);
        }),
      );
    } on FormatException catch (error) {
      throw AppException(
        'The product service returned incomplete product information.',
        cause: error,
      );
    }
  }
}
