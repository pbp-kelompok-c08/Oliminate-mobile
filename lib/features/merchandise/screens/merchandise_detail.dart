import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import '../models/merchandise_model.dart'; 

class MerchandiseDetailScreen extends StatefulWidget {
  // IMPORTANT: The API URL for adding an item to the cart
  // Assuming the base URL is the same as your merchandise_page.dart
  // and the endpoint is merchandise/cart/add/<uuid:merchandise_id>/
  final Merchandise merchandise;
  final String? userRole;

  const MerchandiseDetailScreen({super.key, required this.merchandise, required this.userRole});

  @override
  State<MerchandiseDetailScreen> createState() => _MerchandiseDetailScreenState();
}

class _MerchandiseDetailScreenState extends State<MerchandiseDetailScreen> {
  int _selectedQuantity = 1;
  bool _isAddingToCart = false;

  // Formatter for Indonesian Rupiah
  final NumberFormat _currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    // Ensure the default quantity is not higher than available stock
    if (widget.merchandise.stock < 1) {
      _selectedQuantity = 0;
    }
  }

  // API Call to add the item to the cart
  Future<void> _addToCart() async {
    if (widget.merchandise.stock == 0 || _selectedQuantity == 0) return;

    setState(() {
      _isAddingToCart = true;
    });

    // Construct the full URL for the cart_add_item endpoint
    final url = Uri.parse(
        'https://adjie-m-oliminate.pbp.cs.ui.ac.id/merchandise/cart/add/${widget.merchandise.id}/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // NOTE: For Django POST requests, you often need the CSRF token.
          // In a real Flutter app authenticating with Django sessions,
          // you would need to handle session cookies and CSRF tokens.
          // For simplicity in this single file example, we omit it, but be aware
          // that if Django's CSRF protection is active, this will fail.
          // You would typically send the quantity as form data or in the URL query.
        },
        body: json.encode({
          'quantity': _selectedQuantity,
        }),
      );

      if (response.statusCode == 302 || response.statusCode == 200) {
        // Django's redirect (302) or success (200)
        _showSnackbar('Berhasil menambahkan ${_selectedQuantity}x ${widget.merchandise.name} ke keranjang!', success: true);
        // In a real app, you might refresh the cart count here.
      } else {
        // Handle API error response
        _showSnackbar('Gagal menambahkan ke keranjang. Status: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackbar('Terjadi kesalahan jaringan: $e');
    } finally {
      setState(() {
        _isAddingToCart = false;
      });
    }
  }

  void _showSnackbar(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isStockAvailable = widget.merchandise.stock > 0;
    String formattedPrice = _currencyFormatter.format(widget.merchandise.price);
    final resolvedImageUrl = 'https://adjie-m-oliminate.pbp.cs.ui.ac.id/merchandise/proxy-image/?url=${Uri.encodeComponent(widget.merchandise.imageUrl.toString())}';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          widget.merchandise.name,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF113352),
        foregroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- Image ---
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: resolvedImageUrl.isNotEmpty
                    ? Image.network(
                        resolvedImageUrl,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            _imagePlaceholder(250),
                      )
                    : _imagePlaceholder(250),
              ),
            ),
            const SizedBox(height: 20),

            // --- Name and Price ---
            Text(
              widget.merchandise.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A), // Dark Blue
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formattedPrice,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF065F46), // Dark Green
              ),
            ),
            const Divider(height: 30),

            // --- Stock and Category ---
            _buildInfoRow(
              'Stock Tersedia',
              '${widget.merchandise.stock} unit',
              isStockAvailable ? Colors.green.shade700 : Colors.red.shade700,
            ),
            _buildInfoRow(
              'Kategori',
              widget.merchandise.category,
              Colors.grey.shade700,
            ),
            _buildInfoRow(
              'Penjual',
              widget.merchandise.organizerUsername,
              Colors.grey.shade700,
            ),
            const SizedBox(height: 16),

            // --- Description ---
            Text(
              'Deskripsi Produk',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.merchandise.description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),

            if (widget.userRole?.toLowerCase() == 'user')
              // --- Quantity Selector & Add to Cart Button ---
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  children: [
                    // Quantity Selector
                    if (isStockAvailable)
                      Row(
                        children: [
                          const Text('Jumlah:', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          _buildQuantityButton(Icons.remove, () {
                            if (_selectedQuantity > 1) {
                              setState(() {
                                _selectedQuantity--;
                              });
                            }
                          }),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              '$_selectedQuantity',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          _buildQuantityButton(Icons.add, () {
                            if (_selectedQuantity < widget.merchandise.stock) {
                              setState(() {
                                _selectedQuantity++;
                              });
                            }
                          }),
                        ],
                      ),
                    const Spacer(),

                    // Add to Cart Button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isStockAvailable && !_isAddingToCart
                            ? _addToCart
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isStockAvailable
                              ? const Color(0xFF1E3A8A)
                              : Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isAddingToCart
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isStockAvailable ? 'Tambah ke Keranjang' : 'Stok Habis',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Helper widget for information rows
  Widget _buildInfoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for quantity buttons
  Widget _buildQuantityButton(IconData icon, VoidCallback? onPressed) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: IconButton(
        icon: Icon(icon, size: 18, color: Colors.blueAccent),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        splashRadius: 20,
      ),
    );
  }

  // Placeholder widget for missing image
  Widget _imagePlaceholder(double height) {
    return Container(
      height: height,
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_not_supported,
          color: Colors.grey[400],
          size: 60,
        ),
      ),
    );
  }
}