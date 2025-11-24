class Merchandise {
  final String id;
  final String name;
  final String category;
  final int price;
  final int stock;
  final String? imageUrl;
  final String organizerUsername;

  Merchandise({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.imageUrl,
    required this.organizerUsername,
  });

  // Factory constructor to create a Merchandise object from JSON (Map)
  factory Merchandise.fromJson(Map<String, dynamic> json) {
    return Merchandise(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      price: json['price'] as int,
      stock: json['stock'] as int,
      imageUrl: json['image_url'] as String?,
      organizerUsername: json['organizer_username'] as String,
    );
  }
}

class CategoryChoice {
  final String value;
  final String label;

  CategoryChoice({required this.value, required this.label});

  // Factory constructor to create a CategoryChoice object from the tuple-like list received from Django
  factory CategoryChoice.fromList(List<dynamic> list) {
    return CategoryChoice(
      value: list[0] as String,
      label: list[1] as String,
    );
  }
}