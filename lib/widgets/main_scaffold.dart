import 'package:flutter/material.dart';

import 'package:oliminate_mobile/core/app_config.dart';
import 'package:oliminate_mobile/core/theme/app_colors.dart';
import 'package:oliminate_mobile/features/main-page/main_page.dart';
import 'package:oliminate_mobile/features/merchandise/screens/merchandise_page.dart';
import 'package:oliminate_mobile/features/review/review_page.dart';
import 'package:oliminate_mobile/features/scheduling/presentation/pages/scheduling_page.dart';
import 'package:oliminate_mobile/features/ticketing/ticketing_page.dart';
import 'package:oliminate_mobile/features/user-profile/auth_repository.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _currentIndex;
  final _authRepo = AuthRepository.instance;

  String? _username;
  bool _isOrganizer = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    await _authRepo.init();
    final profile = _authRepo.cachedProfile ?? await _authRepo.fetchProfile();
    if (!mounted) return;
    setState(() {
      _username = profile?.username;
      _isOrganizer = profile?.role.toLowerCase().contains('organizer') ?? false;
    });
  }

  // Index 0: Home (LandingPage)
  // Index 1: Schedule
  // Index 2: Ticketing
  // Index 3: Merchandise
  // Index 4: Review
  List<Widget> get _pages => [
        const LandingPage(),
        SchedulingPage(
          baseUrl: AppConfig.backendBaseUrl,
          currentUsername: _username,
          isOrganizer: _isOrganizer,
        ),
        const TicketingPage(),
        const MerchandisePage(),
        const ReviewPage(),
      ];

  void _onTabTapped(int index) {
    // Navbar indices mapping (bottom bar):
    // 0 => Schedule, 1 => Ticketing, 2 => Merchandise, 3 => Review
    // Map these to `_pages` indexes in the IndexedStack:
    // Schedule -> 1, Ticketing -> 2, Merchandise -> 3, Review -> 4
    int pageIndex;
    switch (index) {
      case 0:
        pageIndex = 1;
        break;
      case 1:
        pageIndex = 2;
        break;
      case 2:
        pageIndex = 3;
        break;
      case 3:
        pageIndex = 4;
        break;
      default:
        pageIndex = 0;
    }

    if (!mounted) return;
    setState(() {
      _currentIndex = pageIndex;
    });
  }

  void _goToHome() {
    setState(() {
      _currentIndex = 0; // Home is at index 0
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex > 0 ? _currentIndex - 1 : -1,
        onTap: _onTabTapped,
      ),
      floatingActionButton: _LogoFAB(onPressed: _goToHome),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.calendar_today_outlined,
                activeIcon: Icons.calendar_today_rounded,
                label: 'Schedule',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavBarItem(
                icon: Icons.confirmation_number_outlined,
                activeIcon: Icons.confirmation_number_rounded,
                label: 'Ticket',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              const SizedBox(width: 100), // Space for Logo FAB
              _NavBarItem(
                icon: Icons.shopping_bag_outlined,
                activeIcon: Icons.shopping_bag_rounded,
                label: 'Merch',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavBarItem(
                icon: Icons.star_outline_rounded,
                activeIcon: Icons.star_rounded,
                label: 'Review',
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.pacilBlueDarker1 : AppColors.neutral500;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoFAB extends StatelessWidget {
  const _LogoFAB({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.pacilBlueDarker1.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo-transparent.png',
                fit: BoxFit.cover,
                width: 88,
                height: 88,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.pacilBlueDarker1,
                        AppColors.pacilRedBase,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Icon(
                    Icons.home_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
