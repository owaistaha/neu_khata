import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/transaction.dart';
import '../../../providers/customer_provider.dart';
import '../../../providers/transaction_provider.dart';

/// Full-screen transaction form with neumorphic numeric keypad.
///
/// Accepts query params: `customerId` and `type` (gave/received).
class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key, this.customerId, this.initialType});

  final int? customerId;
  final TransactionType? initialType;

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  late bool _isReceived;
  String _amount = '0';
  String _selectedCategory = 'Business';
  DateTime _selectedDate = DateTime.now();
  final _notesController = TextEditingController();
  bool _isSaving = false;
  int? _selectedCustomerId;

  @override
  void initState() {
    super.initState();
    _isReceived = widget.initialType != TransactionType.gave;
    _selectedCustomerId = widget.customerId;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _onKeypadTap(String key) {
    setState(() {
      if (key == '⌫') {
        _amount = _amount.length > 1
            ? _amount.substring(0, _amount.length - 1)
            : '0';
      } else if (key == '.') {
        if (!_amount.contains('.')) _amount += '.';
      } else {
        if (_amount == '0') {
          _amount = key;
        } else {
          _amount += key;
        }
      }
    });
  }

  String get _formattedAmount {
    final parts = _amount.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    if (parts.length > 1) return '$intPart.${parts[1]}';
    return intPart;
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amount) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter an amount greater than 0'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedCustomerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No customer selected'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref
          .read(transactionNotifierProvider.notifier)
          .addTransaction(
            customerId: _selectedCustomerId!,
            amount: amount,
            type: _isReceived ? TransactionType.received : TransactionType.gave,
            category: _selectedCategory,
            description: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
            date: _selectedDate,
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isReceived
                  ? 'Payment of ₨$_formattedAmount received!'
                  : 'Credit of ₨$_formattedAmount given!',
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider);
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
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
    final dateLabel =
        '${months[_selectedDate.month - 1]} ${_selectedDate.day}, ${_selectedDate.year}';

    return Scaffold(
      backgroundColor: AppColors.neuBackgroundAlt,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ── Header ──
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: const SizedBox(
                              width: 40,
                              height: 40,
                              child: Icon(Icons.arrow_back),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Add Transaction',
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                    ),

                    // ── Customer Selector (if not pre-set) ──
                    if (_selectedCustomerId == null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: customersAsync.when(
                          data: (customers) {
                            if (customers.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Text(
                                  'Add a customer first',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.danger,
                                  ),
                                ),
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.05,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _selectedCustomerId,
                                    hint: Text(
                                      'Select customer',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                    isExpanded: true,
                                    icon: Icon(
                                      Icons.expand_more,
                                      color: AppColors.primary,
                                    ),
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary,
                                    ),
                                    items: customers
                                        .map(
                                          (c) => DropdownMenuItem(
                                            value: c.id,
                                            child: Text(c.name),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) {
                                      if (v != null) {
                                        setState(() => _selectedCustomerId = v);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (e, st) => const SizedBox.shrink(),
                        ),
                      ),

                    // ── Toggle ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            _ToggleTab(
                              label: 'Payment Received',
                              isActive: _isReceived,
                              activeColor: AppColors.primary,
                              onTap: () => setState(() => _isReceived = true),
                            ),
                            _ToggleTab(
                              label: 'Payment Given',
                              isActive: !_isReceived,
                              activeColor: AppColors.danger,
                              onTap: () => setState(() => _isReceived = false),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Amount Display ──
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          Text(
                            'AMOUNT',
                            style: AppTextStyles.badge.copyWith(
                              color: _isReceived
                                  ? AppColors.primary
                                  : AppColors.danger,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '₨',
                                style: AppTextStyles.headlineMedium.copyWith(
                                  color: AppColors.textTertiary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                _formattedAmount,
                                style: AppTextStyles.amountXL.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ── Form Fields ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // Date picker
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'DATE',
                                      style: AppTextStyles.badge.copyWith(
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: _pickDate,
                                      child: Container(
                                        height: 48,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.05,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                dateLabel,
                                                style: AppTextStyles.bodyMedium
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                              ),
                                            ),
                                            Icon(
                                              Icons.calendar_today,
                                              size: 20,
                                              color: AppColors.primary,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Category
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'CATEGORY',
                                      style: AppTextStyles.badge.copyWith(
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 48,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.05,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _selectedCategory,
                                          isExpanded: true,
                                          icon: Icon(
                                            Icons.expand_more,
                                            color: AppColors.primary,
                                          ),
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.textPrimary,
                                              ),
                                          items:
                                              ['Business', 'Personal', 'Rent']
                                                  .map(
                                                    (v) => DropdownMenuItem(
                                                      value: v,
                                                      child: Text(v),
                                                    ),
                                                  )
                                                  .toList(),
                                          onChanged: (v) {
                                            if (v != null) {
                                              setState(
                                                () => _selectedCategory = v,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Notes
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'NOTES',
                                style: AppTextStyles.badge.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 48,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.05,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: TextField(
                                  controller: _notesController,
                                  decoration: InputDecoration(
                                    hintText: 'What is this for?',
                                    hintStyle: AppTextStyles.bodyMedium
                                        .copyWith(
                                          color: AppColors.textTertiary,
                                        ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    filled: false,
                                  ),
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isKeyboardOpen ? 12 : 24),
                  ],
                ),
              ),
            ),

            // ── Numeric Keypad ──
            if (!isKeyboardOpen)
              Container(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                decoration: BoxDecoration(
                  color: AppColors.neuBackgroundAlt,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    _buildKeypadRow(['1', '2', '3']),
                    const SizedBox(height: 16),
                    _buildKeypadRow(['4', '5', '6']),
                    const SizedBox(height: 16),
                    _buildKeypadRow(['7', '8', '9']),
                    const SizedBox(height: 16),
                    _buildKeypadRow(['.', '0', '⌫']),
                  ],
                ),
              ),

            // ── Save Button ──
            Container(
              padding: EdgeInsets.fromLTRB(
                24,
                isKeyboardOpen ? 8 : 16,
                24,
                isKeyboardOpen ? 12 : 24,
              ),
              color: AppColors.neuBackgroundAlt,
              child: SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle),
                  label: Text(_isSaving ? 'Saving...' : 'Save Transaction'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isReceived
                        ? AppColors.primary
                        : AppColors.danger,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor:
                        (_isReceived ? AppColors.primary : AppColors.danger)
                            .withValues(alpha: 0.3),
                    textStyle: AppTextStyles.titleMedium.copyWith(
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

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      children: keys.map((key) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GestureDetector(
              onTap: () => _onKeypadTap(key),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.neuBackgroundAlt,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neuShadowDarkAlt2,
                      offset: const Offset(4, 4),
                      blurRadius: 8,
                    ),
                    BoxShadow(
                      color: AppColors.neuShadowLight,
                      offset: const Offset(-4, -4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: key == '⌫'
                      ? Icon(
                          Icons.backspace_outlined,
                          color: AppColors.slate700,
                          size: 22,
                        )
                      : Text(
                          key,
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.slate700,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  const _ToggleTab({
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: double.infinity,
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
                color: isActive ? activeColor : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
