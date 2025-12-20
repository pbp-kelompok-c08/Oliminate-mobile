import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:oliminate_mobile/features/ticketing/models.dart';
import 'package:oliminate_mobile/features/ticketing/ticket_payment.dart';

const Color _primaryDark = Color(0xFF113352);
const Color _primaryBlue = Color(0xFF3293EC);
const Color _primaryRed = Color(0xFFEA3C43);
const Color _pacilRedDarker2 = Color(0xFF521517);
const Color _bgColor = Color(0xFFF5F5F5);
const Color _lightBlue = Color(0xFFE5F1FB);

String? getFullImageUrl(String? imageUrl, String baseUrl) {
  if (imageUrl == null || imageUrl.isEmpty) return null;
  if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
    return imageUrl;
  }
  return '$baseUrl$imageUrl';
}

class TicketFormPage extends StatefulWidget {
  final Schedule schedule;
  final String username;
  final String baseUrl;

  const TicketFormPage({super.key, required this.schedule, required this.username, required this.baseUrl});

  @override
  State<TicketFormPage> createState() => _TicketFormPageState();
}

class _TicketFormPageState extends State<TicketFormPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final _formKey = GlobalKey<FormState>();
  String _paymentMethod = 'ewallet';
  bool _isLoading = false;

  final Map<String, IconData> _paymentIcons = {
    'ewallet': Icons.account_balance_wallet_rounded,
    'transfer': Icons.account_balance_rounded,
    'credit': Icons.credit_card_rounded,
  };

  final Map<String, String> _paymentMethods = {
    'ewallet': 'E-Wallet (GoPay, OVO, Dana)',
    'transfer': 'Transfer Bank (BCA, Mandiri, BNI)',
    'credit': 'Kartu Kredit',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${widget.baseUrl}/ticketing/buy-flutter/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'schedule_id': widget.schedule.id,
          'payment_method': _paymentMethod,
          'username': widget.username,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
         if (mounted) {
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(
              builder: (context) => TicketPaymentPage(
                ticketId: data['ticket_id'],
                baseUrl: widget.baseUrl,
              )
            )
          );
        }
      } else {
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
               content: Text(data['message'] ?? "Gagal membeli tiket"),
               backgroundColor: _primaryRed,
                behavior: SnackBarBehavior.floating,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
             ),
           );
         }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: _primaryRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullImageUrl = getFullImageUrl(widget.schedule.imageUrl, widget.baseUrl);

    return Scaffold(
      backgroundColor: _bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Beli Tiket", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: Stack(
                children: [
                   if (fullImageUrl != null)
                    Image.network(
                      fullImageUrl,
                      width: double.infinity,
                      height: 280,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, __) => Container(
                        width: double.infinity,
                        height: 280,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [_primaryDark, _pacilRedDarker2, _primaryRed],
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 280,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [_primaryDark, _pacilRedDarker2, _primaryRed],
                        ),
                      ),
                    ),
                  Container(
                    width: double.infinity,
                    height: 280,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _primaryDark.withOpacity(0.7),
                          _pacilRedDarker2.withOpacity(0.6),
                          _pacilRedDarker2.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 32,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                          ),
                          child: Text(
                            widget.schedule.category.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.schedule.eventName,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Text(widget.schedule.date, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                            const SizedBox(width: 20),
                            const Icon(Icons.access_time_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Text(widget.schedule.time.substring(0, 5), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(widget.schedule.location, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Pilih Metode Pembayaran", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _primaryDark, letterSpacing: -0.3)),
                        const SizedBox(height: 20),
                        
                        ..._paymentMethods.entries.map((entry) {
                          final isSelected = _paymentMethod == entry.key;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            child: InkWell(
                              onTap: () => setState(() => _paymentMethod = entry.key),
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? _primaryBlue : Colors.transparent,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isSelected ? _primaryBlue.withOpacity(0.15) : Colors.black.withOpacity(0.04),
                                      blurRadius: isSelected ? 12 : 6,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isSelected ? _primaryBlue.withOpacity(0.12) : const Color(0xFFF5F5F5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(_paymentIcons[entry.key], color: isSelected ? _primaryBlue : const Color(0xFF9E9E9E), size: 24),
                                    ),
                                    const SizedBox(width: 16),
                                    Text(entry.value, style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                      color: isSelected ? _primaryBlue : const Color(0xFF3D3D3D),
                                    )),
                                    const Spacer(),
                                    if (isSelected)
                                      Icon(Icons.check_circle_rounded, color: _primaryBlue, size: 24)
                                    else 
                                      const Icon(Icons.circle_outlined, color: Color(0xFFE0E0E0), size: 24),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),

                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryBlue,
                              disabledBackgroundColor: const Color(0xFFBDBDBD),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                              shadowColor: _primaryBlue.withOpacity(0.4),
                            ),
                            child: _isLoading 
                              ? const SizedBox(height: 28, width: 28, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                              : const Text("Lanjut ke Pembayaran", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
