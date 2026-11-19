import 'package:material_ui/material_ui.dart';

import '../../../../core/errors/app_exception.dart';
import '../../data/repositories/auth_repository.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({
    required this.repository,
    required this.onAuthenticated,
    super.key,
  });

  final AuthRepository repository;
  final VoidCallback onAuthenticated;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isRegistering = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      if (_isRegistering) {
        await widget.repository.register(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (!mounted) return;
        setState(() {
          _isRegistering = false;
          _isSubmitting = false;
          _successMessage = 'The demo service accepted your account request. It does not save new accounts, so sign in with a demo account below.';
        });
        return;
      }

      await widget.repository.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      widget.onAuthenticated();
    } on AppException catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.message);
    } finally {
      if (mounted && _isSubmitting) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _switchMode() {
    setState(() {
      _isRegistering = !_isRegistering;
      _errorMessage = null;
      _successMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.spa_outlined,
                        size: 30,
                        color: colors.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isRegistering ? 'Create your account' : 'Welcome back',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isRegistering
                          ? 'Join Field & Form to explore the collection.'
                          : 'Sign in to browse the Field & Form collection.',
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 28),
                    if (_successMessage != null) ...[
                      _Notice(message: _successMessage!, isError: false),
                      const SizedBox(height: 16),
                    ],
                    if (_errorMessage != null) ...[
                      _Notice(message: _errorMessage!, isError: true),
                      const SizedBox(height: 16),
                    ],
                    if (_isRegistering) ...[
                      _textField(
                        controller: _firstNameController,
                        label: 'First name',
                        validator: _requiredValidator('Enter your first name.'),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                      _textField(
                        controller: _lastNameController,
                        label: 'Last name',
                        validator: _requiredValidator('Enter your last name.'),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                    ],
                    _textField(
                      controller: _usernameController,
                      label: 'Username',
                      validator: _validateUsername,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                    ),
                    if (_isRegistering) ...[
                      const SizedBox(height: 16),
                      _textField(
                        controller: _emailController,
                        label: 'Email',
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                      ),
                    ],
                    const SizedBox(height: 16),
                    _passwordField(
                      controller: _passwordController,
                      label: 'Password',
                      visible: _isPasswordVisible,
                      onVisibilityChanged: () => setState(
                        () => _isPasswordVisible = !_isPasswordVisible,
                      ),
                      validator: _validatePassword,
                      autofillHints: [
                        _isRegistering
                            ? AutofillHints.newPassword
                            : AutofillHints.password,
                      ],
                    ),
                    if (_isRegistering) ...[
                      const SizedBox(height: 16),
                      _passwordField(
                        controller: _confirmPasswordController,
                        label: 'Confirm password',
                        visible: _isConfirmPasswordVisible,
                        onVisibilityChanged: () => setState(
                          () => _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Confirm your password.';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match.';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isRegistering ? 'Create account' : 'Sign in',
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _isSubmitting ? null : _switchMode,
                      child: Text(
                        _isRegistering
                            ? 'Already have an account? Sign in'
                            : 'New here? Create an account',
                      ),
                    ),
                    if (!_isRegistering) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withValues(
                            alpha: 0.55,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Demo login: emilys / emilyspass',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Iterable<String>? autofillHints,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      autofillHints: autofillHints,
      enabled: !_isSubmitting,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool visible,
    required VoidCallback onVisibilityChanged,
    required String? Function(String?) validator,
    Iterable<String>? autofillHints,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: !visible,
      autofillHints: autofillHints,
      enabled: !_isSubmitting,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        suffixIcon: IconButton(
          tooltip: visible ? 'Hide password' : 'Show password',
          onPressed: onVisibilityChanged,
          icon: Icon(visible ? Icons.visibility_off : Icons.visibility),
        ),
      ),
    );
  }

  String? Function(String?) _requiredValidator(String message) => (value) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  };

  String? _validateUsername(String? value) {
    final username = value?.trim() ?? '';
    if (username.isEmpty) return 'Enter your username.';
    if (username.length < 3) return 'Username must be at least 3 characters.';
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email address.';
    if (!RegExp(r'^[\w.!#$%&’*+/=?^`{|}~-]+@[\w-]+(?:\.[\w-]+)+$')
        .hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter your password.';
    if (_isRegistering && value.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    return null;
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = isError ? colors.error : colors.primary;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(message, style: TextStyle(color: color)),
    );
  }
}
