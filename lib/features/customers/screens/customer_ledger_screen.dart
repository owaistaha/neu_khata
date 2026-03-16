import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/transaction.dart';
import '../../../providers/customer_provider.dart';
import '../../../providers/transaction_provider.dart';

/// Customer ledger / detail screen with live transaction timeline.
class CustomerLedgerScreen extends ConsumerWidget {
  const CustomerLedgerScreen({super.key, required this.customerId});

  final String customerId;

  int get _id => int.tryParse(customerId) ?? 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(customerByIdProvider(_id));
    final txnAsync = ref.watch(transactionsByCustomerProvider(_id));

    return Scaffold(
      backgroundColor: AppColors.neuBackgroundAlt,
      body: Column(
        children: [
          // ── Sticky Header ──
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            decoration: BoxDecoration(
              color: AppColors.neuBackgroundAlt.withValues(alpha: 0.8),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
            ),
            child: customerAsync.when(
              data: (customer) {
                if (customer == null) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Customer not found'),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withValues(alpha: 0.1),
                          ),
                          child: const Icon(Icons.arrow_back),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            width: 2,
                          ),
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                        child: Center(
                          child: Text(
                            customer.name.isNotEmpty
                                ? customer.name[0].toUpperCase()
                                : '?',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              customer.phone ?? 'No phone',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'NET BALANCE',
                                style: AppTextStyles.badge.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              PopupMenuButton<String>(
                                icon: Icon(
                                  Icons.more_vert,
                                  color: AppColors.textTertiary,
                                  size: 20,
                                ),
                                padding: EdgeInsets.zero,
                                onSelected: (value) async {
                                  if (value == 'delete') {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete Customer'),
                                        content: const Text(
                                          'This will delete the customer and all their transactions. Are you sure?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: AppColors.danger,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await ref
                                          .read(
                                            customerNotifierProvider.notifier,
                                          )
                                          .deleteCustomer(customer.id);
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                              'Customer deleted.',
                                            ),
                                            backgroundColor: AppColors.primary,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                                itemBuilder: (context) => [
                                  // const PopupMenuItem(value: 'edit', child: Text('Edit Info')),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text(
                                      'Delete Customer',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            '₨${_fmt(customer.balance.abs())}',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: customer.balance >= 0
                                  ? AppColors.primary
                                  : AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error: $e'),
              ),
            ),
          ),

          // ── Body ──
          Expanded(
            child: txnAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: AppColors.textTertiary.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions yet',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Use the buttons below to record a transaction',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Calculate totals
                double totalGiven = 0;
                double totalReceived = 0;
                for (final t in transactions) {
                  if (t.type == TransactionType.gave) {
                    totalGiven += t.amount;
                  } else {
                    totalReceived += t.amount;
                  }
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Stats
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            _StatCard(
                              label: 'Total Given',
                              amount: '₨${_fmt(totalGiven)}',
                              color: AppColors.danger,
                            ),
                            const SizedBox(width: 16),
                            _StatCard(
                              label: 'Total Received',
                              amount: '₨${_fmt(totalReceived)}',
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),

                      // Timeline header
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          'TIMELINE',
                          style: AppTextStyles.trackingWide.copyWith(
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // Timeline entries
                      ...List.generate(transactions.length, (i) {
                        return _buildTimelineEntry(
                          context,
                          ref,
                          transactions[i],
                          isLast: i == transactions.length - 1,
                        );
                      }),
                    ],
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),

      // ── Bottom Action Bar ──
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: AppColors.neuBackgroundAlt,
          boxShadow: [
            BoxShadow(
              color: AppColors.neuShadowDarkAlt2,
              offset: const Offset(0, -20),
              blurRadius: 60,
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => context.push(
                    '/add-transaction?customerId=$_id&type=gave',
                  ),
                  icon: const Icon(Icons.remove_circle),
                  label: const Text('Give Credit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: AppColors.danger.withValues(alpha: 0.3),
                    textStyle: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => context.push(
                    '/add-transaction?customerId=$_id&type=received',
                  ),
                  icon: const Icon(Icons.add_circle),
                  label: const Text('Got Payment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: AppColors.primary.withValues(alpha: 0.3),
                    textStyle: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineEntry(
    BuildContext context,
    WidgetRef ref,
    Transaction txn, {
    required bool isLast,
  }) {
    final isReceived = txn.type == TransactionType.received;
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dateStr =
        '${months[txn.date.month - 1]} ${txn.date.day}, ${txn.date.year}';
    final timeStr =
        '${txn.date.hour > 12 ? txn.date.hour - 12 : txn.date.hour}:'
        '${txn.date.minute.toString().padLeft(2, '0')} '
        '${txn.date.hour >= 12 ? 'PM' : 'AM'}';

    return Dismissible(
      key: ValueKey(txn.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Transaction'),
            content: const Text('Are you sure? This will reverse the balance.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  'Delete',
                  style: TextStyle(color: AppColors.danger),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        ref.read(transactionNotifierProvider.notifier).deleteTransaction(txn);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 36,
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isReceived
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.danger.withValues(alpha: 0.1),
                        border: Border.all(
                          color: AppColors.neuBackgroundAlt,
                          width: 4,
                        ),
                      ),
                      child: Icon(
                        isReceived ? Icons.south_west : Icons.north_east,
                        size: 16,
                        color: isReceived
                            ? AppColors.primary
                            : AppColors.danger,
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(width: 2, color: AppColors.slate200),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.neuBackgroundAlt,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.05),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isReceived
                                    ? 'Payment Received'
                                    : 'Credit Given',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$dateStr • $timeStr',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${isReceived ? '+' : '-'}₨${_fmt(txn.amount)}',
                            style: AppTextStyles.amountSmall.copyWith(
                              color: isReceived
                                  ? AppColors.primary
                                  : AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                      if (txn.description != null &&
                          txn.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          '"${txn.description}"',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label, amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.neuBackgroundAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              amount,
              style: AppTextStyles.amountSmall.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
