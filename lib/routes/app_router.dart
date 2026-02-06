import 'package:flutter/material.dart';
import '../core/constants/route_constants.dart';
import '../services/storage_service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/create_claim/create_claim_screen.dart';
import '../screens/claim_details/claim_details_screen.dart';
import '../screens/bills/bills_screen.dart';
import '../screens/advances/advances_screen.dart';
import '../screens/settlement/settlement_screen.dart';

class AppRouter {
  static final Set<String> _publicRoutes = {
    RouteConstants.login,
    RouteConstants.register,
    RouteConstants.forgotPassword,
    RouteConstants.resetPassword,
    RouteConstants.splash,
  };

  static bool _isAuthenticated() {
    return StorageService.isLoggedIn();
  }

  static bool _requiresAuth(String? routeName) {
    if (routeName == null) return true;
    return !_publicRoutes.contains(routeName);
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    if (_requiresAuth(settings.name) && !_isAuthenticated()) {
      return _buildRoute(
        const LoginScreen(),
        const RouteSettings(name: RouteConstants.login),
      );
    }

    switch (settings.name) {
      case RouteConstants.splash:
        return _buildRoute(
          _isAuthenticated() ? const DashboardScreen() : const LoginScreen(),
          settings,
        );

      case RouteConstants.login:
        return _buildRoute(const LoginScreen(), settings);

      case RouteConstants.register:
        return _buildRoute(const RegisterScreen(), settings);

      case RouteConstants.dashboard:
      case RouteConstants.home:
        return _buildRoute(const DashboardScreen(), settings);

      case RouteConstants.createClaim:
        return _buildRoute(const CreateClaimScreen(), settings);

      case RouteConstants.editClaim:
        final args = settings.arguments;
        final claimId = args is String ? args : (args is Map ? args['claimId'] as String? : null);
        return _buildRoute(
          CreateClaimScreen(claimId: claimId),
          settings,
        );

      case RouteConstants.claimDetails:
        final args = settings.arguments;
        final claimId = args is String ? args : (args is Map ? args['claimId'] as String : '');
        if (claimId.isEmpty) {
          return _buildNotFoundRoute(settings);
        }
        return _buildRoute(
          ClaimDetailsScreen(claimId: claimId),
          settings,
        );

      case RouteConstants.bills:
        final args = settings.arguments;
        final claimId = args is String ? args : (args is Map ? args['claimId'] as String : '');
        if (claimId.isEmpty) {
          return _buildNotFoundRoute(settings);
        }
        return _buildRoute(
          BillsScreen(claimId: claimId),
          settings,
        );

      case RouteConstants.advances:
        final args = settings.arguments;
        final claimId = args is String ? args : (args is Map ? args['claimId'] as String : '');
        if (claimId.isEmpty) {
          return _buildNotFoundRoute(settings);
        }
        return _buildRoute(
          AdvancesScreen(claimId: claimId),
          settings,
        );

      case RouteConstants.settlement:
        final args = settings.arguments;
        final claimId = args is String ? args : (args is Map ? args['claimId'] as String : '');
        if (claimId.isEmpty) {
          return _buildNotFoundRoute(settings);
        }
        return _buildRoute(
          SettlementScreen(claimId: claimId),
          settings,
        );

      default:
        return _buildNotFoundRoute(settings);
    }
  }

  static PageRouteBuilder<dynamic> _buildRoute(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static PageRouteBuilder<dynamic> _buildNotFoundRoute(RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => Scaffold(
        appBar: AppBar(
          title: const Text('Page Not Found'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                '404',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Route not found: ${settings.name}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => navigateAndClearStack(
                  context,
                  RouteConstants.dashboard,
                ),
                icon: const Icon(Icons.home),
                label: const Text('Go to Dashboard'),
              ),
            ],
          ),
        ),
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  // Navigation helper methods
  static void navigateTo(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void navigateAndReplace(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void navigateAndClearStack(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void pop(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }

  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }

  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }

  static Future<T?> navigateToAndAwait<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }
}

class RouteArguments {
  final String? claimId;
  final String? billId;
  final String? advanceId;
  final Map<String, dynamic>? extra;

  const RouteArguments({
    this.claimId,
    this.billId,
    this.advanceId,
    this.extra,
  });
}
