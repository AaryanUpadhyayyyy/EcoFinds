class Purchase {
  final String id;
  final String productId;
  final String title;
  final double price;
  final String imageUrl;
  final String sellerUsername;
  final DateTime purchaseDate;
  final String status; // 'completed', 'pending', 'cancelled'

  Purchase({
    required this.id,
    required this.productId,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.sellerUsername,
    required this.purchaseDate,
    this.status = 'completed',
  });

  Purchase copyWith({
    String? id,
    String? productId,
    String? title,
    double? price,
    String? imageUrl,
    String? sellerUsername,
    DateTime? purchaseDate,
    String? status,
  }) {
    return Purchase(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      title: title ?? this.title,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      sellerUsername: sellerUsername ?? this.sellerUsername,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'title': title,
      'price': price,
      'imageUrl': imageUrl,
      'sellerUsername': sellerUsername,
      'purchaseDate': purchaseDate.toIso8601String(),
      'status': status,
    };
  }

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'],
      productId: json['productId'],
      title: json['title'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
      sellerUsername: json['sellerUsername'],
      purchaseDate: DateTime.parse(json['purchaseDate']),
      status: json['status'] ?? 'completed',
    );
  }
}
