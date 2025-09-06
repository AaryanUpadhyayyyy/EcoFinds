import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/order_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../models/order.dart';
import '../models/chat_message.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (authProvider.currentUser == null) return;

    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      orderId: widget.order.id,
      senderId: authProvider.currentUser!.id,
      senderUsername: authProvider.currentUser!.username,
      message: _messageController.text.trim(),
      timestamp: DateTime.now(),
      isFromSeller: authProvider.currentUser!.id == widget.order.sellerId,
    );

    await orderProvider.addMessageToOrder(widget.order.id, message);
    _messageController.clear();

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _updateOrderStatus(OrderStatus newStatus) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    await orderProvider.updateOrderStatus(widget.order.id, newStatus);

    if (newStatus == OrderStatus.approved) {
      // Mark product as unavailable
      final product = productProvider.getProductById(widget.order.productId);
      if (product != null) {
        final updatedProduct = product.copyWith(
          isAvailable: false,
          updatedAt: DateTime.now(),
        );
        await productProvider.updateProduct(updatedProduct);
      }
    } else if (newStatus == OrderStatus.completed) {
      // Complete the purchase
      await cartProvider.completePurchase(widget.order);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order ${newStatus.name} successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${widget.order.id.substring(0, 8)}'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          final currentOrder = orderProvider.getOrderById(widget.order.id) ?? widget.order;
          
          return Column(
            children: [
              // Order Info Section
              Flexible(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.grey[50],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Info
                        Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: currentOrder.productImageUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: currentOrder.productImageUrl.startsWith('http')
                                      ? Image.network(
                                          currentOrder.productImageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Center(
                                              child: Icon(Icons.image_not_supported),
                                            );
                                          },
                                        )
                                      : Image.file(
                                          File(currentOrder.productImageUrl),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Center(
                                              child: Icon(Icons.image_not_supported),
                                            );
                                          },
                                        ),
                                )
                              : const Center(
                                  child: Icon(Icons.image),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentOrder.productTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\$${currentOrder.productPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[600],
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: currentOrder.statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  currentOrder.statusDisplayName,
                                  style: TextStyle(
                                    color: currentOrder.statusColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Order Details
                    Row(
                      children: [
                        Expanded(
                          child: _InfoRow(
                            label: 'Buyer',
                            value: currentOrder.buyerUsername,
                            icon: Icons.person,
                          ),
                        ),
                        Expanded(
                          child: _InfoRow(
                            label: 'Seller',
                            value: currentOrder.sellerUsername,
                            icon: Icons.store,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      label: 'Order Date',
                      value: _formatDate(currentOrder.createdAt),
                      icon: Icons.calendar_today,
                    ),
                  ],
                    ),
                  ),
                ),
              ),

              // Action Buttons (for sellers)
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  if (authProvider.currentUser?.id == currentOrder.sellerId &&
                      currentOrder.status == OrderStatus.pending) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _updateOrderStatus(OrderStatus.approved),
                              icon: const Icon(Icons.check),
                              label: const Text('Approve'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _updateOrderStatus(OrderStatus.rejected),
                              icon: const Icon(Icons.close),
                              label: const Text('Reject'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[600],
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (authProvider.currentUser?.id == currentOrder.sellerId &&
                      currentOrder.status == OrderStatus.approved) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _updateOrderStatus(OrderStatus.completed),
                          icon: const Icon(Icons.done_all),
                          label: const Text('Mark as Completed'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Chat Section
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Chat',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Messages
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: currentOrder.messages.isEmpty
                              ? Center(
                                  child: Text(
                                    'No messages yet. Start a conversation!',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(12),
                                  itemCount: currentOrder.messages.length,
                                  itemBuilder: (context, index) {
                                    final message = currentOrder.messages[index];
                                    return _MessageBubble(message: message);
                                  },
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Message Input
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: 'Type a message...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              maxLines: null,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FloatingActionButton.small(
                            onPressed: _sendMessage,
                            backgroundColor: Colors.green[600],
                            child: const Icon(Icons.send, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: message.isFromSeller
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: message.isFromSeller
                  ? Colors.green[600]
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.message,
                  style: TextStyle(
                    color: message.isFromSeller
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: message.isFromSeller
                        ? Colors.white70
                        : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
