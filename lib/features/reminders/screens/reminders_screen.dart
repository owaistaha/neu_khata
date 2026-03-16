import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/business_profile.dart';
import '../../../core/widgets/neumorphic_button.dart';
import '../../../models/reminder.dart';
import '../../../providers/business_profile_provider.dart';
import '../../../providers/customer_provider.dart';
import '../../../providers/reminder_provider.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final remindersAsync = ref.watch(remindersWithCustomerProvider);
    final businessProfile = ref.watch(businessProfileProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.neuBackgroundAlt,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.neuBackgroundAlt,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Payment Reminders',
                      style: AppTextStyles.titleLarge.copyWith(
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  GestureDetector(
                    onTap: _showAddReminderSheet,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.12),
                      ),
                      child: Icon(Icons.add, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.slate200.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: ['Overdue', 'Upcoming', 'Settled']
                      .asMap()
                      .entries
                      .map(
                        (entry) => Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedTab = entry.key),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _selectedTab == entry.key
                                    ? AppColors.neuBackgroundAlt
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: _selectedTab == entry.key
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.05,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                              child: Center(
                                child: Text(
                                  entry.value,
                                  style: AppTextStyles.labelMedium.copyWith(
                                    color: _selectedTab == entry.key
                                        ? AppColors.primary
                                        : AppColors.textTertiary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            Expanded(
              child: remindersAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (error, _) => Center(
                  child: Text(
                    'Error loading reminders: $error',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                data: (items) {
                  final filtered = _filter(items);
                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SummaryCard(
                          selectedTab: _selectedTab,
                          reminders: filtered.map((e) => e.reminder).toList(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            _selectedTab == 2
                                ? 'Settled Reminders'
                                : 'Pending Dues',
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (filtered.isEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.neuBackgroundAlt,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.slate100),
                              ),
                              child: Text(
                                _selectedTab == 2
                                    ? 'No settled reminders yet.'
                                    : 'No reminders in this tab. Tap + to add one.',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),
                          )
                        else
                          ...filtered.map(
                            (item) => _buildReminderCard(item, businessProfile),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddReminderSheet,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.notifications_active_outlined),
        label: const Text('Add Reminder'),
      ),
    );
  }

  List<ReminderWithCustomer> _filter(List<ReminderWithCustomer> items) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    if (_selectedTab == 0) {
      return items
          .where(
            (e) =>
                !e.reminder.isSettled &&
                e.reminder.dueDate.isBefore(todayStart),
          )
          .toList();
    }
    if (_selectedTab == 1) {
      return items
          .where(
            (e) =>
                !e.reminder.isSettled &&
                !e.reminder.dueDate.isBefore(todayStart),
          )
          .toList();
    }
    return items.where((e) => e.reminder.isSettled).toList();
  }

  Widget _buildReminderCard(
    ReminderWithCustomer item,
    BusinessProfile? businessProfile,
  ) {
    final reminder = item.reminder;
    final name = item.customer?.name ?? 'Unknown Customer';
    final initials = _initials(name);
    final amountLabel = '₨${_currency(reminder.amount)}';
    final dueText = _dueLabel(reminder);
    final isSettled = reminder.isSettled;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.neuBackgroundAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
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
                        name,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Due ${DateFormat('MMM d, yyyy').format(reminder.dueDate)}',
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
                      amountLabel,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: isSettled ? AppColors.primary : AppColors.danger,
                      ),
                    ),
                    Text(
                      dueText,
                      style: AppTextStyles.badge.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (reminder.note != null && reminder.note!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.neuBackgroundAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.slate50),
                ),
                child: Text(
                  reminder.note!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: NeuButton(
                    onTap: () async {
                      await ref
                          .read(reminderNotifierProvider.notifier)
                          .setSettled(reminder: reminder, settled: !isSettled);
                    },
                    borderRadius: 16,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSettled
                              ? Icons.restart_alt
                              : Icons.check_circle_outline,
                          size: 20,
                          color: isSettled
                              ? AppColors.textTertiary
                              : AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isSettled ? 'Mark Pending' : 'Mark Settled',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: isSettled
                                ? AppColors.textTertiary
                                : AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                NeuButton(
                  onTap: () async {
                    await _sendWhatsAppReminder(
                      item: item,
                      businessProfile: businessProfile,
                    );
                  },
                  borderRadius: 16,
                  padding: const EdgeInsets.all(12),
                  width: 48,
                  height: 48,
                  child: Icon(Icons.chat, size: 20, color: AppColors.primary),
                ),
                const SizedBox(width: 8),
                NeuButton(
                  onTap: () {
                    if (item.customer?.id != null) {
                      context.push('/customers/${item.customer!.id}');
                    }
                  },
                  borderRadius: 16,
                  padding: const EdgeInsets.all(12),
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.menu_book_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                NeuButton(
                  onTap: () async {
                    await ref
                        .read(reminderNotifierProvider.notifier)
                        .deleteReminder(reminder.id);
                  },
                  borderRadius: 16,
                  padding: const EdgeInsets.all(12),
                  width: 48,
                  height: 48,
                  child: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: AppColors.danger,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddReminderSheet() async {
    final customers = await ref.read(customersProvider.future);
    if (!mounted) return;

    if (customers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Add a customer first before creating reminders.',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    var selectedCustomerId = customers.first.id;
    var dueDate = DateTime.now().add(const Duration(days: 1));
    var amountText = '';
    var noteText = '';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20 + MediaQuery.of(modalContext).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: AppColors.neuBackgroundAlt,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Reminder',
                          style: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          initialValue: selectedCustomerId,
                          decoration: const InputDecoration(
                            labelText: 'Customer',
                          ),
                          items: customers
                              .map(
                                (c) => DropdownMenuItem<int>(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setModalState(() => selectedCustomerId = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Amount',
                          ),
                          onChanged: (value) => amountText = value,
                          validator: (value) {
                            final amount = double.tryParse(value ?? '');
                            if (amount == null || amount <= 0) {
                              return 'Enter a valid amount';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: modalContext,
                              initialDate: dueDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setModalState(() => dueDate = picked);
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.slate200),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Due Date: ${DateFormat('MMM d, yyyy').format(dueDate)}',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: noteText,
                          maxLines: 2,
                          onChanged: (value) => noteText = value,
                          decoration: const InputDecoration(
                            labelText: 'Note (optional)',
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (!formKey.currentState!.validate()) return;
                              final navigator = Navigator.of(ctx);

                              final amount = double.parse(amountText.trim());

                              await ref
                                  .read(reminderNotifierProvider.notifier)
                                  .addReminder(
                                    customerId: selectedCustomerId,
                                    amount: amount,
                                    dueDate: dueDate,
                                    note: noteText,
                                  );

                              if (navigator.mounted) {
                                navigator.pop();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Save Reminder'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _currency(double value) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(value);
  }

  String _dueLabel(Reminder reminder) {
    if (reminder.isSettled) return 'SETTLED';

    final due = DateTime(
      reminder.dueDate.year,
      reminder.dueDate.month,
      reminder.dueDate.day,
    );
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = due.difference(today).inDays;

    if (diff < 0) {
      return '${diff.abs()} Days Late';
    }
    if (diff == 0) {
      return 'Due Today';
    }
    return 'Due in $diff Days';
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'NA';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Future<void> _sendWhatsAppReminder({
    required ReminderWithCustomer item,
    required BusinessProfile? businessProfile,
  }) async {
    final customer = item.customer;
    final reminder = item.reminder;

    if (customer == null) {
      _showSnackBar('Customer not found for this reminder.', isError: true);
      return;
    }

    final rawPhone = customer.phone?.trim() ?? '';
    final phone = _normalizePhoneForWhatsApp(rawPhone);
    if (phone == null) {
      _showSnackBar(
        'Please add a valid customer phone number first.',
        isError: true,
      );
      return;
    }

    final amount = NumberFormat('#,##0.00', 'en_US').format(reminder.amount);
    final dueDate = DateFormat('MMM d, yyyy').format(reminder.dueDate);
    final businessName = businessProfile?.businessName ?? 'your business';
    final ownerName = businessProfile?.ownerName;

    final messageBuffer = StringBuffer()
      ..writeln('Assalam o Alaikum ${customer.name},')
      ..writeln()
      ..writeln('This is a payment reminder from $businessName.')
      ..writeln('Amount Due: ₨$amount')
      ..writeln('Due Date: $dueDate')
      ..writeln('Status: ${_dueLabel(reminder)}');

    if (reminder.note != null && reminder.note!.trim().isNotEmpty) {
      messageBuffer
        ..writeln()
        ..writeln('Note: ${reminder.note!.trim()}');
    }

    messageBuffer
      ..writeln()
      ..writeln('Please clear this payment at your earliest convenience.')
      ..writeln('Thank you.');

    if (ownerName != null && ownerName.trim().isNotEmpty) {
      messageBuffer.writeln('- ${ownerName.trim()}');
    }

    final message = messageBuffer.toString();
    final uri = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(message)}',
    );

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      _showSnackBar('Could not open WhatsApp on this device.', isError: true);
    }
  }

  String? _normalizePhoneForWhatsApp(String input) {
    if (input.isEmpty) return null;

    final digits = input.replaceAll(RegExp(r'[^0-9+]'), '');
    if (digits.startsWith('+')) {
      final onlyDigits = digits.substring(1).replaceAll(RegExp(r'[^0-9]'), '');
      return onlyDigits.isEmpty ? null : onlyDigits;
    }

    if (digits.startsWith('00')) {
      final normalized = digits.substring(2);
      return normalized.isEmpty ? null : normalized;
    }

    if (digits.startsWith('0')) {
      return '92${digits.substring(1)}';
    }

    return digits.length >= 10 ? digits : null;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.selectedTab, required this.reminders});

  final int selectedTab;
  final List<Reminder> reminders;

  @override
  Widget build(BuildContext context) {
    final totalAmount = reminders.fold<double>(0, (sum, r) => sum + r.amount);
    final title = selectedTab == 0
        ? 'TOTAL OVERDUE AMOUNT'
        : selectedTab == 1
        ? 'TOTAL UPCOMING AMOUNT'
        : 'TOTAL SETTLED AMOUNT';

    final subtitle = selectedTab == 0
        ? '${reminders.length} Customers Pending'
        : selectedTab == 1
        ? '${reminders.length} Upcoming Payments'
        : '${reminders.length} Settled Payments';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.accentDark,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                Icons.payments,
                size: 120,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.badge.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₨${NumberFormat('#,##0.00', 'en_US').format(totalAmount)}',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.neuBackgroundAlt.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.group, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
