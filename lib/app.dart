import 'package:material_ui/material_ui.dart';

import 'core/network/api_client.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/products/data/repositories/product_repository.dart';
import 'features/products/presentation/controllers/products_controller.dart';
import 'features/products/presentation/pages/product_list_page.dart';

class DataCatalogApp extends StatefulWidget {
  const DataCatalogApp({
    super.key,
    this.repository,
    this.authRepository,
    this.startAuthenticated = false,
  });

  final ProductRepository? repository;
  final AuthRepository? authRepository;
  final bool startAuthenticated;

  @override
  State<DataCatalogApp> createState() => _DataCatalogAppState();
}

class _DataCatalogAppState extends State<DataCatalogApp> {
  late final ApiClient _apiClient;
  late final ProductsController _productsController;
  late final AuthRepository _authRepository;
  late bool _isAuthenticated;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _authRepository = widget.authRepository ?? ApiAuthRepository(_apiClient);
    final repository = widget.repository;
    if (repository == null) {
      _productsController = ProductsController(
        repository: ApiProductRepository(_apiClient),
      );
    } else {
      _productsController = ProductsController(repository: repository);
    }
    _isAuthenticated = widget.startAuthenticated;
  }

  @override
  void dispose() {
    _productsController.dispose();
    _apiClient.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF6750A4);
    return MaterialApp(
      title: 'Field & Form',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          surface: const Color(0xFFFAF9F6),
        ),
        scaffoldBackgroundColor: const Color(0xFFFAF9F6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAF9F6),
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFEAE8E2)),
          ),
        ),
      ),
      home: _isAuthenticated
          ? ProductListPage(controller: _productsController)
          : AuthPage(
              repository: _authRepository,
              onAuthenticated: () {
                setState(() => _isAuthenticated = true);
              },
            ),
    );
  }
}
