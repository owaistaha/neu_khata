import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neu_khata/features/settings/screens/settings_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/neumorphic_container.dart';
import '../../../providers/customer_provider.dart';
import '../widgets/add_customer_dialog.dart';

/// Customers list screen with live Isar data.
class CustomersScreen extends ConsumerWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersProvider);

    return Scaffold(
      backgroundColor: AppColors.neuBackground,
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_customer_fab',
        onPressed: () => AddCustomerDialog.show(context),
        backgroundColor: AppColors.neuBackground,
        elevation: 0,
        shape: const CircleBorder(),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.neuBackground,
            boxShadow: [
              BoxShadow(
                color: const Color(0xCCFFFFFF),
                offset: const Offset(-4, -4),
                blurRadius: 8,
              ),
              BoxShadow(
                color: const Color(0x26000000),
                offset: const Offset(4, 4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Icon(Icons.person_add, color: AppColors.primary, size: 28),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Sticky Header ──
            _buildHeader(context),

            // ── Summary Cards ──
            customersAsync.when(
              data: (customers) => _buildSummary(customers),
              loading: () => const SizedBox.shrink(),
              error: (e, st) => const SizedBox.shrink(),
            ),

            // ── Customer List ──
            Expanded(
              child: customersAsync.when(
                data: (customers) {
                  if (customers.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final c = customers[index];
                      return _buildCustomerCard(context, c);
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (e, _) => Center(
                  child: Text('Error: $e', style: AppTextStyles.bodyMedium),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 12),
              Text(
                'My Khata',
                style: AppTextStyles.titleLarge.copyWith(letterSpacing: -0.5),
              ),
              NeuContainer(
                type: NeuType.flat,
                borderRadius: 999,
                padding: const EdgeInsets.all(4),
                offset: 4,
                blurRadius: 8,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.person,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          NeuContainer(
            type: NeuType.inset,
            borderRadius: 16,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.search, color: AppColors.textTertiary),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search customers by name or phone...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      filled: false,
                    ),
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
                Icon(Icons.filter_list, color: AppColors.textTertiary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(List customers) {
    double totalReceivable = 0;
    double totalPayable = 0;
    for (final c in customers) {
      if (c.balance > 0) {
        totalReceivable += c.balance;
      } else {
        totalPayable += c.balance.abs();
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: NeuContainer(
              type: NeuType.flat,
              padding: const EdgeInsets.all(16),
              borderRadius: 16,
              border: const Border(
                left: BorderSide(color: AppColors.success, width: 4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "YOU'LL GET",
                    style: AppTextStyles.badge.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₨${_formatAmount(totalReceivable)}',
                    style: AppTextStyles.amountSmall.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: NeuContainer(
              type: NeuType.flat,
              padding: const EdgeInsets.all(16),
              borderRadius: 16,
              border: const Border(
                left: BorderSide(color: AppColors.danger, width: 4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YOU GIVE',
                    style: AppTextStyles.badge.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₨${_formatAmount(totalPayable)}',
                    style: AppTextStyles.amountSmall.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, dynamic c) {
    final isPositive = c.balance > 0;
    final isSettled = c.balance == 0;
    final label = isSettled
        ? 'Settled'
        : (isPositive ? "You'll Get" : 'You Give');
    final color = isSettled
        ? AppColors.textTertiary
        : (isPositive ? AppColors.success : AppColors.danger);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => context.push('/customers/${c.id}'),
        child: NeuContainer(
          type: NeuType.flat,
          padding: const EdgeInsets.all(16),
          borderRadius: 16,
          child: Row(
            children: [
              NeuContainer(
                type: NeuType.flat,
                borderRadius: 999,
                padding: const EdgeInsets.all(2),
                offset: 3,
                blurRadius: 6,
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.slate800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      c.phone ?? 'No phone',
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
                  Text(
                    label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₨${_formatAmount(c.balance.abs())}',
                    style: AppTextStyles.amountSmall.copyWith(
                      fontSize: 18,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.group_outlined,
            size: 80,
            color: AppColors.textTertiary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No customers yet',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first customer',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => AddCustomerDialog.show(context),
            icon: const Icon(Icons.person_add),
            label: const Text('Add Customer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
    }
    return amount
        .toStringAsFixed(2)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}
