class CartItem {
  final String id;
  final String merchandiseId;
  final String merchandiseName;
  final int merchandisePrice;
  final String? merchandiseImage;
  final int quantity;
  final int subtotal;
  final int stock;

  CartItem({
    required this.id,
    required this.merchandiseId,
    required this.merchandiseName,
    required this.merchandisePrice,
    this.merchandiseImage,
    required this.quantity,
    required this.subtotal,
    required this.stock,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'].toString(),
      merchandiseId: json['merchandise_id'].toString(),
      merchandiseName: json['merchandise_name'].toString(),
      merchandisePrice: json['merchandise_price'] as int,
      merchandiseImage: json['merchandise_image']?.toString(),
      quantity: json['quantity'] as int,
      subtotal: json['subtotal'] as int,
      stock: json['stock'] as int,
    );
  }
}

class Cart {
  final String id;
  final int totalPrice;
  final List<CartItem> items;

  Cart({
    required this.id,
    required this.totalPrice,
    required this.items,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List;
    List<CartItem> itemsList = list.map((i) => CartItem.fromJson(i)).toList();

    return Cart(
      id: json['cart_id'].toString(),
      totalPrice: json['total_price'] as int,
      items: itemsList,
    );
  }
}