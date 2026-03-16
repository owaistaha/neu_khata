import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/neumorphic_container.dart';
import '../../../providers/reports_provider.dart';

/// Reports screen with neumorphic charts, tabs, and category breakdown.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  int _selectedTab = 0;

  ReportsRange get _selectedRange {
    if (_selectedTab == 0) return ReportsRange.weekly;
    if (_selectedTab == 1) return ReportsRange.monthly;
    return ReportsRange.yearly;
  }

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(reportsProvider(_selectedRange));

    return Scaffold(
      backgroundColor: AppColors.neuBackgroundAlt,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Financial Reports',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ──
            Expanded(
              child: reportsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (error, _) => Center(
                  child: Text(
                    'Error loading reports: $error',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                data: (report) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: ['Weekly', 'Monthly', 'Yearly']
                                  .asMap()
                                  .entries
                                  .map(
                                    (e) => _TabButton(
                                      label: e.value,
                                      isActive: _selectedTab == e.key,
                                      onTap: () =>
                                          setState(() => _selectedTab = e.key),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: _SummaryCard(
                                  title: 'INCOME',
                                  value: report.income,
                                  icon: Icons.arrow_downward,
                                  color: AppColors.primary,
                                  changeText: _formatChange(
                                    report.incomeChangePercent,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _SummaryCard(
                                  title: 'EXPENSE',
                                  value: report.expense,
                                  icon: Icons.arrow_upward,
                                  color: AppColors.danger,
                                  changeText: _formatChange(
                                    report.expenseChangePercent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Cash Flow Analysis',
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                _formatRange(
                                  report.rangeStart,
                                  report.rangeEnd,
                                ),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: NeuContainer(
                            type: NeuType.flat,
                            borderRadius: 24,
                            padding: const EdgeInsets.all(24),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                            child: SizedBox(
                              height: 192,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: _buildChartBars(report.buckets),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Expense Categories',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._buildCategories(report.expenseCategories),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildChartBars(List<ReportBucket> buckets) {
    final max = buckets.fold<double>(
      0,
      (value, bucket) => bucket.amount > value ? bucket.amount : value,
    );
    var highlightedIndex = 0;
    var highlightedValue = 0.0;
    for (var i = 0; i < buckets.length; i++) {
      if (buckets[i].amount > highlightedValue) {
        highlightedValue = buckets[i].amount;
        highlightedIndex = i;
      }
    }

    return buckets.asMap().entries.map((entry) {
      final bucket = entry.value;
      final normalized = max == 0
          ? 0.08
          : (bucket.amount / max).clamp(0.08, 1.0);
      return _ChartBar(
        value: normalized,
        label: bucket.label,
        isHighlight: entry.key == highlightedIndex,
      );
    }).toList();
  }

  List<Widget> _buildCategories(List<CategoryBreakdown> categories) {
    final total = categories.fold<double>(0, (sum, item) => sum + item.amount);

    if (categories.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: NeuContainer(
            type: NeuType.flat,
            padding: const EdgeInsets.all(16),
            borderRadius: 16,
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
            child: Text(
              'No expense categories in selected range.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ),
      ];
    }

    return categories.map((c) {
      final percent = total == 0 ? 0.0 : (c.amount / total);
      final color = _colorForCategory(c.name);
      final icon = _iconForCategory(c.name);

      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(c.name, style: AppTextStyles.labelLarge),
                        Text(
                          '₨${_formatCurrency(c.amount)}',
                          style: AppTextStyles.labelLarge,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent,
                        backgroundColor: AppColors.slate200,
                        valueColor: AlwaysStoppedAnimation(color),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(amount);
  }

  String _formatChange(double? value) {
    if (value == null) return 'N/A';
    final sign = value >= 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(1)}%';
  }

  String _formatRange(DateTime start, DateTime endExclusive) {
    final end = endExclusive.subtract(const Duration(days: 1));
    final df = DateFormat('MMM d');
    return '${df.format(start)} - ${df.format(end)}';
  }

  Color _colorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'rent':
        return Colors.purple;
      case 'personal':
        return Colors.orange;
      case 'business':
        return Colors.blue;
      default:
        return AppColors.primary;
    }
  }

  IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'rent':
        return Icons.home_work_outlined;
      case 'personal':
        return Icons.person_outline;
      case 'business':
        return Icons.storefront_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.changeText,
  });

  final String title;
  final double value;
  final IconData icon;
  final Color color;
  final String changeText;

  @override
  Widget build(BuildContext context) {
    final amount = NumberFormat('#,##0.00', 'en_US').format(value);

    return NeuContainer(
      type: NeuType.flat,
      padding: const EdgeInsets.all(20),
      borderRadius: 16,
      border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.badge.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('₨$amount', style: AppTextStyles.amountSmall),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              changeText,
              style: AppTextStyles.badge.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isActive ? AppColors.primary : AppColors.textTertiary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  const _ChartBar({
    required this.value,
    required this.label,
    this.isHighlight = false,
  });
  final double value;
  final String label;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: NeuContainer(
                type: NeuType.inset,
                borderRadius: 999,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isHighlight
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.badge.copyWith(
                color: isHighlight ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
