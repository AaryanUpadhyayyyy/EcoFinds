enum ProductCategory {
  electronics,
  clothing,
  furniture,
  books,
  sports,
  beauty,
  home,
  toys,
  automotive,
  other,
}

extension ProductCategoryExtension on ProductCategory {
  String get categoryDisplayName {
    switch (this) {
      case ProductCategory.electronics:
        return 'Electronics';
      case ProductCategory.clothing:
        return 'Clothing';
      case ProductCategory.furniture:
        return 'Furniture';
      case ProductCategory.books:
        return 'Books';
      case ProductCategory.sports:
        return 'Sports';
      case ProductCategory.beauty:
        return 'Beauty';
      case ProductCategory.home:
        return 'Home';
      case ProductCategory.toys:
        return 'Toys';
      case ProductCategory.automotive:
        return 'Automotive';
      case ProductCategory.other:
        return 'Other';
    }
  }
}

class Product {
  final String id;
  final String title;
  final String description;
  final ProductCategory category;
  final double price;
  final String sellerId;
  final String sellerUsername;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isAvailable;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.sellerId,
    required this.sellerUsername,
    required this.imageUrls,
    required this.createdAt,
    required this.updatedAt,
    this.isAvailable = true,
  });

  Product copyWith({
    String? id,
    String? title,
    String? description,
    ProductCategory? category,
    double? price,
    String? sellerId,
    String? sellerUsername,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isAvailable,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      sellerId: sellerId ?? this.sellerId,
      sellerUsername: sellerUsername ?? this.sellerUsername,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'price': price,
      'sellerId': sellerId,
      'sellerUsername': sellerUsername,
      'imageUrls': imageUrls,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isAvailable': isAvailable,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: ProductCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ProductCategory.other,
      ),
      price: json['price'].toDouble(),
      sellerId: json['sellerId'],
      sellerUsername: json['sellerUsername'],
      imageUrls: List<String>.from(json['imageUrls']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  String get categoryDisplayName {
    switch (category) {
      case ProductCategory.electronics:
        return 'Electronics';
      case ProductCategory.clothing:
        return 'Clothing';
      case ProductCategory.furniture:
        return 'Furniture';
      case ProductCategory.books:
        return 'Books';
      case ProductCategory.sports:
        return 'Sports';
      case ProductCategory.beauty:
        return 'Beauty';
      case ProductCategory.home:
        return 'Home';
      case ProductCategory.toys:
        return 'Toys';
      case ProductCategory.automotive:
        return 'Automotive';
      case ProductCategory.other:
        return 'Other';
    }
  }
}
