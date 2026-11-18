import 'package:material_ui/material_ui.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({required this.imageUrl, this.height, super.key});

  final String imageUrl;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final image = Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const ColoredBox(
          color: Color(0xFFF1F0ED),
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return const ColoredBox(
          color: Color(0xFFF1F0ED),
          child: Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              size: 36,
              color: Color(0xFF98958F),
            ),
          ),
        );
      },
    );
    if (height == null) {
      return SizedBox.expand(child: image);
    }
    return SizedBox(width: double.infinity, height: height, child: image);
  }
}
