import 'dart:async';

import 'package:flutter/material.dart';
import 'package:oliminate_mobile/core/app_config.dart';
import 'package:oliminate_mobile/features/scheduling/data/datasources/scheduling_api_service.dart';
import 'package:oliminate_mobile/features/scheduling/data/models/schedule.dart';
import 'package:oliminate_mobile/features/user-profile/auth_repository.dart';
import 'package:oliminate_mobile/features/user-profile/main_profile.dart';
import 'package:oliminate_mobile/widgets/main_scaffold.dart';

const _primaryDark = Color(0xFF113352);
const _primaryBlue = Color(0xFF3293EC);
const _blueLight1 = Color(0xFF73B9F9);
const _redBase = Color(0xFFEA3C43);
const _redLight1 = Color(0xFFF47479);
const _neutralBg = Color(0xFFF5F5F5);

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  static const String routeName = '/landing';

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late final SchedulingApiService _api;
  final _authRepo = AuthRepository.instance;

  List<Schedule> _upcomingSchedules = [];
  bool _loadingSchedules = true;
  bool _errorSchedules = false;
  
  // Timer for periodic polling
  Timer? _refreshTimer;
  static const Duration _refreshInterval = Duration(seconds: 15);

  @override
  void initState() {
    super.initState();
    _api = SchedulingApiService(
      baseUrl: AppConfig.backendBaseUrl,
      djangoClient: _authRepo.client,
    );
    _fetchUpcomingSchedules();
    _startPeriodicRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      _silentRefreshSchedules();
    });
  }

  /// Silent refresh without showing loading indicator
  Future<void> _silentRefreshSchedules() async {
    try {
      final List<Schedule> allSchedules = await _api.fetchList();
      if (!mounted) return;
      
      final upcoming = allSchedules
          .where((s) => s.status.toLowerCase() == 'upcoming')
          .take(5)
          .toList();
      
      setState(() {
        _upcomingSchedules = upcoming;
        _errorSchedules = false;
      });
    } catch (e) {
      // Silent fail - don't show error on periodic refresh
      debugPrint('Silent refresh error: $e');
    }
  }

  Future<void> _fetchUpcomingSchedules() async {
    setState(() {
      _loadingSchedules = true;
      _errorSchedules = false;
    });

    try {
      final List<Schedule> allSchedules = await _api.fetchList();
      if (!mounted) return;
      
      // Filter only upcoming schedules and take first 5
      final upcoming = allSchedules
          .where((s) => s.status.toLowerCase() == 'upcoming')
          .take(5)
          .toList();
      
      setState(() {
        _upcomingSchedules = upcoming;
        _loadingSchedules = false;
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error fetching upcoming schedules: $e');
      setState(() {
        _errorSchedules = true;
        _loadingSchedules = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                    _ScheduleSection(
                      schedules: _upcomingSchedules,
                      loading: _loadingSchedules,
                      error: _errorSchedules,
                      onRefresh: _fetchUpcomingSchedules,
                    ),
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
  const _ScheduleSection({
    required this.schedules,
    required this.loading,
    required this.error,
    required this.onRefresh,
  });

  final List<Schedule> schedules;
  final bool loading;
  final bool error;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: _GradientText(
              'Pertandingan Mendatang',
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
          if (loading)
            const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(color: _primaryBlue),
              ),
            )
          else if (error)
            SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.grey[400], size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal memuat jadwal',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: onRefresh,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            )
          else if (schedules.isEmpty)
            SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Belum ada jadwal upcoming.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ),
            )
          else
            SizedBox(
              height: 340,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(vertical: 12),
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final schedule = schedules[index];
                  return _ScheduleCard(schedule: schedule);
                },
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemCount: schedules.length,
              ),
            ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.schedule});

  final Schedule schedule;

  String get _matchTitle => '${schedule.team1} vs ${schedule.team2}';

  String _formatDate(String dateStr) {
    // Parse YYYY-MM-DD to readable format
    try {
      final parts = dateStr.split('-');
      if (parts.length != 3) return dateStr;
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      final day = int.parse(parts[2]);
      final month = int.parse(parts[1]);
      final year = parts[0];
      return '$day ${months[month - 1]} $year';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatTime(String timeStr) {
    // Add WIB suffix if not present
    if (timeStr.contains('WIB')) return timeStr;
    return '$timeStr WIB';
  }

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
            child: schedule.imageUrl != null && schedule.imageUrl!.isNotEmpty
                ? Image.network(
                    schedule.imageUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                  )
                : _buildPlaceholderImage(),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Match title
                Text(
                  _matchTitle,
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
                  schedule.category.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _redBase,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 12),
                // Details with icons
                _scheduleDetailRow('📅', _formatDate(schedule.date)),
                const SizedBox(height: 4),
                _scheduleDetailRow('🕒', _formatTime(schedule.time)),
                const SizedBox(height: 4),
                _scheduleDetailRow('📍', schedule.location),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryBlue.withOpacity(0.2), _redBase.withOpacity(0.2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(
        Icons.sports,
        size: 48,
        color: _primaryDark.withOpacity(0.3),
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

