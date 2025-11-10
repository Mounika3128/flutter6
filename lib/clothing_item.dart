class ClothingItem {
  int? id;
  String name;
  String category;
  String brand;
  String size;

  ClothingItem({
    this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.size,
  });

  factory ClothingItem.fromMap(Map<String, dynamic> map) {
    return ClothingItem(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      brand: map['brand'],
      size: map['size'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'brand': brand,
      'size': size,
    };
  }
}
