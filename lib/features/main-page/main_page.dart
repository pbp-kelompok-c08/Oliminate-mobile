import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static const String routeName = '/landing';

  void _showSnack(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Anda mengklik tombol $label')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeroSection(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    _AboutSection(),
                    const SizedBox(height: 16),
                    _ScheduleSection(),
                    const SizedBox(height: 16),
                    _TicketCTA(onTap: () => _showSnack(context, 'Beli Tiket Sekarang')),
                    const SizedBox(height: 16),
                    _ReviewCTA(onTap: () => _showSnack(context, 'Lihat Review')),
                    const SizedBox(height: 16),
                    _ProfileCTA(
                      onTap: () => _showSnack(context, 'Masuk / Profil'),
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1b2340), Color(0xFF1b2340), Color(0xFF1b2340), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Selamat Datang di Oliminate!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Temukan dan beli tiket pertandingan favoritmu!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 4,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 600;

          // 1. BUKAN Expanded di sini, cukup Column biasa
          final textColumn = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tentang Kami',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF1f3b6f),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  text:
                      'Oliminate adalah aplikasi yang dirancang untuk membantu event organizer dalam mengelola perlombaan secara efisien dan terintegrasi. Produk ini dibuat oleh ',
                  children: [
                    TextSpan(
                      text: 'Kelompok C08',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const TextSpan(
                      text:
                          ' dengan tujuan mempermudah pengelolaan event kompetisi, mulai dari penjadwalan, penjualan tiket, hingga pengalaman menonton secara langsung maupun daring.',
                    ),
                  ],
                ),
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
            ],
          );

          final illustration = Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFFf97316), Color(0xFFec4899)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.sports_volleyball,
              color: Colors.white,
              size: 80,
            ),
          );

          if (isNarrow) {
            // 2. Di mobile: teks di atas, ilustrasi di bawah
            return Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textColumn,
                  const SizedBox(height: 16),
                  Center(child: illustration),
                ],
              ),
            );
          }

          // 3. Di lebar: teks + ilustrasi sejajar, teks dibungkus Expanded DI SINI
          return Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: textColumn),
                const SizedBox(width: 12),
                illustration,
              ],
            ),
          );
        },
      ),
    );
  }
}


class _ScheduleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Text(
              'Jadwal Terdekat',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [Color(0xFF1f4c8f), Color(0xFF8b1a3d)],
                  ).createShader(const Rect.fromLTWH(0, 0, 200, 20)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada jadwal upcoming.',
              style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF4B5563)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketCTA extends StatelessWidget {
  const _TicketCTA({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Text(
              'Ingin Dapatkan Tiketmu Sekarang?',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1f3b6f),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Jangan sampai ketinggalan keseruan pertandingan favoritmu!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF4B5563)),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF95D6A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              icon: const Icon(Icons.confirmation_number),
              label: const Text('Beli Tiket Sekarang'),
            ),
            const SizedBox(height: 12),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: const Color(0xFFFFF7D6),
              ),
              child: const Icon(
                Icons.confirmation_number,
                color: Color(0xFFF59E0B),
                size: 72,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCTA extends StatelessWidget {
  const _ReviewCTA({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: const Color(0xFFFFF7E0),
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Color(0xFFFBBF24),
                size: 64,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lihat Review dari Penonton Lain!',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1f3b6f),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ketahui pengalaman mereka sebelum kamu datang ke event berikutnya.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF4B5563)),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF95D6A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              icon: const Icon(Icons.star),
              label: const Text('Lihat Review'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCTA extends StatelessWidget {
  const _ProfileCTA({required this.onTap, required this.theme});

  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: const Color(0xFF3293ec).withOpacity(0.5)),
      ),
      child: Text(
        'Masuk / Profil',
        style: theme.textTheme.titleMedium?.copyWith(
          color: const Color(0xFF3293ec),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
