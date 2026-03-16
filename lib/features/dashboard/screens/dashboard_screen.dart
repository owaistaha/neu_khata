import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/neumorphic_container.dart';
import '../../../core/widgets/neumorphic_button.dart';
import '../../../models/transaction.dart';
import '../../../providers/dashboard_provider.dart';
import '../../customers/widgets/add_customer_dialog.dart';

/// Dashboard home screen — neumorphic financial overview with live data.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.neuBackground,
      body: SafeArea(
        child: dashAsync.when(
          data: (data) => _buildContent(context, data),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (e, _) =>
              Center(child: Text('Error: $e', style: AppTextStyles.bodyMedium)),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, DashboardData data) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    NeuButton(
                      onTap: () {},
                      borderRadius: 999,
                      padding: const EdgeInsets.all(8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 40,
                          height: 40,
                          color: AppColors.primary.withValues(alpha: 0.1),
                          child: Icon(Icons.person, color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Digital Khata',
                          style: AppTextStyles.titleLarge.copyWith(
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          '${data.customerCount} CUSTOMERS',
                          style: AppTextStyles.badge.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                NeuButton(
                  onTap: () => context.push('/reminders'),
                  borderRadius: 999,
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Financial Cards ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: NeuContainer(
                    type: NeuType.flat,
                    padding: const EdgeInsets.all(20),
                    borderRadius: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.arrow_downward, color: AppColors.primary),
                        const SizedBox(height: 8),
                        Text(
                          'To Receive',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₨${_fmt(data.totalReceivable)}',
                          style: AppTextStyles.amountMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: NeuContainer(
                    type: NeuType.flat,
                    padding: const EdgeInsets.all(20),
                    borderRadius: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.arrow_upward, color: AppColors.danger),
                        const SizedBox(height: 8),
                        Text(
                          'To Pay',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₨${_fmt(data.totalPayable)}',
                          style: AppTextStyles.amountMedium.copyWith(
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Quick Actions ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Quick Actions',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: NeuButton(
                    onTap: () => AddCustomerDialog.show(context),
                    height: 56,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_add, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Add Customer',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: NeuButton(
                    onTap: () => context.go('/reports'),
                    height: 56,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description, color: AppColors.slate700),
                        const SizedBox(width: 8),
                        Text(
                          'Daily Report',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.slate700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Today's Transactions ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Today's Transactions",
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go('/customers'),
                  child: Text(
                    'See All',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (data.todayTransactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 48,
                      color: AppColors.textTertiary.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No transactions today',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...data.todayTransactions.map((twc) {
              final t = twc.transaction;
              final isCredit = t.type == TransactionType.received;
              final timeStr =
                  '${t.date.hour > 12 ? t.date.hour - 12 : t.date.hour}:'
                  '${t.date.minute.toString().padLeft(2, '0')} '
                  '${t.date.hour >= 12 ? 'PM' : 'AM'}';

              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: NeuContainer(
                  type: NeuType.flat,
                  padding: const EdgeInsets.all(16),
                  borderRadius: 16,
                  child: Row(
                    children: [
                      NeuContainer(
                        type: NeuType.inset,
                        borderRadius: 12,
                        padding: const EdgeInsets.all(8),
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.account_circle,
                          color: isCredit
                              ? AppColors.primary
                              : AppColors.danger,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              twc.customerName,
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.slate800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$timeStr${t.description != null ? ' • ${t.description}' : ''}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isCredit ? '+ ' : '- '}₨${_fmt(t.amount)}',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: isCredit
                                  ? AppColors.primary
                                  : AppColors.danger,
                            ),
                          ),
                          Text(
                            isCredit ? 'RECEIVED' : 'GIVEN',
                            style: AppTextStyles.badge.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _fmt(double v) {
    if (v == v.roundToDouble()) {
      return v.toInt().toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
    }
    return v
        .toStringAsFixed(2)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}
