import 'package:flutter/material.dart';

import 'package:oliminate_mobile/core/theme/app_colors.dart';
import 'package:oliminate_mobile/features/user-profile/auth_repository.dart';
import 'package:oliminate_mobile/features/user-profile/main_profile.dart';
import '../../data/datasources/scheduling_api_service.dart';
import '../../data/models/schedule.dart';
import '../widgets/schedule_card.dart';
import '../widgets/schedule_form_dialog.dart';
import 'schedule_detail_page.dart';

class SchedulingPage extends StatefulWidget {
  const SchedulingPage({
    super.key,
    required this.baseUrl,
    this.currentUsername,
    this.isOrganizer = false,
    this.authHeaders,
  });

  final String baseUrl;
  final String? currentUsername;
  final bool isOrganizer;
  final Map<String, String>? authHeaders;

  @override
  State<SchedulingPage> createState() => _SchedulingPageState();
}

class _SchedulingPageState extends State<SchedulingPage> {
  late final SchedulingApiService _api;
  final _authRepo = AuthRepository.instance;

  bool _loading = false;
  bool _error = false;
  bool _empty = false;
  String _filter = 'all';
  List<Schedule> _items = <Schedule>[];
  bool _isOrganizer = false;

  @override
  void initState() {
    super.initState();
    _api = SchedulingApiService(
      baseUrl: widget.baseUrl,
      djangoClient: _authRepo.client,
    );
    _checkOrganizerRole();
    _fetchList();
  }

  Future<void> _checkOrganizerRole() async {
    await _authRepo.init();
    final profile = _authRepo.cachedProfile ?? await _authRepo.fetchProfile();
    if (!mounted) return;
    setState(() {
      _isOrganizer = profile?.role.toLowerCase().contains('organizer') ?? false;
    });
  }

  Future<void> _fetchList({bool showSnack = false}) async {
    setState(() {
      _loading = true;
      _error = false;
      _empty = false;
    });

    try {
      final List<Schedule> data = await _api.fetchList(filter: _filter);
      if (!mounted) return;
      setState(() {
        _items = data;
        _empty = data.isEmpty;
      });
      if (showSnack) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jadwal berhasil di-refresh')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Error fetching schedule list: $e');
      setState(() {
        _error = true;
      });
      if (showSnack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat jadwal: ${e.toString()}'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _openForm({Schedule? initial}) async {
    if (!_isOrganizer && initial == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hanya organizer yang dapat membuat jadwal.'),
        ),
      );
      return;
    }

    final ScheduleFormResult? result =
        await showDialog<ScheduleFormResult>(
      context: context,
      builder: (_) => ScheduleFormDialog(initial: initial),
    );

    if (result == null) return;

