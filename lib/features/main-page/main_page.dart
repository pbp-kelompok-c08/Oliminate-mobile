import 'package:flutter/material.dart';
import 'package:oliminate_mobile/features/user-profile/main_profile.dart';
import 'package:oliminate_mobile/left_drawer.dart';
import 'package:oliminate_mobile/widgets/main_scaffold.dart';

const _primaryDark = Color(0xFF113352);
const _primaryBlue = Color(0xFF3293EC);
const _blueLight1 = Color(0xFF73B9F9);
const _redBase = Color(0xFFEA3C43);
const _redLight1 = Color(0xFFF47479);
const _neutralBg = Color(0xFFF5F5F5);

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static const String routeName = '/landing';

  void _notImplemented(String label) {
    debugPrint('$label: tombol ini belum diimplementasikan');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Oliminate',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: _primaryDark,
        foregroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Profil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: LeftDrawer(),
      backgroundColor: _neutralBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const _HeroSection(),
              Container(
                transform: Matrix4.translationValues(0, -18, 0),
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  children: [
                    const _AboutSection(),
                    const SizedBox(height: 20),
                    const _ScheduleSection(),
                    const SizedBox(height: 20),
                    _TicketCallToAction(onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MainScaffold(initialIndex: 2)),
                      );
                    }),
                    const SizedBox(height: 20),
                    _ReviewCallToAction(onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MainScaffold(initialIndex: 4)),
                      );
                    }),
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
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          // Background image with blue gradient overlay (matching web design)
          Positioned.fill(
            child: Image.asset(
              'assets/images/banner2.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Blue gradient overlay (like web hero-section)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _primaryDark.withOpacity(0.92),
                    const Color(0xFF22629E).withOpacity(0.85),
                    _primaryBlue.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Content
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Main title - large and bold
                  Text(
                    'Selamat Datang\ndi Oliminate',
                    textAlign: TextAlign.center,
                    style: textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1,
                      height: 1.1,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.4),
                          offset: const Offset(0, 4),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Subtitle
                  Text(
                    'Temukan dan beli tiket pertandingan\nfavoritmu dengan pengalaman premium',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.3,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Smooth fade to background
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    _neutralBg.withOpacity(0.5),
                    _neutralBg,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0, 0.5, 1],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _SectionContainer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 620;
          final illustration = ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              'assets/images/gambar1.png',
              width: 140,
              height: 140,
              fit: BoxFit.cover,
            ),
          );

          final textBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GradientText(
                'Tentang Kami',
                gradient: const LinearGradient(
                  colors: [_primaryBlue, _redBase],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  text:
                      'Oliminate adalah aplikasi yang dirancang untuk membantu event organizer dalam mengelola perlombaan secara efisien dan terintegrasi. Produk ini dibuat oleh ',
                  children: [
                    TextSpan(
                      text: 'Kelompok C08',
                      style: const TextStyle(
                        color: _redBase,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const TextSpan(
                      text:
                          ' dengan tujuan mempermudah pengelolaan event kompetisi, mulai dari penjadwalan, penjualan tiket, hingga pengalaman menonton secara langsung maupun daring.',
                    ),
                  ],
                ),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: _primaryDark,
                  height: 1.5,
                ),
              ),
            ],
          );

          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: textBlock),
                const SizedBox(width: 20),
                illustration,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textBlock,
              const SizedBox(height: 16),
              Center(child: illustration),
            ],
          );
        },
      ),
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: _GradientText(
              'Jadwal Terdekat',
              gradient: const LinearGradient(
                colors: [_primaryBlue, _redBase],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_mockSchedules.isEmpty)
            Text(
              'Belum ada jadwal upcoming.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            )
          else
            SizedBox(
              height: 340,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 12),
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final data = _mockSchedules[index];
                  return _ScheduleCard(data: data);
                },
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemCount: _mockSchedules.length,
              ),
            ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.data});

  final _ScheduleCardData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(
          color: _primaryBlue.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with overflow hidden
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.asset(
              data.imagePath,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Match title
                Text(
                  data.matchTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _primaryDark,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Category with red accent (like web)
                Text(
                  data.category.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _redBase,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 12),
                // Details with icons
                _scheduleDetailRow('📅', data.date),
                const SizedBox(height: 4),
                _scheduleDetailRow('🕒', data.time),
                const SizedBox(height: 4),
                _scheduleDetailRow('📍', data.location),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _scheduleDetailRow(String icon, String text) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF3D3D3D),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _TicketCallToAction extends StatelessWidget {
  const _TicketCallToAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final illustration = ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.asset(
        'assets/images/gambar3.png',
        width: 180,
        height: 180,
        fit: BoxFit.cover,
      ),
    );

    final textBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingin Dapatkan Tiketmu Sekarang?',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: _primaryDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Jangan sampai ketinggalan keseruan pertandingan favoritmu!',
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_redBase, Color(0xFF9E292D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: _redBase.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('🎟️', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 10),
                    Text(
                      'Jelajahi Tiket',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return _SectionContainer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 620;
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: textBlock),
                const SizedBox(width: 24),
                illustration,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textBlock,
              const SizedBox(height: 20),
              Center(child: illustration),
            ],
          );
        },
      ),
    );
  }
}

