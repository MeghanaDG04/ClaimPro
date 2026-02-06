import 'package:flutter/material.dart';
import '../core/constants/route_constants.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/create_claim/create_claim_screen.dart';
import '../screens/claim_details/claim_details_screen.dart';
import '../screens/bills/bills_screen.dart';
import '../screens/advances/advances_screen.dart';
import '../screens/settlement/settlement_screen.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.login:
        return _buildRoute(const LoginScreen(), settings);

      case RouteConstants.register:
        return _buildRoute(const RegisterScreen(), settings);

      case RouteConstants.dashboard:
        return _buildRoute(const DashboardScreen(), settings);

      case RouteConstants.createClaim:
        return _buildRoute(const CreateClaimScreen(), settings);

      case RouteConstants.editClaim:
        final claimId = settings.arguments as String?;
        return _buildRoute(
          CreateClaimScreen(claimId: claimId),
          settings,
        );

      case RouteConstants.claimDetails:
        final claimId = settings.arguments as String;
        return _buildRoute(
          ClaimDetailsScreen(claimId: claimId),
          settings,
        );

      case RouteConstants.bills:
        final claimId = settings.arguments as String;
        return _buildRoute(
          BillsScreen(claimId: claimId),
          settings,
        );

      case RouteConstants.advances:
        final claimId = settings.arguments as String;
        return _buildRoute(
          AdvancesScreen(claimId: claimId),
          settings,
        );

      case RouteConstants.settlement:
        final claimId = settings.arguments as String;
        return _buildRoute(
          SettlementScreen(claimId: claimId),
          settings,
        );

      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
          settings,
        );
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

  static void navigateTo(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void navigateAndReplace(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void navigateAndClearStack(BuildContext context, String routeName, {Object? arguments}) {
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
}
