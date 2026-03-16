import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/neumorphic_container.dart';
import '../../../providers/app_language_provider.dart';
import '../../../providers/business_profile_provider.dart';

/// Settings screen with neumorphic cards and premium banner.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessProfileAsync = ref.watch(businessProfileProvider);
    final languageAsync = ref.watch(appLanguageProvider);
    final selectedLanguage = languageAsync.valueOrNull ?? AppLanguage.english;

    return Scaffold(
      backgroundColor: AppColors.neuBackgroundAlt,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 16),
                  Text(
                    'Settings',
                    style: AppTextStyles.titleLarge.copyWith(
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                    child: Icon(Icons.help_outline, color: AppColors.primary),
                  ),
                ],
              ),
            ),

            // ── Body ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Business Identity
                    _SectionHeader(title: 'Business Identity'),
                    const SizedBox(height: 12),
                    businessProfileAsync.when(
                      data: (profile) {
                        final hasProfile = profile != null;
                        return NeuContainer(
                          type: NeuType.flat,
                          padding: const EdgeInsets.all(16),
                          borderRadius: 16,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.storefront,
                                      size: 32,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: -2,
                                    right: -2,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.neuBackgroundAlt,
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        hasProfile ? Icons.edit : Icons.add,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hasProfile
                                          ? profile.businessName
                                          : 'No business registered',
                                      style: AppTextStyles.titleMedium.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      hasProfile
                                          ? (profile.ownerName?.isNotEmpty ??
                                                    false)
                                                ? profile.ownerName!
                                                : 'Business Profile'
                                          : 'Setup required to use all features',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                    if (hasProfile &&
                                        (profile.phone?.isNotEmpty ?? false))
                                      Text(
                                        profile.phone!,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.textTertiary,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => context.go(
                                  '/register-business?from=settings',
                                ),
                                icon: Icon(
                                  Icons.chevron_right,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () => NeuContainer(
                        type: NeuType.flat,
                        padding: const EdgeInsets.all(16),
                        borderRadius: 16,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      error: (error, stackTrace) => NeuContainer(
                        type: NeuType.flat,
                        padding: const EdgeInsets.all(16),
                        borderRadius: 16,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                        child: Text(
                          'Could not load business profile',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _SettingCard(
                      icon: Icons.settings_suggest,
                      iconBg: const Color(0xFFEFF6FF),
                      iconColor: const Color(0xFF2563EB),
                      title: 'Business Setup',
                      subtitle: businessProfileAsync.maybeWhen(
                        data: (profile) => profile == null
                            ? 'Register your business profile'
                            : 'Edit business name, owner, phone and address',
                        orElse: () => 'Manage setup details',
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: AppColors.textTertiary,
                      ),
                      onTap: () =>
                          context.go('/register-business?from=settings'),
                    ),

                    const SizedBox(height: 32),

                    // Preferences & Tools
                    _SectionHeader(title: 'Preferences & Tools'),
                    const SizedBox(height: 12),

                    // Language
                    _SettingCard(
                      icon: Icons.language,
                      iconBg: const Color(0xFFEEF2FF),
                      iconColor: const Color(0xFF4F46E5),
                      title: 'App Language',
                      subtitle: 'English / اردو',
                      trailing: _LanguageToggle(
                        selectedLanguage: selectedLanguage,
                        onChanged: (language) {
                          ref
                              .read(appLanguageProvider.notifier)
                              .setLanguage(language);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Export PDF
                    _SettingCard(
                      icon: Icons.picture_as_pdf,
                      iconBg: const Color(0xFFFEF2F2),
                      iconColor: const Color(0xFFDC2626),
                      title: 'Export PDF Ledger',
                      subtitle: 'Download monthly reports',
                      trailing: Icon(
                        Icons.download,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Cloud Backup
                    _SettingCard(
                      icon: Icons.cloud_done,
                      iconBg: const Color(0xFFEFF6FF),
                      iconColor: const Color(0xFF2563EB),
                      title: 'Backup to Cloud',
                      subtitle: 'Last synced: 2 mins ago',
                      trailing: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Security
                    _SettingCard(
                      icon: Icons.lock_person,
                      iconBg: const Color(0xFFFFFBEB),
                      iconColor: const Color(0xFFD97706),
                      title: 'Security & App Lock',
                      subtitle: 'Fingerprint enabled',
                      trailing: Icon(
                        Icons.chevron_right,
                        color: AppColors.textTertiary,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Footer
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Digital Khata v4.2.0-stable',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Made with ❤️ for local businesses',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textTertiary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.badge.copyWith(color: AppColors.textTertiary),
      ),
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle({
    required this.selectedLanguage,
    required this.onChanged,
  });

  final AppLanguage selectedLanguage;
  final ValueChanged<AppLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    return NeuContainer(
      type: NeuType.inset,
      borderRadius: 999,
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LanguageChip(
            label: 'English',
            isSelected: selectedLanguage == AppLanguage.english,
            onTap: () => onChanged(AppLanguage.english),
          ),
          _LanguageChip(
            label: 'اردو',
            isSelected: selectedLanguage == AppLanguage.urdu,
            onTap: () => onChanged(AppLanguage.urdu),
          ),
        ],
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textTertiary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconBg, iconColor;
  final String title, subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeuContainer(
        type: NeuType.flat,
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
