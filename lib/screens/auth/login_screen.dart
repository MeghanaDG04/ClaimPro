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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, RouteConstants.dashboard);
    } else {
      SnackbarUtils.showError(
        context,
        authProvider.error ?? 'Login failed. Please try again.',
      );
    }
  }

  void _handleForgotPassword() {
    SnackbarUtils.showInfo(
      context,
      'Password reset link will be sent to your email.',
    );
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
        width: 450,
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
          const SizedBox(height: 40),
          _buildEmailField(),
          const SizedBox(height: 20),
          _buildPasswordField(),
          const SizedBox(height: 16),
          _buildRememberMeRow(),
          const SizedBox(height: 24),
          _buildLoginButton(),
          const SizedBox(height: 24),
          _buildRegisterLink(isDesktop),
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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDesktop
                    ? [AppColors.primary, AppColors.secondary]
                    : [Colors.white, Colors.white.withOpacity(0.9)],
              ),
              borderRadius: BorderRadius.circular(20),
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
              Icons.shield_outlined,
              size: 40,
              color: isDesktop ? Colors.white : AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'ClaimPro',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isDesktop ? AppColors.textPrimary : Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your trusted insurance claim partner',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isDesktop
                  ? AppColors.textSecondary
                  : Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return FadeInLeft(
      delay: const Duration(milliseconds: 300),
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

  Widget _buildPasswordField() {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return FadeInRight(
      delay: const Duration(milliseconds: 400),
      child: isDesktop
          ? CustomTextField(
              label: 'Password',
              hint: 'Enter your password',
              controller: _passwordController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              prefixIcon: Icons.lock_outline,
              validator: (value) =>
                  ValidationUtils.validateMinLength(value, 6, 'Password'),
              onSubmitted: (_) => _handleLogin(),
            )
          : _buildMobileTextField(
              controller: _passwordController,
              hint: 'Password',
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (value) =>
                  ValidationUtils.validateMinLength(value, 6, 'Password'),
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
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
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

  Widget _buildRememberMeRow() {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return FadeIn(
      delay: const Duration(milliseconds: 500),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _rememberMe,
                  onChanged: (value) {
                    setState(() => _rememberMe = value ?? false);
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
              const SizedBox(width: 8),
              Text(
                'Remember me',
                style: TextStyle(
                  color: isDesktop
                      ? AppColors.textSecondary
                      : Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: _handleForgotPassword,
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                color: isDesktop ? AppColors.primary : Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return FadeInUp(
      delay: const Duration(milliseconds: 600),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return isDesktop
              ? CustomButton(
                  text: 'Login',
                  onPressed: authProvider.isLoading ? null : _handleLogin,
                  isLoading: authProvider.isLoading,
                  fullWidth: true,
                  size: ButtonSize.large,
                )
              : SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        authProvider.isLoading ? null : _handleLogin,
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
                            'Login',
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

  Widget _buildRegisterLink(bool isDesktop) {
    return FadeIn(
      delay: const Duration(milliseconds: 700),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: TextStyle(
              color: isDesktop
                  ? AppColors.textSecondary
                  : Colors.white.withOpacity(0.8),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, RouteConstants.register);
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Register',
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
