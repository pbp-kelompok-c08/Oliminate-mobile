import 'package:flutter/material.dart';

import 'package:oliminate_mobile/core/theme/app_colors.dart';
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

  bool _loading = false;
  bool _error = false;
  bool _empty = false;
  String _filter = 'all';
  List<Schedule> _items = <Schedule>[];

  @override
  void initState() {
    super.initState();
    _api = SchedulingApiService(
      baseUrl: widget.baseUrl,
      defaultHeaders: widget.authHeaders ?? <String, String>{},
    );
    _fetchList();
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
    if (!widget.isOrganizer && initial == null) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Pertandingan'),
        backgroundColor: AppColors.pacilBlueDarker2,
      ),
      backgroundColor: AppColors.neutral50,
      floatingActionButton: widget.isOrganizer
          ? FloatingActionButton.extended(
              onPressed: () => _openForm(),
              backgroundColor: AppColors.pacilBlueDarker2,
              icon: const Icon(Icons.add),
              label: const Text('Buat Jadwal'),
            )
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
                    ? const SizedBox.shrink()
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
                                singleColumn ? 0.9 : 0.95,
                            mainAxisExtent: singleColumn ? 520 : null,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Jadwal Pertandingan',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  ChoiceChip(
                    label: const Text('Semua'),
                    selected: _filter == 'all',
                    selectedColor: AppColors.pacilBlueLight3,
                    onSelected: (bool v) {
                      if (!v) return;
                      setState(() {
                        _filter = 'all';
                      });
                      _fetchList();
                    },
                  ),
                  ChoiceChip(
                    label: const Text('Jadwal Saya'),
                    selected: _filter == 'mine',
                    selectedColor: AppColors.pacilBlueLight3,
                    onSelected: (bool v) {
                      if (!v) return;
                      setState(() {
                        _filter = 'mine';
                      });
                      _fetchList();
                    },
                  ),
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: () => _fetchList(showSnack: true),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
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


