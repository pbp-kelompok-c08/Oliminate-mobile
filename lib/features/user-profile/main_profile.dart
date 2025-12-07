import 'package:flutter/material.dart';
import 'package:oliminate_mobile/core/app_config.dart';
import 'package:oliminate_mobile/features/user-profile/auth_repository.dart';
import 'package:oliminate_mobile/features/user-profile/login.dart';
import 'edit_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  static const String routeName = '/profile';

  static const Color _muted = Color(0xFF6B7280);
  static const Color _baseBlue = Color(0xFF3293EC);
  static const Color _navy = Color(0xFF113352);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authRepo = AuthRepository.instance;
  ProfileData? _profile;
  bool _loading = true;
  String? _error;
  bool _loggingOut = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _authRepo.init();
    final ok = await _authRepo.validateSession();
    if (!mounted) return;
    if (!ok) {
      setState(() {
        _loading = false;
        _error = 'Sesi berakhir, silakan login ulang.';
      });
      return;
    }
    final data = await _authRepo.fetchProfile();
    if (!mounted) return;
    setState(() {
      _profile = data;
      _loading = false;
      _error = data == null ? 'Profil tidak bisa dimuat.' : null;
    });
  }

  Future<void> _logout() async {
    setState(() {
      _loggingOut = true;
    });
    await _authRepo.logout();
    if (!mounted) return;
    setState(() {
      _loggingOut = false;
    });
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  String? _resolveImage(String path) {
    if (path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    return '${AppConfig.backendBaseUrl}$path';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_profile == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error ?? 'Profil tidak tersedia.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _load,
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final p = _profile!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'User Profile',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: ProfilePage._navy,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 24,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _AvatarPlaceholder(
                          accent: ProfilePage._baseBlue,
                          navy: ProfilePage._navy,
                          imageUrl: _resolveImage(p.profilePictureUrl),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${p.firstName} ${p.lastName}'.trim(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: ProfilePage._navy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.role.isEmpty ? 'Role belum diisi' : p.role,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: ProfilePage._muted),
                        ),
                        const SizedBox(height: 22),
                        _ProfileField(label: 'Username', value: p.username),
                        const SizedBox(height: 16),
                        _ProfileField(label: 'First Name', value: p.firstName),
                        const SizedBox(height: 16),
                        _ProfileField(label: 'Last Name', value: p.lastName),
                        const SizedBox(height: 16),
                        _ProfileField(
                          label: 'Email',
                          value: p.email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        _ProfileField(label: 'Faculty', value: p.fakultas),
                        const SizedBox(height: 16),
                        const _ProfileField(
                            label: 'Password', value: '********', obscure: true),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const EditProfilePage(),
                                ),
                              );
                              if (mounted) _load();
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: ProfilePage._baseBlue,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 8,
                              shadowColor:
                                  ProfilePage._baseBlue.withOpacity(0.28),
                            ),
                            child: Text(
                              'Edit Profile',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _loggingOut ? null : _logout,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              side: BorderSide(
                                  color: ProfilePage._baseBlue.withOpacity(0.35)),
                            ),
                            child: Text(
                              _loggingOut ? 'Logging out...' : 'Logout',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: ProfilePage._baseBlue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    '© 2025 Oliminate',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: ProfilePage._navy),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.value,
    this.obscure = false,
    this.keyboardType,
  });

  final String label;
  final String value;
  final bool obscure;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value.isEmpty ? null : value,
          readOnly: true,
          obscureText: obscure,
          enableInteractiveSelection: false,
          keyboardType: keyboardType,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF111827),
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: value.isEmpty ? 'Belum diisi' : null,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF9CA3AF)),
          ),
        ),
      ],
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder({
    required this.accent,
    required this.navy,
    this.imageUrl,
  });

  final Color accent;
  final Color navy;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [navy, accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: CircleAvatar(
        radius: 52,
        backgroundColor: const Color(0xFFE9EEF5),
        backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
        child: imageUrl == null
            ? Icon(Icons.person, size: 54, color: navy.withOpacity(0.62))
            : null,
      ),
    );
  }
}
