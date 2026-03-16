import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Shared scaffold that wraps tab-level screens with a
/// neumorphic bottom navigation bar and a center FAB.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    required this.currentPath,
  });

  final Widget child;
  final String currentPath;

  static const _tabs = [
    _Tab(
      icon: Icons.home,
      activeIcon: Icons.home,
      label: 'Home',
      path: '/dashboard',
    ),
    _Tab(
      icon: Icons.group_outlined,
      activeIcon: Icons.group,
      label: 'Customers',
      path: '/customers',
    ),
    _Tab(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      label: 'Bills',
      path: '/reports',
    ),
    _Tab(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      label: 'Settings',
      path: '/settings',
    ),
  ];

  int get _currentIndex {
    for (int i = 0; i < _tabs.length; i++) {
      if (currentPath.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.neuBackground,
      body: child,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-transaction'),
        backgroundColor: AppColors.primary,
        elevation: isDark ? 12 : 8,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.neuBackground,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.55)
                  : Colors.black.withValues(alpha: 0.06),
              offset: const Offset(4, 4),
              blurRadius: 12,
            ),
            BoxShadow(
              color: isDark
                  ? AppColors.neuShadowLight.withValues(alpha: 0.7)
                  : Colors.white.withValues(alpha: 0.8),
              offset: const Offset(-4, -4),
              blurRadius: 10,
            ),
          ],
          border: Border.all(
            color: isDark
                ? AppColors.slate200.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.5),
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ..._tabs.take(2).map((tab) => _buildTab(tab, context)),
                const SizedBox(width: 56), // space for FAB
                ..._tabs.skip(2).map((tab) => _buildTab(tab, context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(_Tab tab, BuildContext context) {
    final isActive = _tabs.indexOf(tab) == _currentIndex;

    return GestureDetector(
      onTap: () => context.go(tab.path),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isActive ? null : Colors.transparent,
                boxShadow: isActive
                    ? [] // inset-like for active
                    : null,
              ),
              child: Icon(
                isActive ? tab.activeIcon : tab.icon,
                color: isActive ? AppColors.primary : AppColors.textTertiary,
                size: 24,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              tab.label,
              style: AppTextStyles.badge.copyWith(
                color: isActive ? AppColors.primary : AppColors.textTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab {
  const _Tab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
  });
  final IconData icon, activeIcon;
  final String label, path;
}
