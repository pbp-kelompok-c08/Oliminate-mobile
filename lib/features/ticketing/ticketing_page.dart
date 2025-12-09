import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Schedule Model (from API)
class Schedule {
  final int id;
  final String category;
  final String team1;
  final String team2;
  final String location;
  final String date;
  final String time;
  final String status;
  final String? imageUrl;
  final String? caption;

  Schedule({
    required this.id,
    required this.category,
    required this.team1,
    required this.team2,
    required this.location,
    required this.date,
    required this.time,
    required this.status,
    this.imageUrl,
    this.caption,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      category: json['category'],
      team1: json['team1'],
      team2: json['team2'],
      location: json['location'],
      date: json['date'],
      time: json['time'],
      status: json['status'],
      imageUrl: json['image_url'],
      caption: json['caption'],
    );
  }

  String get eventName => "${category.toUpperCase()}: $team1 vs $team2";
  String get formattedSchedule => "$date | ${time.substring(0, 5)}";
}

// Ticket Model (for display)
class Ticket {
  final String id;
  final String eventName;
  final String schedule;
  final double price;
  final String status;
  final bool isUsed;

  Ticket({
    required this.id,
    required this.eventName,
    required this.schedule,
    required this.price,
    required this.status,
    required this.isUsed,
  });
}

class TicketingPage extends StatefulWidget {
  const TicketingPage({super.key});

  @override
  State<TicketingPage> createState() => _TicketingPageState();
}

class _TicketingPageState extends State<TicketingPage> {
  String _selectedFilter = 'all';

  // Warna
  final Color _pacilBlue = const Color(0xFF3293EC);
  final Color _neutralBg = const Color(0xFFF5F5F5);
  final Color _textDark = const Color(0xFF1A1A1A);
  final Color _textGrey = const Color(0xFF7D7D7D);

  // API Base URL - change this to your backend URL
  // Use localhost for Chrome/web testing
  // Use 10.0.2.2 for Android emulator
  // Use your actual IP for physical device
  static const String baseUrl = 'http://localhost:8000';

  // State for schedules
  List<Schedule> _schedules = [];
  bool _isLoadingSchedules = false;
  String? _schedulesError;

  // Tickets list - will be fetched from API
  final List<Ticket> _allTickets = [];

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  // Fetch schedules from API
  Future<void> _fetchSchedules() async {
    setState(() {
      _isLoadingSchedules = true;
      _schedulesError = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ticketing/schedules/json/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> schedulesJson = data['schedules'];
        setState(() {
          _schedules = schedulesJson
              .map((json) => Schedule.fromJson(json))
              .toList();
          _isLoadingSchedules = false;
        });
      } else {
        setState(() {
          _schedulesError = 'Failed to load schedules: ${response.statusCode}';
          _isLoadingSchedules = false;
        });
      }
    } catch (e) {
      setState(() {
        _schedulesError = 'Connection error: $e';
        _isLoadingSchedules = false;
      });
    }
  }

  // --- FUNGSI MANUAL FORMAT RUPIAH (PENGGANTI INTL) ---
  String formatRupiah(double price) {
    String priceStr = price.toInt().toString();
    String result = '';
    int count = 0;
    for (int i = priceStr.length - 1; i >= 0; i--) {
      count++;
      result = priceStr[i] + result;
      if (count == 3 && i > 0) {
        result = '.$result';
        count = 0;
      }
    }
    return 'Rp $result';
  }

