class CartItem {
  final String productId;
  final String title;
  final double price;
  final String imageUrl;
  final String sellerUsername;
  final DateTime addedAt;

  CartItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.sellerUsername,
    required this.addedAt,
  });

  CartItem copyWith({
    String? productId,
    String? title,
    double? price,
    String? imageUrl,
    String? sellerUsername,
    DateTime? addedAt,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      title: title ?? this.title,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      sellerUsername: sellerUsername ?? this.sellerUsername,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'imageUrl': imageUrl,
      'sellerUsername': sellerUsername,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'],
      title: json['title'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
      sellerUsername: json['sellerUsername'],
      addedAt: DateTime.parse(json['addedAt']),
    );
  }
}