    try {
      if (initial == null) {
        await _api.createSchedule(result.toFormBody());
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jadwal berhasil dibuat')),
        );
      } else {
        await _api.updateSchedule(initial.id, result.toFormBody());
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jadwal berhasil diupdate')),
        );
      }
      await _fetchList();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan jadwal: $e')),
      );
    }
  }

  Future<void> _confirmDelete(Schedule s) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Jadwal'),
        content: const Text('Yakin ingin menghapus jadwal ini?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pacilRedBase,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await _api.deleteSchedule(s.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jadwal terhapus')),
      );
      await _fetchList();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus jadwal')),
      );
    }
  }

  Future<void> _makeCompleted(Schedule s) async {
    try {
      final Map<String, dynamic> res = await _api.makeCompleted(s.id);
      if (!mounted) return;

      if (res['ok'] != true) {
        final Map<String, dynamic>? errors =
            res['errors'] as Map<String, dynamic>?;
        final Object? general = errors != null ? errors['__all__'] : null;
        final String msg =
            general?.toString() ?? 'Gagal menandai completed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (res['message'] ?? 'Ditandai completed').toString(),
          ),
        ),
      );
      await _fetchList();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan jaringan')),
      );
    }
  }

  Future<void> _makeReviewable(Schedule s) async {
    try {
      final Map<String, dynamic> res = await _api.makeReviewable(s.id);
      if (!mounted) return;

      if (res['ok'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menandai reviewable')),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (res['message'] ?? 'Ditandai reviewable').toString(),
          ),
        ),
      );
      await _fetchList();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan jaringan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Color palette matching ticketing design
    const Color primaryDark = Color(0xFF113352);
    const Color neutralBg = Color(0xFFF5F5F5);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Jadwal Pertandingan',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        automaticallyImplyLeading: false,
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
      backgroundColor: neutralBg,
      floatingActionButton: _isOrganizer
          ? _CreateScheduleFAB(onPressed: () => _openForm())
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              _buildHeaderControls(),
              const SizedBox(height: 8),
              _buildStateText(),
              const SizedBox(height: 12),
              Expanded(
                child: _items.isEmpty && !_loading
                    ? _buildEmptyState()
                    : LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints c) {
                          final int crossAxisCount;
                          if (c.maxWidth > 900) {
                            crossAxisCount = 3;
                          } else if (c.maxWidth > 600) {
                            crossAxisCount = 2;
                          } else {
                            crossAxisCount = 1;
                          }

                          final bool singleColumn = crossAxisCount == 1;
                          final SliverGridDelegateWithFixedCrossAxisCount
                              gridDelegate =
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio:
                                singleColumn ? 0.75 : 0.85,
                            mainAxisExtent: singleColumn ? 420 : null,
                          );

                          return RefreshIndicator(
                            onRefresh: () => _fetchList(),
                            child: GridView.builder(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              gridDelegate: gridDelegate,
                              itemCount: _items.length,
                              itemBuilder:
                                  (BuildContext context, int index) {
                                final Schedule s = _items[index];
                                final bool isOwner =
                                    s.organizer != null &&
                                        widget.currentUsername != null &&
                                        s.organizer ==
                                            widget.currentUsername;

                                return ScheduleCard(
                                  schedule: s,
                                  isOwner: isOwner,
                                  onEdit: () => _openForm(initial: s),
                                  onDelete: () => _confirmDelete(s),
                                  onCompleted: () => _makeCompleted(s),
                                  onReviewable: () =>
                                      _makeReviewable(s),
                                  onDetail: () => _openDetail(s),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(Schedule s) {
    final bool isOwner =
        s.organizer != null &&
            widget.currentUsername != null &&
            s.organizer == widget.currentUsername;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ScheduleDetailPage(
          schedule: s,
          isOwner: isOwner,
          onEdit: isOwner
              ? () {
                  Navigator.of(context).pop();
                  _openForm(initial: s);
                }
              : null,
          onDelete: isOwner
              ? () {
                  Navigator.of(context).pop();
                  _confirmDelete(s);
                }
              : null,
        ),
      ),
    );
  }

  Widget _buildHeaderControls() {
    return Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
                _FilterChip(
                  label: 'Semua',
                  isSelected: _filter == 'all',
                  onSelected: () {
                    setState(() {
                      _filter = 'all';
                    });
                    _fetchList();
                  },
                ),
                _FilterChip(
                  label: 'Jadwal Saya',
                  isSelected: _filter == 'mine',
                  onSelected: () {
                    setState(() {
                      _filter = 'mine';
                    });
                    _fetchList();
                  },
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    tooltip: 'Refresh',
                    onPressed: () => _fetchList(showSnack: true),
                    icon: const Icon(Icons.refresh_rounded),
                    color: AppColors.pacilBlueDarker1,
                  ),
                ),
          ],
        );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.pacilBlueDarker1.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: AppColors.pacilBlueDarker1.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum ada jadwal',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai buat jadwal pertandingan pertama Anda',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.neutral500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStateText() {
    if (_loading) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Memuat data jadwal…',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.neutral700,
          ),
        ),
      );
    }
    if (_error) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Terjadi error saat memuat jadwal.',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.pacilRedBase,
          ),
        ),
      );
    }
    if (_empty) {
      return const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Belum ada jadwal pertandingan.',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.neutral500,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  // Color palette matching ticketing design
  static const Color _primaryDark = Color(0xFF113352);
  static const Color _primaryBlue = Color(0xFF3293EC);
  static const Color _textGrey = Color(0xFF3D3D3D);
  static const Color _borderLight = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? _primaryDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? _primaryDark : _borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onSelected,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : _textGrey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CreateScheduleFAB extends StatelessWidget {
  const _CreateScheduleFAB({required this.onPressed});

  final VoidCallback onPressed;

  // Color palette matching ticketing design
  static const Color _accentTeal = Color(0xFF0D9488);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: _accentTeal,
        boxShadow: [
          BoxShadow(
            color: _accentTeal.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.add_rounded,
                  size: 22,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text(
                  'Buat Jadwal',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


