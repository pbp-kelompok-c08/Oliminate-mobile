import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:oliminate_mobile/features/user-profile/auth_repository.dart';
import 'dart:convert';
import '../models/cart_item_model.dart'; // Ensure this path is correct

class CartPage extends StatefulWidget {
  final String baseUrl = 'http://localhost:8000'; // Match your other pages
  final String apiEndpoint = '/merchandise/api/cart/';
  final String updateEndpoint = '/merchandise/cart/item/'; // Base for item updates
  final String checkoutEndpoint = '/merchandise/cart/checkout/';

  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Cart? cart;
  bool isLoading = true;
  bool isCheckingOut = false;

  @override
  void initState() {
    super.initState();
    fetchCart();
  }
  
  // --- API Methods ---

  Future<void> fetchCart() async {
    setState(() { isLoading = true; });
    try {
      final uri = widget.apiEndpoint;
      
      // final response = await http.get(
      //   uri,
      // );

      final response = await AuthRepository.instance.client.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          cart = (data['items'] != null && data['items'].isNotEmpty) ? Cart.fromJson(data) : null;
          isLoading = false;
        });
      } else {
        String message = response.statusCode == 302 
            ? 'Gagal: Sesi login tidak valid atau kadaluarsa.' 
            : 'Failed to load cart: ${response.statusCode}';
        
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        setState(() { isLoading = false; });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Network error: $e')));
      setState(() { isLoading = false; });
    }
  }

  Future<void> _updateCartItemQuantity(String itemId, int newQuantity) async {
    if (newQuantity < 1) {
      return _removeItemFromCart(itemId);
    }
    
    // URL: /merchandise/cart/item/<uuid:item_id>/update/
    final url = Uri.parse('${widget.updateEndpoint}$itemId/update/').toString();
    
    try {
      // final response = await http.post(
      //   url,
      //   headers: {
      //     'Content-Type': 'application/x-www-form-urlencoded', // Django expects form data for request.POST
      //   },
      //   // Send data as URL-encoded form data
      //   body: 'quantity=$newQuantity',
      // );

      final response = await AuthRepository.instance.client.postForm(url, body: {});

      if (response.statusCode == 302 || response.statusCode == 200) {
        // Success means Django redirected back, refresh the cart
        await fetchCart(); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quantity updated to $newQuantity.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update quantity. Status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error during update: $e')),
      );
    }
  }

  Future<void> _removeItemFromCart(String itemId) async {
    // URL: /merchandise/cart/item/<uuid:item_id>/remove/
    final url = Uri.parse('${widget.baseUrl}${widget.updateEndpoint}$itemId/remove/');

    try {
      final response = await http.post(
        url,
        body: {}, // Empty body for simple POST removal
      );

      if (response.statusCode == 302 || response.statusCode == 200) {
        // Success means Django redirected back, refresh the cart
        await fetchCart(); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item removed from cart.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove item. Status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error during removal: $e')),
      );
    }
  }


  Future<void> _checkoutCart() async {
    if (cart == null || cart!.items.isEmpty) return;

    setState(() { isCheckingOut = true; });

    try {
      final uri = Uri.parse('${widget.baseUrl}${widget.checkoutEndpoint}');
      
      final response = await http.post(
        uri
      );

      if (response.statusCode == 302 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Checkout berhasil! Redirecting to payment...')),
        );
        await fetchCart(); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout gagal. Status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan jaringan saat checkout: $e')),
      );
    } finally {
      setState(() { isCheckingOut = false; });
    }
  }
  // -----------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cart == null || cart!.items.isEmpty
              ? const Center(child: Text('Keranjangmu Kosong'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cart!.items.length,
                        itemBuilder: (context, index) {
                          // Pass the update/remove functions to the item widget
                          return _buildCartItem(
                            cart!.items[index], 
                            _updateCartItemQuantity, 
                            _removeItemFromCart,
                          );
                        },
                      ),
                    ),
                    _buildCartSummary(),
                  ],
                ),
    );
  }

  // --- Cart Item Widget (Now accepts callbacks) ---
  Widget _buildCartItem(
    CartItem item, 
    Function(String, int) onUpdateQuantity, 
    Function(String) onRemoveItem,
  ) {
    // The total price for this specific item (Qty * Price)
    final itemTotalPrice = item.quantity * item.merchandisePrice;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Placeholder
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.merchandiseName, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Harga Satuan: Rp ${item.merchandisePrice}', 
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      // Item Subtotal
                      Text(
                        'Total: Rp $itemTotalPrice',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // --- Update and Delete Controls ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Quantity Controls
                Row(
                  children: [
                    // Decrement Button
                    InkWell(
                      onTap: () => onUpdateQuantity(item.id, item.quantity - 1),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(Icons.remove, size: 20, color: item.quantity > 1 ? Colors.blue : Colors.grey),
                      ),
                    ),
                    
                    // Quantity Display
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                    // Increment Button
                    InkWell(
                      onTap: () => onUpdateQuantity(item.id, item.quantity + 1),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.add, size: 20, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                
                // Delete Button
                TextButton.icon(
                  onPressed: () => onRemoveItem(item.id),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Cart Summary Widget ---
  Widget _buildCartSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12, offset: const Offset(0, -2))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                'Rp ${cart?.totalPrice ?? 0}', 
                style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12), 
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: cart != null && cart!.items.isNotEmpty && !isCheckingOut
                  ? _checkoutCart
                  : null,
              child: isCheckingOut
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Checkout', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}