  @override
  Widget build(BuildContext context) {
    final displayTickets = _selectedFilter == 'all'
        ? _allTickets
        : _allTickets.where((t) => t.status == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: _neutralBg,
      appBar: AppBar(
        title: const Text("Riwayat Tiket", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF113352),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER & TOMBOL BELI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Tiket Saya",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _textDark,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _showBuyTicketDialog(context);
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Beli Tiket"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pacilBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),

            // FILTER CHIPS
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterBtn("Semua", 'all'),
                  const SizedBox(width: 8),
                  _buildFilterBtn("Sudah Dibayar", 'paid'),
                  const SizedBox(width: 8),
                  _buildFilterBtn("Belum Dibayar", 'unpaid'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // LIST TIKET
            if (displayTickets.isEmpty)
              _buildEmptyState()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayTickets.length,
                separatorBuilder: (ctx, index) => const SizedBox(height: 16),
                itemBuilder: (ctx, index) {
                  return _buildTicketCard(displayTickets[index]);
                },
              ),
          ],
        ),
      ),
    );
  }

  // Dialog to buy ticket with schedules from API
  void _showBuyTicketDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Pilih Jadwal",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: _isLoadingSchedules
                  ? const Center(child: CircularProgressIndicator())
                  : _schedulesError != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                              const SizedBox(height: 16),
                              Text(_schedulesError!, textAlign: TextAlign.center),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchSchedules,
                                child: const Text("Coba Lagi"),
                              ),
                            ],
                          ),
                        )
                      : _schedules.isEmpty
                          ? const Center(
                              child: Text("Tidak ada jadwal tersedia"),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _schedules.length,
                              itemBuilder: (context, index) {
                                final schedule = _schedules[index];
                                return _buildScheduleCard(schedule);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard(Schedule schedule) {
    Color statusColor;
    String statusText;
    
    switch (schedule.status) {
      case 'upcoming':
        statusColor = Colors.green;
        statusText = 'Upcoming';
        break;
      case 'completed':
        statusColor = Colors.grey;
        statusText = 'Selesai';
        break;
      case 'reviewable':
        statusColor = Colors.blue;
        statusText = 'Reviewable';
        break;
      default:
        statusColor = Colors.grey;
        statusText = schedule.status;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: schedule.status == 'upcoming' ? () {
          Navigator.pop(context);
          _confirmTicketPurchase(schedule);
        } : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      schedule.eventName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: _textGrey),
                  const SizedBox(width: 4),
                  Text(
                    schedule.formattedSchedule,
                    style: TextStyle(fontSize: 13, color: _textGrey),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: _textGrey),
                  const SizedBox(width: 4),
                  Text(
                    schedule.location,
                    style: TextStyle(fontSize: 13, color: _textGrey),
                  ),
                ],
              ),
              if (schedule.status == 'upcoming') ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _confirmTicketPurchase(schedule);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pacilBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Beli Tiket"),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _confirmTicketPurchase(Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Pembelian"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Event: ${schedule.eventName}"),
            const SizedBox(height: 8),
            Text("Tanggal: ${schedule.formattedSchedule}"),
            Text("Lokasi: ${schedule.location}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement actual purchase via buy_ticket_flutter API
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Tiket untuk ${schedule.eventName} berhasil dibeli!"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _pacilBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text("Beli"),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBtn(String label, String value) {
    final bool isActive = _selectedFilter == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? _pacilBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? _pacilBlue : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : _textGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard(Ticket ticket) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.eventName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "ID: #${ticket.id} • ${ticket.schedule}",
                      style: TextStyle(fontSize: 12, color: _textGrey),
                    ),
                  ],
                ),
              ),
              // Panggil fungsi manual di sini
              Text(
                formatRupiah(ticket.price),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
              ),
            ],
          ),
          
          const Divider(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (ticket.status == 'paid')
                    _buildBadge("Sudah Dibayar", const Color(0xFFD1FAE5), const Color(0xFF065F46))
                  else
                    _buildBadge("Belum Dibayar", const Color(0xFFFEF9C3), const Color(0xFFB45309)),
                  
                  const SizedBox(height: 6),

                  if (ticket.isUsed)
                    _buildBadge("Sudah Digunakan", const Color(0xFFDBEAFE), const Color(0xFF1E40AF))
                  else
                    _buildBadge("Belum Digunakan", const Color(0xFFF3F4F6), const Color(0xFF374151)),
                ],
              ),

              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _pacilBlue),
                  foregroundColor: _pacilBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Lihat Detail"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.confirmation_number_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "Tidak Ada Tiket",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark),
          ),
          const SizedBox(height: 8),
          Text(
            "Kamu belum memiliki tiket di kategori ini.",
            textAlign: TextAlign.center,
            style: TextStyle(color: _textGrey),
          ),
        ],
      ),
    );
  }
}