class _ReviewCallToAction extends StatelessWidget {
  const _ReviewCallToAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final illustration = ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.asset(
        'assets/images/gambar4.png',
        width: 180,
        height: 180,
        fit: BoxFit.cover,
      ),
    );

    final textBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lihat Review dari Penonton Lain!',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: _primaryDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ketahui pengalaman mereka sebelum kamu datang ke event berikutnya.',
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_redBase, Color(0xFF9E292D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: _redBase.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('⭐', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 10),
                    Text(
                      'Baca Review',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return _SectionContainer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 620;
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                illustration,
                const SizedBox(width: 24),
                Expanded(child: textBlock),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: illustration),
              const SizedBox(height: 20),
              textBlock,
            ],
          );
        },
      ),
    );
  }
}

class _SectionContainer extends StatelessWidget {
  const _SectionContainer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }
}

class _GradientText extends StatelessWidget {
  const _GradientText(this.text, {required this.gradient, this.style});

  final String text;
  final Gradient gradient;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final textStyle = (style ?? Theme.of(context).textTheme.bodyLarge)?.copyWith(color: Colors.white);
    return ShaderMask(
      shaderCallback: (rect) => gradient.createShader(rect),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: textStyle,
      ),
    );
  }
}

class _ScheduleCardData {
  const _ScheduleCardData({
    required this.team1,
    required this.team2,
    required this.category,
    required this.date,
    required this.time,
    required this.location,
    required this.imagePath,
  });

  final String team1;
  final String team2;
  final String category;
  final String date;
  final String time;
  final String location;
  final String imagePath;

  String get matchTitle => '$team1 vs $team2';
}

const List<_ScheduleCardData> _mockSchedules = [
  _ScheduleCardData(
    team1: 'Garuda United',
    team2: 'Harimau Muda',
    category: 'Sepak Bola',
    date: '12 Okt 2024',
    time: '18:00 WIB',
    location: 'Jakarta International Stadium',
    imagePath: 'assets/images/sepak_bola.png',
  ),
  _ScheduleCardData(
    team1: 'Blue Fire',
    team2: 'Angkasa',
    category: 'Basket',
    date: '15 Okt 2024',
    time: '16:30 WIB',
    location: 'Istora Senayan',
    imagePath: 'assets/images/basket.png',
  ),
  _ScheduleCardData(
    team1: 'Rivaldo',
    team2: 'Satria',
    category: 'Voli',
    date: '18 Okt 2024',
    time: '14:00 WIB',
    location: 'GOR Temuguruh',
    imagePath: 'assets/images/voli.png',
  ),
  _ScheduleCardData(
    team1: 'Smash ID',
    team2: 'Feather',
    category: 'Badminton',
    date: '22 Okt 2024',
    time: '19:30 WIB',
    location: 'GOR Cendrawasih',
    imagePath: 'assets/images/badminton.png',
  ),
];
