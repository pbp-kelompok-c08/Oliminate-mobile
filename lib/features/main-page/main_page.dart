import 'package:flutter/material.dart';
import 'package:oliminate_mobile/features/user-profile/edit_profile.dart';
import 'package:oliminate_mobile/left_drawer.dart';

const _blueDark2 = Color(0xFF113352);
const _blueDark1 = Color(0xFF22629E);
const _blueLight1 = Color(0xFF73B9F9);
const _redBase = Color(0xFFEA3C43);
const _redLight1 = Color(0xFFF47479);

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
        title: const Text("Oliminate"),
        toolbarHeight: kToolbarHeight,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline_rounded),
            tooltip: 'Edit Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditProfilePage(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: LeftDrawer(),
      backgroundColor: const Color(0xFFF5F7FB),
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
                    _TicketCallToAction(onTap: () => _notImplemented('Beli tiket')),
                    const SizedBox(height: 20),
                    _ReviewCallToAction(onTap: () => _notImplemented('Lihat review')),
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
      height: 360,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'tk web/Oliminate/static/images/banner2.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.85),
                    Colors.black.withOpacity(0.45),
                    Colors.black.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0, 0.55, 0.8, 1],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _GradientText(
                    'Selamat Datang di Oliminate!',
                    gradient: const LinearGradient(
                      colors: [_blueLight1, _redLight1],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Temukan dan beli tiket pertandingan favoritmu!',
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      shadows: const [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(0, 2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 60,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Color(0xFFF5F7FB),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
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
              'tk web/Oliminate/static/images/gambar1.png',
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
                  colors: [_blueDark1, _redBase],
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
                  color: _blueDark2,
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
                colors: [_blueDark1, _redBase],
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
      width: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 18,
            offset: Offset(0, 12),
          ),
        ],
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: Image.asset(
              data.imagePath,
              height: 130,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: DefaultTextStyle(
              style: theme.textTheme.bodyMedium!.copyWith(color: _blueDark2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.matchTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _blueDark2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.category.toUpperCase(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.grey[600],
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('📅 ${data.date}'),
                  Text('🕒 ${data.time}'),
                  Text('📍 ${data.location}'),
                ],
              ),
            ),
          ),
        ],
      ),
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
        'tk web/Oliminate/static/images/gambar3.png',
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
            color: _blueDark2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Jangan sampai ketinggalan keseruan pertandingan favoritmu!',
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: _redLight1,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 6,
          ),
          icon: const Text('🎟️', style: TextStyle(fontSize: 20)),
          label: const Text(
            'Beli Tiket Sekarang',
            style: TextStyle(fontWeight: FontWeight.w700),
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
        'tk web/Oliminate/static/images/gambar4.png',
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
            color: _blueDark2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ketahui pengalaman mereka sebelum kamu datang ke event berikutnya.',
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: _redLight1,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 6,
          ),
          icon: const Text('⭐', style: TextStyle(fontSize: 18)),
          label: const Text(
            'Lihat Review',
            style: TextStyle(fontWeight: FontWeight.w700),
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
    imagePath: 'tk web/Oliminate/static/images/sepak_bola.png',
  ),
  _ScheduleCardData(
    team1: 'Blue Fire',
    team2: 'Angkasa',
    category: 'Basket',
    date: '15 Okt 2024',
    time: '16:30 WIB',
    location: 'Istora Senayan',
    imagePath: 'tk web/Oliminate/static/images/basket.png',
  ),
  _ScheduleCardData(
    team1: 'Rivaldo',
    team2: 'Satria',
    category: 'Voli',
    date: '18 Okt 2024',
    time: '14:00 WIB',
    location: 'GOR Temuguruh',
    imagePath: 'tk web/Oliminate/static/images/voli.png',
  ),
  _ScheduleCardData(
    team1: 'Smash ID',
    team2: 'Feather',
    category: 'Badminton',
    date: '22 Okt 2024',
    time: '19:30 WIB',
    location: 'GOR Cendrawasih',
    imagePath: 'tk web/Oliminate/static/images/badminton.png',
  ),
];