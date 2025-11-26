import 'package:flutter/material.dart';
import 'package:oliminate_mobile/features/user-profile/auth_repository.dart';
import 'package:oliminate_mobile/features/user-profile/login.dart';

const Color kAuthBlue = Color(0xFF22629E);
const Color kAuthRed = Color(0xFF9E292D);
const Color kAuthNavy = Color(0xFF113352);
const Color kAuthMuted = Color(0xFF6B7280);

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, this.onLoginTap});

  static const String routeName = '/register';

  final VoidCallback? onLoginTap;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authRepo = AuthRepository.instance;

  final List<String> _roleOptions = const ['User', 'Organizer'];
  String _selectedRole = 'User';

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kAuthBlue, kAuthRed],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 26,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Register',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: kAuthNavy,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _LabeledField(
                              label: 'Username',
                              controller: _usernameController,
                              autofillHints: const [AutofillHints.username],
                            ),
                            const SizedBox(height: 14),
                            _LabeledField(
                              label: 'First Name',
                              controller: _firstNameController,
                              autofillHints: const [AutofillHints.givenName],
                            ),
                            const SizedBox(height: 14),
                            _LabeledField(
                              label: 'Last Name',
                              controller: _lastNameController,
                              autofillHints: const [AutofillHints.familyName],
                            ),
                            const SizedBox(height: 14),
                            _LabeledField(
                              label: 'Email',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                            ),
                            const SizedBox(height: 14),
                            _LabeledField(
                              label: 'Password',
                              controller: _passwordController,
                              obscure: true,
                              autofillHints: const [AutofillHints.newPassword],
                            ),
                            const SizedBox(height: 14),
                            _LabeledField(
                              label: 'Phone number',
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              autofillHints: const [
                                AutofillHints.telephoneNumber,
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Register as',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF183D5C),
                              ),
                            ),
                            const SizedBox(height: 8),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE6EDF6),
                                ),
                              ),
                              child: DropdownButtonFormField<String>(
                                value: _selectedRole,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.black54,
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 14,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                items: _roleOptions
                                    .map(
                                      (role) => DropdownMenuItem<String>(
                                        value: role,
                                        child: Text(role),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() => _selectedRole = value);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: 22),
                            _GradientButton(
                              label: 'Submit',
                              isLoading: _isLoading,
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      if (!(_formKey.currentState?.validate() ??
                                          false))
                                        return;
                                      FocusScope.of(context).unfocus();
                                      setState(() {
                                        _isLoading = true;
                                        _error = null;
                                      });

                                      final res = await _authRepo.register(
                                        username: _usernameController.text
                                            .trim(),
                                        firstName: _firstNameController.text
                                            .trim(),
                                        lastName: _lastNameController.text
                                            .trim(),
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text
                                            .trim(),
                                        phoneNumber: _phoneController.text
                                            .trim(),
                                        role: _selectedRole.toLowerCase(),
                                      );

                                      if (!mounted) return;
                                      setState(() => _isLoading = false);
                                      if (res.success) {
                                        final successMessage =
                                            res.message ??
                                                'Registrasi berhasil. Silakan login.';
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(successMessage),
                                          ),
                                        );
                                        if (widget.onLoginTap != null) {
                                          widget.onLoginTap!.call();
                                        } else {
                                          Navigator.of(context)
                                              .pushReplacementNamed(
                                            LoginPage.routeName,
                                          );
                                        }
                                      } else {
                                        setState(() => _error = res.message);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              res.message ?? 'Registrasi gagal',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (_error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: [
                            Text(
                              'Already have account?',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: kAuthMuted,
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                if (widget.onLoginTap != null) {
                                  widget.onLoginTap!.call();
                                  return;
                                }
                                if (!mounted) return;
                                Navigator.of(
                                  context,
                                ).pushReplacementNamed(LoginPage.routeName);
                              },
                              child: Text(
                                'Login here',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: kAuthBlue,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
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
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.obscure = false,
    this.autofillHints,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscure;
  final Iterable<String>? autofillHints;

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
            color: const Color(0xFF183D5C),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          autofillHints: autofillHints,
          validator: (value) => (value == null || value.trim().isEmpty)
              ? '$label is required'
              : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE6EDF6)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE6EDF6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kAuthBlue),
            ),
          ),
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kAuthBlue, kAuthRed],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
