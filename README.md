# Field & Form

A Flutter product catalog that loads products from the public DummyJSON API.
Browse the catalog, search by title, category, or tag, and open a product to
view its details.

## Run

```shell
flutter pub get
flutter run
```

The app supports Android, web, and Windows. It needs an internet connection to
load product data and images.

## Architecture

```text
lib/
  app.dart
  core/
    errors/
    network/
  features/
    products/
      data/
        models/
        repositories/
      presentation/
        controllers/
        pages/
        widgets/
```

- `ApiClient` handles HTTP, timeouts, response status, and JSON validation.
- `ApiProductRepository` maps API responses to validated `Product` models.
- `ProductsController` owns loading/error/success state and search filtering.
- Presentation widgets render loading, retryable error, empty, list, and detail
  states.

Run the automated checks with:

```shell
flutter analyze
flutter test
```
