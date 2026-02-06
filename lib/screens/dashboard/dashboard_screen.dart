import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

import '../../providers/claim_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/color_scheme.dart';
import '../../core/constants/route_constants.dart';
import '../../widgets/responsive_layout.dart';
import 'dashboard_content.dart';
import 'sidebar_menu.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedNavIndex = 0;
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClaimProvider>().loadClaims();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > ResponsiveLayout.tabletBreakpoint) {
          return _buildDesktopLayout();
        } else if (constraints.maxWidth >= ResponsiveLayout.mobileBreakpoint) {
          return _buildTabletLayout();
        } else {
          return _buildMobileLayout();
        }
      },
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      drawer: DrawerMenu(
        selectedIndex: _selectedNavIndex,
        onItemSelected: _handleNavigation,
      ),
      body: const DashboardContent(),
      floatingActionButton: _buildFAB(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedNavIndex,
            onDestinationSelected: _handleNavigation,
            labelType: NavigationRailLabelType.selected,
            backgroundColor: Colors.white,
            leading: FadeInDown(
              duration: const Duration(milliseconds: 400),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(80),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.medical_services,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.add_circle_outline),
                selectedIcon: Icon(Icons.add_circle),
                label: Text('New Claim'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.list_alt_outlined),
                selectedIcon: Icon(Icons.list_alt),
                label: Text('Claims'),
              ),
            ],
          ),
          const VerticalDivider(width: 1),
          const Expanded(child: DashboardContent()),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildDesktopLayout() {
    return Scaffold(
      key: _scaffoldKey,
      body: Row(
        children: [
          SidebarMenu(
            selectedIndex: _selectedNavIndex,
            isCollapsed: false,
            onItemSelected: _handleNavigation,
          ),
          Expanded(
            child: Column(
              children: [
                _buildDesktopAppBar(),
                const Expanded(child: DashboardContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.medical_services,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'ClaimFlow',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _isSearchExpanded ? Icons.close : Icons.search,
              key: ValueKey(_isSearchExpanded),
            ),
          ),
          onPressed: _toggleSearch,
        ),
        IconButton(
          icon: Badge(
            label: const Text('3'),
            backgroundColor: AppColors.error,
            child: const Icon(Icons.notifications_outlined),
          ),
          onPressed: () => Navigator.pushNamed(context, RouteConstants.notifications),
        ),
        _buildUserAvatarMenu(),
      ],
      bottom: _isSearchExpanded ? _buildSearchBar() : null,
    );
  }

  Widget _buildDesktopAppBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search claims by number, patient, or hospital...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: (value) {
                  context.read<ClaimProvider>().setSearchQuery(value);
                },
              ),
            ),
          ),
          const SizedBox(width: 24),
          IconButton(
            icon: Badge(
              label: const Text('3'),
              backgroundColor: AppColors.error,
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () => Navigator.pushNamed(context, RouteConstants.notifications),
          ),
          const SizedBox(width: 16),
          _buildUserAvatarMenu(),
        ],
      ),
    );
  }

  PreferredSize _buildSearchBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: FadeInDown(
        duration: const Duration(milliseconds: 200),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search claims...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            onChanged: (value) {
              context.read<ClaimProvider>().setSearchQuery(value);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatarMenu() {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Hero(
              tag: 'user_avatar',
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: Text(
                  user?.name.isNotEmpty == true
                      ? user!.name[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withAlpha(26),
              child: Icon(Icons.person_outline, color: AppColors.primary),
            ),
            title: Text(user?.name ?? 'User'),
            subtitle: Text(
              user?.email ?? '',
              style: const TextStyle(fontSize: 12),
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'settings',
          child: ListTile(
            leading: Icon(Icons.settings_outlined),
            title: Text('Settings'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value: 'logout',
          child: ListTile(
            leading: Icon(Icons.logout, color: AppColors.error),
            title: Text('Logout', style: TextStyle(color: AppColors.error)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
      onSelected: (value) => _handleUserMenuAction(value),
    );
  }

  Widget _buildBottomNav() {
    return NavigationBar(
      selectedIndex: _selectedNavIndex,
      onDestinationSelected: _handleNavigation,
      animationDuration: const Duration(milliseconds: 400),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.add_circle_outline),
          selectedIcon: Icon(Icons.add_circle),
          label: 'New Claim',
        ),
        NavigationDestination(
          icon: Icon(Icons.list_alt_outlined),
          selectedIcon: Icon(Icons.list_alt),
          label: 'Claims',
        ),
      ],
    );
  }

  Widget _buildFAB() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = MediaQuery.of(context).size.width <
            ResponsiveLayout.tabletBreakpoint;
        
        if (!isMobile) return const SizedBox.shrink();

        return FadeInUp(
          duration: const Duration(milliseconds: 400),
          child: FloatingActionButton.extended(
            onPressed: () =>
                Navigator.pushNamed(context, RouteConstants.createClaim),
            icon: const Icon(Icons.add),
            label: const Text('New Claim'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (!_isSearchExpanded) {
        _searchController.clear();
        context.read<ClaimProvider>().setSearchQuery('');
      }
    });
  }

  void _handleNavigation(int index) {
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.pop(context);
    }

    setState(() => _selectedNavIndex = index);

    switch (index) {
      case 1:
        Navigator.pushNamed(context, RouteConstants.createClaim);
        break;
      case 2:
        Navigator.pushNamed(context, RouteConstants.claims);
        break;
    }
  }

  Future<void> _handleUserMenuAction(String action) async {
    switch (action) {
      case 'profile':
        Navigator.pushNamed(context, RouteConstants.profile);
        break;
      case 'settings':
        Navigator.pushNamed(context, RouteConstants.settings);
        break;
      case 'logout':
        final confirmed = await _showLogoutConfirmation();
        if (confirmed && mounted) {
          await context.read<AuthProvider>().logout();
          if (mounted) {
            Navigator.pushReplacementNamed(context, RouteConstants.login);
          }
        }
        break;
    }
  }

  Future<bool> _showLogoutConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
