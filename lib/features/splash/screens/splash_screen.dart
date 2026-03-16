import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/neumorphic_container.dart';
import '../../../core/widgets/neumorphic_progress_bar.dart';
import '../../../providers/business_profile_provider.dart';

/// Splash screen with neumorphic design.
///
/// Displays the app logo, brand name, animated progress bar,
/// and navigates to onboarding after loading completes.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  String _statusText = 'Initializing...';
  late final Timer _timer;

  final _statusMessages = [
    'Initializing...',
    'Loading preferences...',
    'Securing your vault...',
    'Almost ready...',
  ];

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() {
    int step = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      step++;
      setState(() {
        _progress = (step * 0.25).clamp(0.0, 1.0);
        _statusText =
            _statusMessages[(step - 1).clamp(0, _statusMessages.length - 1)];
      });
      if (step >= 4) {
        timer.cancel();
        _navigateNext();
      }
    });
  }

  Future<void> _navigateNext() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('hasSeenOnboarding') ?? false;
    final hasBusinessProfile = await ref.read(
      hasBusinessProfileProvider.future,
    );

    String nextRoute;
    if (!hasSeen) {
      nextRoute = '/onboarding';
    } else if (!hasBusinessProfile) {
      nextRoute = '/register-business';
    } else {
      nextRoute = '/dashboard';
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) context.go(nextRoute);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neuBackground,
      body: Stack(
        children: [
          // Background blur circles
          Positioned(
            top: -MediaQuery.of(context).size.height * 0.1,
            left: -MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -MediaQuery.of(context).size.height * 0.1,
            right: -MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: 256,
              height: 256,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // Spacer
                  const Spacer(flex: 2),

                  // ── Logo Card ──
                  NeuContainer(
                    type: NeuType.flat,
                    borderRadius: 24,
                    padding: const EdgeInsets.all(32),
                    offset: 12,
                    blurRadius: 24,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Image.asset(
                        'assets/icons/Icon.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ── Brand Name ──
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Khata',
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: 'Pro',
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: AppColors.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Digital Ledger',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Premium Badge ──
                  NeuContainer(
                    type: NeuType.inset,
                    borderRadius: 999,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'PREMIUM & SECURE',
                          style: AppTextStyles.badge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 3),

                  // ── Progress Section ──
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _statusText,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${(_progress * 100).toInt()}%',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        NeuProgressBar(progress: _progress),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Footer ──
                  Text(
                    'Trusted by 1M+ Businesses Worldwide',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (i) => Container(
                        width: 32,
                        height: 32,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.slate300.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
