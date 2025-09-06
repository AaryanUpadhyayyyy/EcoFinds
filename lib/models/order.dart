import 'package:flutter/material.dart';
import 'chat_message.dart';

enum OrderStatus {
  pending,
  approved,
  rejected,
  completed,
  cancelled,
}

class Order {
  final String id;
  final String productId;
  final String productTitle;
  final String productImageUrl;
  final double productPrice;
  final String buyerId;
  final String buyerUsername;
  final String sellerId;
  final String sellerUsername;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;
  final List<ChatMessage> messages;

  Order({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.productImageUrl,
    required this.productPrice,
    required this.buyerId,
    required this.buyerUsername,
    required this.sellerId,
    required this.sellerUsername,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.messages = const [],
  });

  Order copyWith({
    String? id,
    String? productId,
    String? productTitle,
    String? productImageUrl,
    double? productPrice,
    String? buyerId,
    String? buyerUsername,
    String? sellerId,
    String? sellerUsername,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    List<ChatMessage>? messages,
  }) {
    return Order(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productTitle: productTitle ?? this.productTitle,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      productPrice: productPrice ?? this.productPrice,
      buyerId: buyerId ?? this.buyerId,
      buyerUsername: buyerUsername ?? this.buyerUsername,
      sellerId: sellerId ?? this.sellerId,
      sellerUsername: sellerUsername ?? this.sellerUsername,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productTitle': productTitle,
      'productImageUrl': productImageUrl,
      'productPrice': productPrice,
      'buyerId': buyerId,
      'buyerUsername': buyerUsername,
      'sellerId': sellerId,
      'sellerUsername': sellerUsername,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'notes': notes,
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      productId: json['productId'],
      productTitle: json['productTitle'],
      productImageUrl: json['productImageUrl'],
      productPrice: json['productPrice'].toDouble(),
      buyerId: json['buyerId'],
      buyerUsername: json['buyerUsername'],
      sellerId: json['sellerId'],
      sellerUsername: json['sellerUsername'],
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      notes: json['notes'],
      messages: (json['messages'] as List<dynamic>?)
          ?.map((m) => ChatMessage.fromJson(m))
          .toList() ?? [],
    );
  }

  String get statusDisplayName {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending Approval';
      case OrderStatus.approved:
        return 'Approved';
      case OrderStatus.rejected:
        return 'Rejected';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.approved:
        return Colors.green;
      case OrderStatus.rejected:
        return Colors.red;
      case OrderStatus.completed:
        return Colors.blue;
      case OrderStatus.cancelled:
        return Colors.grey;
    }
  }
}

