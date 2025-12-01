import 'package:flutter/material.dart';

// Model Dummy
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

  final List<Ticket> _allTickets = [
    Ticket(
      id: "101",
      eventName: "FUTSAL: FASILKOM vs FT",
      schedule: "24 Nov 2025 | 18:30",
      price: 45000,
      status: 'paid',
      isUsed: true,
    ),
    Ticket(
      id: "102",
      eventName: "BASKET: FISIP vs FKM",
      schedule: "25 Nov 2025 | 20:00",
      price: 50000,
      status: 'paid',
      isUsed: false,
    ),
    Ticket(
      id: "105",
      eventName: "VALORANT: MIPA vs VOKASI",
      schedule: "26 Nov 2025 | 19:00",
      price: 35000,
      status: 'unpaid',
      isUsed: false,
    ),
  ];

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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Buka form beli tiket...")),
                    );
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