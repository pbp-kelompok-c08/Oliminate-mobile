import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const Color _primaryDark = Color(0xFF113352);
const Color _primaryBlue = Color(0xFF3293EC);
const Color _primaryRed = Color(0xFFEA3C43);
const Color _pacilRedDarker2 = Color(0xFF521517);
const Color _successGreen = Color(0xFF10B981);
const Color _bgColor = Color(0xFFF5F5F5);

String? getFullImageUrl(String? imageUrl, String baseUrl) {
  if (imageUrl == null || imageUrl.isEmpty) return null;
  if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
    return imageUrl;
  }
  return '$baseUrl$imageUrl';
}

class TicketDetailPage extends StatefulWidget {
  final int ticketId;
  final String baseUrl;
  final bool initialIsUsed;

  const TicketDetailPage({
    super.key, 
    required this.ticketId, 
    required this.baseUrl,
    this.initialIsUsed = false,
  });

  @override
  State<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends State<TicketDetailPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isLoading = false;
  late bool _isUsed;
  Map<String, dynamic>? _ticketData;

  @override
  void initState() {
    super.initState();
    _isUsed = widget.initialIsUsed;
    _setupAnimations();
    _fetchTicketData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchTicketData() async {
    try {
      final response = await http.get(
        Uri.parse('${widget.baseUrl}/ticketing/tickets-flutter/?ticket_id=${widget.ticketId}'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['tickets'] != null && (data['tickets'] as List).isNotEmpty) {
          setState(() {
            _ticketData = data['tickets'][0];
            _isUsed = _ticketData?['is_used'] ?? _isUsed;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching ticket data: $e');
    }
  }

  String _generateQrCodeUrl() {
    final buyerUsername = _ticketData?['buyer_username'] ?? 'user';
    final data = 'TIKET-${widget.ticketId}-$buyerUsername';
    return 'https://api.qrserver.com/v1/create-qr-code/?data=$data&size=200x200';
  }

  Future<void> _scanTicket() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('${widget.baseUrl}/ticketing/scan-flutter/${widget.ticketId}/'),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == 'success') {
        setState(() {
          _isUsed = true;
        });
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(data['message']), backgroundColor: _successGreen),
           );
        }
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(data['message'] ?? "Gagal scan tiket"), backgroundColor: _primaryRed),
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
    final eventName = _ticketData?['event_name'] ?? 'Event';
    final category = _ticketData?['category'] ?? '';
    final date = _ticketData?['date'] ?? '';
    final time = _ticketData?['time'] ?? '';
    final location = _ticketData?['location'] ?? '';
    
    final fullImageUrl = getFullImageUrl(scheduleImage, widget.baseUrl);
    
    return Scaffold(
      backgroundColor: _bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Detail Tiket", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
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
                   // Background image or placeholder
                  if (fullImageUrl != null)
                    Image.network(
                      fullImageUrl,
                      width: double.infinity,
                      height: 280,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, error, __) {
                        return Container(
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
                        );
                      },
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
                  // Gradient overlay with pacil-red-darker-2
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
                  // Content overlay
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 32,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category badge
                        if (category.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                            ),
                            child: Text(
                              category.toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                            ),
                          ),
                        if (category.isNotEmpty) const SizedBox(height: 12),
                        // Event name
                        Text(
                          eventName,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        // Date, time, location info
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (date.isNotEmpty || time.isNotEmpty)
                              Row(
                                children: [
                                  if (date.isNotEmpty) ...[
                                    const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 16),
                                    const SizedBox(width: 8),
                                    Text(date, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                                    const SizedBox(width: 20),
                                  ],
                                  if (time.isNotEmpty) ...[
                                    const Icon(Icons.access_time_rounded, color: Colors.white, size: 16),
                                    const SizedBox(width: 8),
                                    Text(time.length >= 5 ? time.substring(0, 5) : time, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                                  ],
                                ],
                              ),
                            if (location.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_rounded, color: Colors.white, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(location, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // QR Code Section
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _isUsed ? Colors.grey.shade50 : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: ColorFiltered(
                                  colorFilter: _isUsed 
                                    ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                                    : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
                                  child: Image.network(
                                    _generateQrCodeUrl(),
                                    width: 200,
                                    height: 200,
                                    errorBuilder: (ctx, _, __) => Container(
                                      width: 200,
                                      height: 200,
                                      color: Colors.grey.shade100,
                                      child: const Icon(Icons.broken_image_rounded, size: 64, color: Color(0xFFBDBDBD)),
                                    ),
                                    loadingBuilder: (ctx, child, progress) {
                                      if (progress == null) return child;
                                      return SizedBox(
                                        width: 200,
                                        height: 200,
                                        child: Center(child: CircularProgressIndicator(color: _primaryBlue)),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                            
                            if (_isUsed) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFACF5D4), width: 0.5),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: const Color(0xFF047857), size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Tiket Sudah Divalidasi",
                                      style: TextStyle(color: const Color(0xFF047857), fontWeight: FontWeight.w700, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Scan Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: (_isLoading || _isUsed) ? null : _scanTicket,
                          icon: _isLoading 
                            ? const SizedBox.shrink()
                            : Icon(_isUsed ? Icons.block_rounded : Icons.qr_code_scanner_rounded, size: 20),
                          label: _isLoading 
                            ? const SizedBox(height: 28, width: 28, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : Text(
                                _isUsed ? "Tiket Sudah Divalidasi" : "Validasi Tiket",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.3),
                              ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isUsed ? Colors.grey.shade400 : _primaryBlue,
                            disabledBackgroundColor: Colors.grey.shade400,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Info text
                      Text(
                        _isUsed 
                          ? "Tiket ini sudah tidak dapat digunakan lagi."
                          : "Tekan tombol di atas untuk memvalidasi tiket Anda.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: const Color(0xFF3D3D3D), fontSize: 14, height: 1.6),
                      ),
                    ],
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
