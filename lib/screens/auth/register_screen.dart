import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/color_scheme.dart';
import '../../core/constants/route_constants.dart';
import '../../core/utils/validation_utils.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _acceptTerms = false;
  double _passwordStrength = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _calculatePasswordStrength(String password) {
    double strength = 0;
    if (password.length >= 6) strength += 0.2;
    if (password.length >= 8) strength += 0.2;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.2;
    setState(() => _passwordStrength = strength);
  }

  Color _getStrengthColor() {
    if (_passwordStrength <= 0.2) return AppColors.error;
    if (_passwordStrength <= 0.4) return AppColors.warning;
    if (_passwordStrength <= 0.6) return AppColors.accent;
    if (_passwordStrength <= 0.8) return AppColors.secondary;
    return AppColors.success;
  }

  String _getStrengthText() {
    if (_passwordStrength <= 0.2) return 'Very Weak';
    if (_passwordStrength <= 0.4) return 'Weak';
    if (_passwordStrength <= 0.6) return 'Fair';
    if (_passwordStrength <= 0.8) return 'Strong';
    return 'Very Strong';
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      SnackbarUtils.showWarning(
        context,
        'Please accept the terms and conditions',
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: _phoneController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      SnackbarUtils.showSuccess(context, 'Registration successful!');
      Navigator.pushReplacementNamed(context, RouteConstants.dashboard);
    } else {
      SnackbarUtils.showError(
        context,
        authProvider.error ?? 'Registration failed. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
              AppColors.primary.withOpacity(0.8),
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildBackgroundPattern(),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: isDesktop
                      ? _buildDesktopLayout(size)
                      : _buildMobileLayout(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _PatternPainter(),
      ),
    );
  }

  Widget _buildDesktopLayout(Size size) {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: _buildFormContent(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: _buildFormContent(),
    );
  }

  Widget _buildFormContent() {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildBranding(isDesktop),
          const SizedBox(height: 32),
          _buildNameField(),
          const SizedBox(height: 16),
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildPhoneField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          if (_passwordController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildPasswordStrengthIndicator(),
          ],
          const SizedBox(height: 16),
          _buildConfirmPasswordField(),
          const SizedBox(height: 16),
          _buildTermsCheckbox(isDesktop),
          const SizedBox(height: 24),
          _buildRegisterButton(),
          const SizedBox(height: 24),
          _buildLoginLink(isDesktop),
        ],
      ),
    );
  }

  Widget _buildBranding(bool isDesktop) {
    return FadeInDown(
      delay: const Duration(milliseconds: 200),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDesktop
                    ? [AppColors.primary, AppColors.secondary]
                    : [Colors.white, Colors.white.withOpacity(0.9)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: (isDesktop ? AppColors.primary : Colors.black)
                      .withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              Icons.person_add_outlined,
              size: 35,
              color: isDesktop ? Colors.white : AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Create Account',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDesktop ? AppColors.textPrimary : Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Join ClaimPro and manage your claims easily',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: isDesktop
                  ? AppColors.textSecondary
                  : Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return FadeInLeft(
      delay: const Duration(milliseconds: 300),
      child: isDesktop
          ? CustomTextField(
              label: 'Full Name',
              hint: 'Enter your full name',
              controller: _nameController,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.person_outline,
              validator: (value) =>
                  ValidationUtils.validateRequired(value, 'Full name'),
            )
          : _buildMobileTextField(
              controller: _nameController,
              hint: 'Full Name',
              icon: Icons.person_outline,
              keyboardType: TextInputType.name,
              validator: (value) =>
                  ValidationUtils.validateRequired(value, 'Full name'),
            ),
    );
  }

  Widget _buildEmailField() {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return FadeInRight(
      delay: const Duration(milliseconds: 350),
      child: isDesktop
          ? CustomTextField(
              label: 'Email Address',
              hint: 'Enter your email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.email_outlined,
              validator: ValidationUtils.validateEmail,
            )
          : _buildMobileTextField(
              controller: _emailController,
              hint: 'Email Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: ValidationUtils.validateEmail,
            ),
    );
  }

  Widget _buildPhoneField() {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return FadeInLeft(
      delay: const Duration(milliseconds: 400),
      child: isDesktop
          ? CustomTextField(
              label: 'Phone Number',
              hint: 'Enter your 10-digit mobile number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.phone_outlined,
              validator: ValidationUtils.validatePhone,
            )
          : _buildMobileTextField(
              controller: _phoneController,
              hint: 'Phone Number (10 digits)',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: ValidationUtils.validatePhone,
            ),
    );
  }

  Widget _buildPasswordField() {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return FadeInRight(
      delay: const Duration(milliseconds: 450),
      child: isDesktop
          ? CustomTextField(
              label: 'Password',
              hint: 'Create a strong password',
              controller: _passwordController,
              obscureText: true,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.lock_outline,
              validator: (value) =>
                  ValidationUtils.validateMinLength(value, 6, 'Password'),
              onChanged: _calculatePasswordStrength,
            )
          : _buildMobileTextField(
              controller: _passwordController,
              hint: 'Password',
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (value) =>
                  ValidationUtils.validateMinLength(value, 6, 'Password'),
              onChanged: _calculatePasswordStrength,
            ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return FadeIn(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _passwordStrength,
              backgroundColor: isDesktop
                  ? AppColors.border
                  : Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(_getStrengthColor()),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Password Strength: ${_getStrengthText()}',
            style: TextStyle(
              fontSize: 12,
              color: isDesktop
                  ? _getStrengthColor()
                  : Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return FadeInLeft(
      delay: const Duration(milliseconds: 500),
      child: isDesktop
          ? CustomTextField(
              label: 'Confirm Password',
              hint: 'Re-enter your password',
              controller: _confirmPasswordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              prefixIcon: Icons.lock_outline,
              validator: _validateConfirmPassword,
              onSubmitted: (_) => _handleRegister(),
            )
          : _buildMobileTextField(
              controller: _confirmPasswordController,
              hint: 'Confirm Password',
              icon: Icons.lock_outline,
              obscureText: true,
              validator: _validateConfirmPassword,
            ),
    );
  }

  Widget _buildMobileTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.8)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error),
        ),
        errorStyle: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildTermsCheckbox(bool isDesktop) {
    return FadeIn(
      delay: const Duration(milliseconds: 550),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: _acceptTerms,
              onChanged: (value) {
                setState(() => _acceptTerms = value ?? false);
              },
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return isDesktop ? AppColors.primary : Colors.white;
                }
                return Colors.transparent;
              }),
              checkColor: isDesktop ? Colors.white : AppColors.primary,
              side: BorderSide(
                color: isDesktop
                    ? AppColors.border
                    : Colors.white.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                text: 'I agree to the ',
                style: TextStyle(
                  color: isDesktop
                      ? AppColors.textSecondary
                      : Colors.white.withOpacity(0.9),
                  fontSize: 13,
                ),
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: isDesktop ? AppColors.primary : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: isDesktop ? AppColors.primary : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return FadeInUp(
      delay: const Duration(milliseconds: 600),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return isDesktop
              ? CustomButton(
                  text: 'Create Account',
                  onPressed: authProvider.isLoading ? null : _handleRegister,
                  isLoading: authProvider.isLoading,
                  fullWidth: true,
                  size: ButtonSize.large,
                )
              : SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        authProvider.isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: authProvider.isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          )
                        : Text(
                            'Create Account',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                );
        },
      ),
    );
  }

  Widget _buildLoginLink(bool isDesktop) {
    return FadeIn(
      delay: const Duration(milliseconds: 700),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Already have an account? ',
            style: TextStyle(
              color: isDesktop
                  ? AppColors.textSecondary
                  : Colors.white.withOpacity(0.8),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Login',
              style: TextStyle(
                color: isDesktop ? AppColors.primary : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    const spacing = 60.0;
    const radius = 3.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
