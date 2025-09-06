class ChatMessage {
  final String id;
  final String orderId;
  final String senderId;
  final String senderUsername;
  final String message;
  final DateTime timestamp;
  final bool isFromSeller;

  ChatMessage({
    required this.id,
    required this.orderId,
    required this.senderId,
    required this.senderUsername,
    required this.message,
    required this.timestamp,
    required this.isFromSeller,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'senderId': senderId,
      'senderUsername': senderUsername,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isFromSeller': isFromSeller,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      orderId: json['orderId'],
      senderId: json['senderId'],
      senderUsername: json['senderUsername'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      isFromSeller: json['isFromSeller'],
    );
  }
}
