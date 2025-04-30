class Product {
  final String id;
  final String name;
  final String? description;
  final double priceWithVat;
  final String? imageUrl;
  final String categoryId;
  final bool display;
  final String? hexColor;
  final List<String>? tags;
  final List<String>? notes;
  final String unit;
  final double vat;
  final String? imageUrlSubtitle;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.priceWithVat,
    this.imageUrl,
    required this.categoryId,
    required this.display,
    this.hexColor,
    this.tags,
    this.notes,
    required this.unit,
    required this.vat,
    this.imageUrlSubtitle,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      priceWithVat: _parseDouble(json['priceWithVat']),
      imageUrl: json['imageUrl']?.toString(),
      categoryId: json['_categoryId']?.toString() ?? '',
      display: json['display'] as bool? ?? false,
      hexColor: json['hexColor']?.toString(),
      tags: json['tags'] != null
          ? List<String>.from(json['tags'].map((x) => x?.toString() ?? ''))
          : null,
      notes: json['notes'] != null
          ? List<String>.from(json['notes'].map((x) => x?.toString() ?? ''))
          : null,
      unit: json['unit']?.toString() ?? '',
      vat: _parseDouble(json['vat']),
      imageUrlSubtitle: json['subtitle']
          ?.toString(), // It should stay as subtitle from the api side. but should be kept as imageUrlSubtitle in the model.
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }
}
