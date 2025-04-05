class MenuItem {
  final String id;
  final String name;
  final String category;
  final int cookTimeMinutes;
  final double price;
  final String imageUrl;
  final int gram;
  final double rating;

  static const String defaultImageUrl = 'https://i.pinimg.com/736x/72/d9/af/72d9af964d384fc2a16fd087c1062a7c.jpg';

  MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.cookTimeMinutes,
    required this.price,
    required this.imageUrl,
    required this.gram,
    required this.rating,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    final String? imageUrl = json['imageUrl'] as String?;
    return MenuItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      cookTimeMinutes: json['cookTimeMinutes'] as int,
      price: (json['price'] as num).toDouble(),
      imageUrl: imageUrl?.isNotEmpty == true ? imageUrl! : defaultImageUrl,
      gram: json['gram'] as int,
      rating: (json['rating'] as num).toDouble(),
    );
  }
} 