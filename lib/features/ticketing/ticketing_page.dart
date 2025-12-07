import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:oliminate_mobile/left_drawer.dart';
import 'package:oliminate_mobile/features/user-profile/auth_repository.dart';

import 'package:oliminate_mobile/features/ticketing/models.dart';
import 'package:oliminate_mobile/features/ticketing/ticket_form.dart';
import 'package:oliminate_mobile/features/ticketing/ticket_detail.dart';
import 'package:oliminate_mobile/features/ticketing/ticket_payment.dart';

// Models are now in models.dart

class TicketingPage extends StatefulWidget {
  const TicketingPage({super.key});

  @override
  State<TicketingPage> createState() => _TicketingPageState();
}

class _TicketingPageState extends State<TicketingPage> {
  String _paymentFilter = 'all'; // all, paid, unpaid
  String _usageFilter = 'all'; // all, used, unused

  // Warna - Updated to modern professional color palette
  final Color _primaryDark = const Color(0xFF113352);
  final Color _primaryBlue = const Color(0xFF3293EC);
  final Color _accentTeal = const Color(0xFF0D9488);
  final Color _primaryRed = const Color(0xFFEA3C43);
  final Color _neutralBg = const Color(0xFFF5F5F5);
  final Color _cardBg = Colors.white;
  final Color _textDark = const Color(0xFF113352);
  final Color _textGrey = const Color(0xFF3D3D3D);
  final Color _borderLight = const Color(0xFFE0E0E0);

  // API Base URL
  static const String baseUrl = 'http://localhost:8000';

  // State
  List<Schedule> _schedules = [];
  bool _isLoadingSchedules = false;
  String? _schedulesError;

  List<Ticket> _allTickets = [];
  bool _isLoadingTickets = false;
  
