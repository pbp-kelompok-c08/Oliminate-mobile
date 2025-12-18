// features/merchandise/screens/cart_paid_page.dart (Rename/Update your success page)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting date and currency
import '../models/order_summary_model.dart'; // <--- IMPORT NEW MODEL

// Renamed from OrderSuccessPage to CartPaidPage for consistency with your intent
class CartPaidPage extends StatelessWidget {
  final OrderSummary orderSummary;

  const CartPaidPage({super.key, required this.orderSummary});

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }
  
  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy, HH:mm').format(date);
  }
  
  String _getQrCodeUrl(String data) {
    // Your specified QR Code API
    return 'https://api.qrserver.com/v1/create-qr-code/?data=$data&size=150x150';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran Berhasil'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
                  const SizedBox(height: 16),
                  const Text(
                    'Terima Kasih - Pembayaran Berhasil!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Pesananmu telah diproses.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),

                  // --- Order Summary ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Order ID: ${orderSummary.orderId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Date: ${_formatDate(orderSummary.createdAt)}', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      Text(
                        _formatCurrency(orderSummary.totalPrice),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),

                  // --- QR Code ---
                  const SizedBox(height: 20),
                  const Text('QR Code', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Image.network(
                    _getQrCodeUrl(orderSummary.orderId),
                    width: 150,
                    height: 150,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(
                        width: 150, height: 150, child: Icon(Icons.qr_code_2_rounded, size: 100, color: Colors.grey)),
                  ),
                  
                  // --- Items List ---
                  const SizedBox(height: 24),
                  const Text('Barang yang dipesan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const Divider(),
                  
                  ...orderSummary.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${item.name} x ${item.quantity}', style: const TextStyle(fontSize: 14)),
                        Text(_formatCurrency(item.subtotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )),
                  const Divider(),
                  
                  const SizedBox(height: 32),
                  
                  // --- Action Button ---
                  ElevatedButton(
                    onPressed: () {
                      // Navigate back to the Merchandise List Page and clear the cart/order success screen
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Lanjut Belanja', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}