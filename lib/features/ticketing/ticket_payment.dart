import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:oliminate_mobile/features/ticketing/ticket_detail.dart';

const Color _primaryDark = Color(0xFF113352);
const Color _primaryBlue = Color(0xFF3293EC);
const Color _primaryRed = Color(0xFFEA3C43);
const Color _successGreen = Color(0xFF10B981);
const Color _bgColor = Color(0xFFF5F5F5);
const Color _pacilRedDarker2 = Color(0xFF521517);

class TicketPaymentPage extends StatefulWidget {
  final int ticketId;
  final String baseUrl;

  const TicketPaymentPage({super.key, required this.ticketId, required this.baseUrl});

  @override
  State<TicketPaymentPage> createState() => _TicketPaymentPageState();
}

class _TicketPaymentPageState extends State<TicketPaymentPage> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  
  bool _isLoading = false;
  Map<String, dynamic>? _ticketData;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    
    _scaleController.forward();
    _fetchTicketDetails();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _fetchTicketDetails() async {
    try {
      final response = await http.get(
        Uri.parse('${widget.baseUrl}/ticketing/tickets-flutter/?ticket_id=${widget.ticketId}'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['tickets'] != null && (data['tickets'] as List).isNotEmpty) {
          if (mounted) {
            setState(() {
              _ticketData = data['tickets'][0];
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching ticket details: $e");
    }
  }

  Future<void> _confirmPayment() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await http.post(
        Uri.parse('${widget.baseUrl}/ticketing/pay-flutter/${widget.ticketId}/'),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == 'success') {
         if (mounted) {
           // Simpan referensi sebelum pop
           final navigator = Navigator.of(context);
           final ticketId = widget.ticketId;
           final baseUrl = widget.baseUrl;
           
           // Pop dulu agar .then() di ticketing_page terpanggil dan status ter-refresh
           navigator.pop(true);
           
           // Langsung push ke halaman detail
           navigator.push(
             MaterialPageRoute(
               builder: (context) => TicketDetailPage(
                 ticketId: ticketId,
                 baseUrl: baseUrl,
                 initialIsUsed: false,
               ),
             ),
           );
         }
      } else {
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(data['error'] ?? "Gagal konfirmasi pembayaran"), backgroundColor: _primaryRed),
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
    final scheduleImage = _ticketData?['schedule_image'];
    final fullImageUrl = getFullImageUrl(scheduleImage, widget.baseUrl);
    final eventName = _ticketData?['event_name'] ?? 'Loading...';
    final category = _ticketData?['category'] ?? '';
    final date = _ticketData?['date'] ?? '';
    final time = _ticketData?['time'] ?? '';
    final location = _ticketData?['location'] ?? '';

    return Scaffold(
      backgroundColor: _bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Konfirmasi Pembayaran", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
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
                            colors: [
                              _primaryDark,
                              _pacilRedDarker2,
                              _primaryRed,
                            ],
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
                          colors: [
                            _primaryDark,
                            _pacilRedDarker2,
                            _primaryRed,
                          ],
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
                        if (category.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.4), width: 1),
                            ),
                            child: Text(
                              category.toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                            ),
                          ),
                        if (category.isNotEmpty) const SizedBox(height: 12),
                        Text(
                          eventName,
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                       if (date.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Text(date, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                              const SizedBox(width: 20),
                              if (time.isNotEmpty) ...[
                                const Icon(Icons.access_time_rounded, color: Colors.white, size: 16),
                                const SizedBox(width: 8),
                                Text(time.length >= 5 ? time.substring(0, 5) : time, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                              ]
                            ],
                          ),
                       ]
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            ScaleTransition(
              scale: _scaleAnimation,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      "Konfirmasi Pembayaran",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _primaryDark, letterSpacing: -0.5),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      "Selesaikan pembayaran untuk mendapatkan tiket",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: const Color(0xFF757575), height: 1.5),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _primaryRed.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                             child: Icon(Icons.confirmation_number_outlined, color: _primaryRed, size: 32),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "ID Tiket Anda",
                            style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "#${widget.ticketId}",
                            style: const TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.w800, fontSize: 28),
                          ),
                         const SizedBox(height: 8),
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                           decoration: BoxDecoration(
                             color: const Color(0xFFFEF3C7),
                             borderRadius: BorderRadius.circular(20),
                           ),
                           child: const Text(
                             "BELUM DIBAYAR",
                             style: TextStyle(color: Color(0xFFB45309), fontSize: 11, fontWeight: FontWeight.bold),
                           ),
                         )
                      ],
                    ),
                  ),
                    
                    const SizedBox(height: 40),
                    
                    // Confirm Payment Button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _confirmPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _successGreen,
                          foregroundColor: Colors.white,
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                          shadowColor: _successGreen.withOpacity(0.4),
                        ),
                         child: _isLoading 
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.check_circle_outline_rounded, size: 22),
                                SizedBox(width: 8),
                                Text("Konfirmasi Pembayaran", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              ],
                            ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _primaryRed,
                          side: const BorderSide(color: _primaryRed, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text("Batalkan", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
