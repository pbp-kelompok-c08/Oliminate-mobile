import 'package:flutter/material.dart';
import 'package:oliminate_mobile/core/app_config.dart';
import 'package:oliminate_mobile/features/user-profile/auth_repository.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  static const String routeName = '/edit-profile';

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  static const Color _muted = Color(0xFF6B7280);
  static const Color _baseBlue = Color(0xFF3293EC);
  static const Color _navy = Color(0xFF113352);

  final _authRepo = AuthRepository.instance;

  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedFaculty;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  String? _profilePicturePath;
  String? _profileImageUrl;

  final List<String> _faculties = const [
    'Kedokteran',
    'Kedokteran Gigi',
    'Matematika dan Ilmu Pengetahuan Alam',
    'Teknik',
    'Hukum',
    'Ekonomi dan Bisnis',
    'Ilmu Pengetahuan Budaya',
    'Psikologi',
    'Ilmu Sosial dan Ilmu Politik',
    'Kesehatan Masyarakat',
    'Ilmu Komputer',
    'Ilmu Keperawatan',
    'Pendidikan Vokasi',
    'Farmasi',
    'Ilmu Administrasi',
    'Ilmu Lingkungan',
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    await _authRepo.init();
    final data = await _authRepo.fetchProfileFromEdit() ?? await _authRepo.fetchProfile();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (data != null) {
        _usernameController.text = data.username;
        _firstNameController.text = data.firstName;
        _lastNameController.text = data.lastName;
        _emailController.text = data.email;
        _selectedFaculty = data.fakultas.isEmpty ? null : data.fakultas;
        _profileImageUrl =
            data.profilePictureUrl.isNotEmpty ? data.profilePictureUrl : _authRepo.cachedProfile?.profilePictureUrl;
      } else {
        _error = 'Gagal memuat data profil. Pastikan sudah login.';
      }
    });
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    final res = await _authRepo.updateProfile(
      ProfileUpdate(
        username: _usernameController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        fakultas: _selectedFaculty ?? '',
        password: _passwordController.text,
        profilePicturePath: _profilePicturePath,
      ),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (res.success) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Profil berhasil diperbarui.')));
        Navigator.of(context).pop();
      }
    } else {
      setState(() => _error = res.message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.message ?? 'Gagal menyimpan perubahan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String? _resolveImage(String? path) {
      if (path == null || path.isEmpty) return null;
      if (path.startsWith('http')) return path;
      return '${AppConfig.backendBaseUrl}$path';
    }

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                    'Edit Profile',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: _navy,
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      children: [
                        _AvatarPlaceholder(
                          accent: _baseBlue,
                          navy: _navy,
                          imageUrl: _resolveImage(_profileImageUrl),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: _baseBlue.withOpacity(0.35)),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {},
                          child: Text(
                            'Edit Picture',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: _baseBlue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Max 2MB. JPG/PNG',
                          style: theme.textTheme.bodySmall?.copyWith(color: _muted),
                        ),
                        const SizedBox(height: 22),
                        _FormField(
                          label: 'Username',
                          controller: _usernameController,
                          hint: 'Isi username',
                        ),
                        const SizedBox(height: 16),
                        _FormField(
                          label: 'First Name',
                          controller: _firstNameController,
                          hint: 'Isi nama depan',
                        ),
                        const SizedBox(height: 16),
                        _FormField(
                          label: 'Last Name',
                          controller: _lastNameController,
                          hint: 'Isi nama belakang',
                        ),
                        const SizedBox(height: 16),
                        _FormField(
                          label: 'Email',
                          controller: _emailController,
                          hint: 'Isi email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Faculty',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedFaculty,
                          decoration: const InputDecoration(isDense: true),
                          hint: Text(
                            'Choose Origin Faculty...',
                            style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF9CA3AF)),
                          ),
                          items: _faculties
                              .map(
                                (f) => DropdownMenuItem<String>(
                                  value: f,
                                  child: Text(f, overflow: TextOverflow.ellipsis),
                                ),
                              )
                              .toList(),
                          onChanged: (val) => setState(() => _selectedFaculty = val),
                        ),
                        const SizedBox(height: 16),
                        _FormField(
                          label: 'New Password',
                          controller: _passwordController,
                          hint: 'Fill with old password if unchanged',
                          obscure: true,
                        ),
                        const SizedBox(height: 22),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red.shade700),
                            ),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  side: BorderSide(color: _baseBlue.withOpacity(0.24)),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  'Cancel',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: _baseBlue,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: _baseBlue,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 8,
                                  shadowColor: _baseBlue.withOpacity(0.28),
                                ),
                                onPressed: _isSaving ? null : _save,
                                child: Text(
                                  _isSaving ? 'Saving...' : 'Save',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.obscure = false,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscure;

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
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
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
