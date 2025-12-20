// features/merchandise/models/order_summary_model.dart (Create this file)

class OrderItemSummary {
  final String name;
  final int quantity;
  final double subtotal; // Use double for currency
  final double price;

  OrderItemSummary({
    required this.name,
    required this.quantity,
    required this.subtotal,
    required this.price,
  });

  factory OrderItemSummary.fromJson(Map<String, dynamic> json) {
    return OrderItemSummary(
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      // Ensure the subtotal and price are parsed as doubles
      subtotal: (json['subtotal'] as num).toDouble(), 
      price: (json['price'] as num).toDouble(),
    );
  }
}

class OrderSummary {
  final String orderId;
  final DateTime createdAt;
  final double totalPrice;
  final List<OrderItemSummary> items;

  OrderSummary({
    required this.orderId,
    required this.createdAt,
    required this.totalPrice,
    required this.items,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    // Parse the list of items
    final itemsList = (json['items'] as List)
        .map((i) => OrderItemSummary.fromJson(i))
        .toList();

    return OrderSummary(
      orderId: json['order_id'] as String,
      // Parse ISO 8601 string into DateTime
      createdAt: DateTime.parse(json['created_at'] as String), 
      // Ensure total_price is parsed as a double
      totalPrice: (json['total_price'] as num).toDouble(), 
      items: itemsList,
    );
  }
}