  // User Role State
  String _role = 'user'; // Default to user (guest)
  String? _currentUsername;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
    _fetchSchedules();
  }

  Future<void> _checkUserRole() async {
    final auth = AuthRepository.instance;
    if (auth.cachedProfile == null) {
      await auth.validateSession();
      await auth.fetchProfile();
    }
    
    if (mounted) {
      setState(() {
        if (auth.cachedProfile != null) {
          _role = auth.cachedProfile!.role.toLowerCase(); // Normalize to lowercase
          _currentUsername = auth.cachedProfile!.username;
        } else {
          _role = 'user'; // Fallback
          _currentUsername = null;
        }
      });
      _fetchTickets(); // Fetch tickets after getting username
    }
  }

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

  Future<void> _fetchTickets() async {
    setState(() => _isLoadingTickets = true);
    try {
      String url = '$baseUrl/ticketing/tickets-flutter/';
      if (_currentUsername != null) {
        url += '?username=$_currentUsername';
      }
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
         final data = jsonDecode(response.body);
         if (data['status'] == 'success') {
            final List ticketsJson = data['tickets'];
            setState(() {
               _allTickets.clear();
               _allTickets.addAll(ticketsJson.map((json) => Ticket.fromJson(json)).toList());
               _isLoadingTickets = false; 
            });
         } else {
            setState(() => _isLoadingTickets = false);
         }
      } else {
         setState(() => _isLoadingTickets = false);
      }
    } catch (e) {
      debugPrint("Error fetching tickets: $e");
      setState(() => _isLoadingTickets = false);
    }
  }

  String formatRupiah(double? price) {
    if (price == null) return 'Rp -';
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

  List<Ticket> _getFilteredTickets() {
    List<Ticket> tickets = _allTickets;

    // Payment Filter
    if (_paymentFilter == 'unpaid') {
      tickets = tickets.where((t) => t.status != 'paid').toList();
    } else if (_paymentFilter == 'paid') {
      tickets = tickets.where((t) => t.status == 'paid').toList();
    }

    // Usage Filter
    if (_usageFilter == 'used') {
      tickets = tickets.where((t) => t.isUsed).toList();
    } else if (_usageFilter == 'unused') {
      tickets = tickets.where((t) => !t.isUsed).toList();
    }

    return tickets;
  }

  @override
  Widget build(BuildContext context) {
    final displayTickets = _getFilteredTickets();
    final bool isOrganizer = _role == 'organizer';

    return Scaffold(
      backgroundColor: _neutralBg,
      appBar: AppBar(
        title: Text(isOrganizer ? "Kelola Harga Tiket" : "Riwayat Tiket", style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: _primaryDark,
        foregroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
      ),
      drawer: const LeftDrawer(),
      body: isOrganizer ? _buildOrganizerBody() : _buildUserBody(displayTickets),
    );
  }

  // ============ ORGANIZER VIEW ============
  Widget _buildOrganizerBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Atur Harga Tiket Event",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _textDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Pilih jadwal untuk mengatur atau mengubah harga tiket.",
            style: TextStyle(color: _textGrey, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 24),
          
          // Schedule List for Organizer
          if (_isLoadingSchedules)
            const Center(child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ))
          else if (_schedulesError != null)
            Center(
              child: Column(
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
          else if (_schedules.isEmpty)
            const Center(child: Text("Tidak ada jadwal tersedia"))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _schedules.length,
              itemBuilder: (context, index) {
                final schedule = _schedules[index];
                return _buildOrganizerScheduleCard(schedule);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildOrganizerScheduleCard(Schedule schedule) {
    final double? price = schedule.price;
    final bool hasPriceSet = price != null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    schedule.eventName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${schedule.date} • ${schedule.location}",
                    style: TextStyle(fontSize: 13, color: _textGrey, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: hasPriceSet 
                        ? const Color(0xFFDCFCE7).withOpacity(0.7)
                        : const Color(0xFFFEF3C7).withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: hasPriceSet 
                          ? const Color(0xFF6EE7B7)
                          : const Color(0xFFFCD34D),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      hasPriceSet ? formatRupiah(price) : "Harga Belum Diatur",
                      style: TextStyle(
                        color: hasPriceSet ? const Color(0xFF047857) : const Color(0xFFB45309),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => _showSetPriceDialog(schedule),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              child: Text(hasPriceSet ? "Ubah" : "Atur", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  // ============ USER VIEW ============
  Widget _buildUserBody(List<Ticket> displayTickets) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tiket Saya",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Kelola dan lihat status tiket Anda",
                    style: TextStyle(color: _textGrey, fontSize: 13),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _showBuyTicketDialog(context);
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text("Beli Tiket"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentTeal,
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
          
          const SizedBox(height: 24),

          Row(
            children: [
              // Usage Filter
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _borderLight),
                    boxShadow: [
                       BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))
                    ]
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _usageFilter,
                      isExpanded: true,
                      icon: Icon(Icons.qr_code_rounded, color: _primaryBlue, size: 18),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      style: TextStyle(color: _textDark, fontSize: 13, fontWeight: FontWeight.w600),
                      items: [
                        DropdownMenuItem(value: 'all', child: Text("Semua Status")),
                        DropdownMenuItem(value: 'used', child: Text("Sudah Dipakai")),
                        DropdownMenuItem(value: 'unused', child: Text("Belum Dipakai")),
                      ],
                      onChanged: (val) => setState(() => _usageFilter = val!),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Payment Filter
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _borderLight),
                    boxShadow: [
                       BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))
                    ]
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _paymentFilter,
                      isExpanded: true,
                      icon: Icon(Icons.payments_rounded, color: _primaryBlue, size: 18),
                      dropdownColor: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      style: TextStyle(color: _textDark, fontSize: 13, fontWeight: FontWeight.w600),
                      items: [
                        DropdownMenuItem(value: 'all', child: Text("Semua Bayar")),
                        DropdownMenuItem(value: 'paid', child: Text("Sudah Dibayar")),
                        DropdownMenuItem(value: 'unpaid', child: Text("Belum Dibayar")),
                      ],
                      onChanged: (val) => setState(() => _paymentFilter = val!),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // LIST TIKET
          if (_isLoadingTickets)
            const Center(child: CircularProgressIndicator())
          else if (displayTickets.isEmpty)
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

    // Role Logic
    final bool isOrganizer = _role == 'organizer';
    final double? price = schedule.price;
    final bool isPriceSet = price != null;

    String buttonLabel = "Aksi";
    VoidCallback? onAction;
    bool isActionEnabled = false;

    if (schedule.status == 'upcoming') {
      if (isOrganizer) {
        buttonLabel = isPriceSet ? "Ubah Harga (${formatRupiah(price)})" : "Atur Harga";
        isActionEnabled = true;
        onAction = () {
          _showSetPriceDialog(schedule);
        };
      } else {
        // User Logic
        if (isPriceSet) {
           buttonLabel = "Beli (${formatRupiah(price)})";
           isActionEnabled = true;
           onAction = () {
              Navigator.pop(context); // Close sheet before form
             _openTicketForm(schedule);
           };
        } else {
           buttonLabel = "Harga Belum Tersedia";
           isActionEnabled = false;
           onAction = null;
        }
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    onPressed: isActionEnabled ? onAction : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryBlue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      disabledForegroundColor: Colors.grey[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(buttonLabel),
                  ),
                ),
              ],
            ],
          ),
      ),
    );
  }

  // --- API ACTIONS ---

  Future<void> _setPrice(Schedule schedule, String priceStr) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ticketing/set-price-flutter/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'schedule_id': schedule.id,
          'price': priceStr,
          'username': _currentUsername, 
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['status'] == 'success') {
        if (mounted) {
          Navigator.pop(context); // Close dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Harga berhasil diatur!"), backgroundColor: Colors.green),
          );
          _fetchSchedules(); 
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text(data['message'] ?? "Gagal mengatur harga"), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showSetPriceDialog(Schedule schedule) {
    final priceController = TextEditingController(text: schedule.price?.toInt().toString() ?? '');
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.confirmation_number_outlined, color: _primaryBlue, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Atur Harga Tiket",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          schedule.category.toUpperCase(),
                          style: TextStyle(fontSize: 13, color: _textGrey, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Event Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _neutralBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Pertandingan", style: TextStyle(color: _textGrey, fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(
                      "${schedule.team1} vs ${schedule.team2}",
                      style: TextStyle(color: _textDark, fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    Text("Tanggal & Lokasi", style: TextStyle(color: _textGrey, fontSize: 12, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(
                      "${schedule.date} • ${schedule.location}",
                      style: TextStyle(color: _textDark, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Input Field
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: "Harga Tiket",
                  hintText: "0",
                  prefixText: "Rp ",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderLight)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _primaryBlue, width: 2)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: _textGrey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Batal", style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (priceController.text.isNotEmpty) {
                          _setPrice(schedule, priceController.text);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text("Simpan", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openTicketForm(Schedule schedule) {
    final user = _currentUsername ?? "guest"; 
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketFormPage(
          schedule: schedule,
          username: user,
          baseUrl: baseUrl,
        ),
      ),
    ).then((_) => _fetchTickets()); // Refresh tickets after return
  }



  Widget _buildTicketCard(Ticket ticket) {
    // Robust ID parsing
    final int ticketIdInt = int.tryParse(ticket.id) ?? 0;
    
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.confirmation_number_rounded, color: _primaryBlue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.eventName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "ID: #${ticket.id}",
                        style: TextStyle(fontSize: 12, color: _textGrey, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatRupiah(ticket.price),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 14),
            Container(height: 1, color: _borderLight),
            const SizedBox(height: 14),

            // Status Row - Improved badge layout
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBadge(
                      ticket.status == 'paid' ? "Sudah Dibayar" : "Belum Dibayar",
                      ticket.status == 'paid' ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                      ticket.status == 'paid' ? const Color(0xFF047857) : const Color(0xFFB45309),
                    ),
                    const SizedBox(height: 8),
                    _buildBadge(
                      ticket.isUsed ? "Sudah Digunakan" : "Belum Digunakan",
                      ticket.isUsed ? const Color(0xFFDBEAFE) : const Color(0xFFF1F5F9),
                      ticket.isUsed ? const Color(0xFF1E40AF) : const Color(0xFF334155),
                    ),
                  ],
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    if (ticketIdInt == 0) return;

                    if (ticket.status == 'unpaid') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TicketPaymentPage(
                            ticketId: ticketIdInt,
                            baseUrl: baseUrl,
                          ),
                        ),
                      ).then((_) => _fetchTickets());
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TicketDetailPage(
                            ticketId: ticketIdInt,
                            baseUrl: baseUrl,
                            initialIsUsed: ticket.isUsed,
                          ),
                        ),
                      ).then((_) => _fetchTickets());
                    }
                  },
                  child: Text(
                    ticket.status == 'unpaid' ? "Bayar Sekarang" : "Lihat Detail",
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.2), width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderLight, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.confirmation_number_outlined, size: 40, color: _primaryBlue),
          ),
          const SizedBox(height: 16),
          Text(
            "Belum Ada Tiket",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _textDark),
          ),
          const SizedBox(height: 8),
          Text(
            "Mulai dengan membeli tiket untuk event yang ingin Anda hadiri.",
            textAlign: TextAlign.center,
            style: TextStyle(color: _textGrey, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showBuyTicketDialog(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text("Beli Tiket Sekarang"),
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentTeal,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
