import 'package:flutter/material.dart';

enum DeviceType {
  mobile,
  tablet,
  desktop,
}

enum ScreenSize {
  xs,
  sm,
  md,
  lg,
  xl,
}

class ResponsiveUtils {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;
  
  static const double xsBreakpoint = 320;
  static const double smBreakpoint = 480;
  static const double mdBreakpoint = 768;
  static const double lgBreakpoint = 1024;
  static const double xlBreakpoint = 1280;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width < tabletBreakpoint) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < xsBreakpoint) return ScreenSize.xs;
    if (width < smBreakpoint) return ScreenSize.sm;
    if (width < mdBreakpoint) return ScreenSize.md;
    if (width < lgBreakpoint) return ScreenSize.lg;
    return ScreenSize.xl;
  }

  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double safeAreaTop(BuildContext context) =>
      MediaQuery.of(context).padding.top;

  static double safeAreaBottom(BuildContext context) =>
      MediaQuery.of(context).padding.bottom;

  static EdgeInsets responsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    }
    return const EdgeInsets.all(32);
  }

  static EdgeInsets responsiveHorizontalPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24);
    }
    return const EdgeInsets.symmetric(horizontal: 48);
  }

  static EdgeInsets responsiveMargin(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(8);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(16);
    }
    return const EdgeInsets.all(24);
  }

  static double responsiveFontSize(BuildContext context, double baseFontSize) {
    if (isMobile(context)) {
      return baseFontSize;
    } else if (isTablet(context)) {
      return baseFontSize * 1.1;
    }
    return baseFontSize * 1.2;
  }

  static int responsiveGridColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }

  static double responsiveDialogWidth(BuildContext context) {
    final width = screenWidth(context);
    if (isMobile(context)) return width * 0.9;
    if (isTablet(context)) return width * 0.7;
    return 500;
  }

  static T responsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, bool isMobile, bool isTablet, bool isDesktop) builder;
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  })  : mobile = null,
        tablet = null,
        desktop = null;

  const ResponsiveBuilder.widgets({
    super.key,
    required Widget this.mobile,
    this.tablet,
    this.desktop,
  }) : builder = _defaultBuilder;

  static Widget _defaultBuilder(
      BuildContext context, bool isMobile, bool isTablet, bool isDesktop) {
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final isMobileDevice = ResponsiveUtils.isMobile(context);
    final isTabletDevice = ResponsiveUtils.isTablet(context);
    final isDesktopDevice = ResponsiveUtils.isDesktop(context);

    if (mobile != null) {
      if (isDesktopDevice) return desktop ?? tablet ?? mobile!;
      if (isTabletDevice) return tablet ?? mobile!;
      return mobile!;
    }

    return builder(context, isMobileDevice, isTabletDevice, isDesktopDevice);
  }
}

class ResponsiveConstraints extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final bool center;

  const ResponsiveConstraints({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.center = true,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: center ? child : Align(alignment: Alignment.topLeft, child: child),
      ),
    );
  }
}
