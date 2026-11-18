import 'package:flutter/foundation.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/models/product.dart';
import '../../data/repositories/product_repository.dart';

enum ProductsLoadState { initial, loading, success, error }

class ProductsController extends ChangeNotifier {
  ProductsController({required this.repository});

  final ProductRepository repository;
  List<Product> _products = const [];
  String _searchQuery = '';
  String? _errorMessage;
  ProductsLoadState _state = ProductsLoadState.initial;
  int _requestId = 0;
  bool _isDisposed = false;

  List<Product> get products => _products;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;
  ProductsLoadState get state => _state;

  List<Product> get visibleProducts {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _products;

    return _products
        .where((product) {
          return product.title.toLowerCase().contains(query) ||
              product.category.toLowerCase().contains(query) ||
              product.tags.any((tag) => tag.toLowerCase().contains(query));
        })
        .toList(growable: false);
  }

  Future<void> loadProducts() async {
    if (_isDisposed) return;
    final requestId = ++_requestId;
    _state = ProductsLoadState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final products = await repository.fetchProducts();
      if (_isDisposed || requestId != _requestId) return;
      _products = List<Product>.unmodifiable(products);
      _state = ProductsLoadState.success;
    } on AppException catch (error) {
      if (_isDisposed || requestId != _requestId) return;
      _errorMessage = error.message;
      _state = ProductsLoadState.error;
    }

    if (!_isDisposed && requestId == _requestId) {
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    if (_isDisposed || query == _searchQuery) return;
    _searchQuery = query;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _requestId++;
    super.dispose();
  }
}
