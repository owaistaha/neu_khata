import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction.dart';
import 'transaction_provider.dart';

enum ReportsRange { weekly, monthly, yearly }

class ReportBucket {
  const ReportBucket({required this.label, required this.amount});

  final String label;
  final double amount;
}

class CategoryBreakdown {
  const CategoryBreakdown({required this.name, required this.amount});

  final String name;
  final double amount;
}

class ReportsData {
  const ReportsData({
    required this.rangeStart,
    required this.rangeEnd,
    required this.income,
    required this.expense,
    required this.incomeChangePercent,
    required this.expenseChangePercent,
    required this.buckets,
    required this.expenseCategories,
  });

  final DateTime rangeStart;
  final DateTime rangeEnd;
  final double income;
  final double expense;
  final double? incomeChangePercent;
  final double? expenseChangePercent;
  final List<ReportBucket> buckets;
  final List<CategoryBreakdown> expenseCategories;
}

final reportsProvider = Provider.family<AsyncValue<ReportsData>, ReportsRange>((
  ref,
  range,
) {
  final transactionsAsync = ref.watch(allTransactionsProvider);

  return transactionsAsync.when(
    data: (transactions) {
      final current = _resolveRange(range, DateTime.now());
      final previous = _previousRange(range, current.start);

      final currentTx = transactions
          .where((t) => _isWithin(t.date, current.start, current.end))
          .toList();
      final previousTx = transactions
          .where((t) => _isWithin(t.date, previous.start, previous.end))
          .toList();

      final income = _sumByType(currentTx, TransactionType.received);
      final expense = _sumByType(currentTx, TransactionType.gave);

      final previousIncome = _sumByType(previousTx, TransactionType.received);
      final previousExpense = _sumByType(previousTx, TransactionType.gave);

      final buckets = _buildBuckets(
        currentTx,
        range,
        current.start,
        current.end,
      );
      final categories = _buildCategoryBreakdown(currentTx);

      return AsyncValue.data(
        ReportsData(
          rangeStart: current.start,
          rangeEnd: current.end,
          income: income,
          expense: expense,
          incomeChangePercent: _computeChange(income, previousIncome),
          expenseChangePercent: _computeChange(expense, previousExpense),
          buckets: buckets,
          expenseCategories: categories,
        ),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

class _DateRange {
  const _DateRange(this.start, this.end);

  final DateTime start;
  final DateTime end;
}

_DateRange _resolveRange(ReportsRange range, DateTime now) {
  switch (range) {
    case ReportsRange.weekly:
      final end = DateTime(now.year, now.month, now.day + 1);
      final start = DateTime(now.year, now.month, now.day - 6);
      return _DateRange(start, end);
    case ReportsRange.monthly:
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 1);
      return _DateRange(start, end);
    case ReportsRange.yearly:
      final start = DateTime(now.year, 1, 1);
      final end = DateTime(now.year + 1, 1, 1);
      return _DateRange(start, end);
  }
}

_DateRange _previousRange(ReportsRange range, DateTime currentStart) {
  switch (range) {
    case ReportsRange.weekly:
      final end = currentStart;
      final start = currentStart.subtract(const Duration(days: 7));
      return _DateRange(start, end);
    case ReportsRange.monthly:
      final start = DateTime(currentStart.year, currentStart.month - 1, 1);
      final end = DateTime(currentStart.year, currentStart.month, 1);
      return _DateRange(start, end);
    case ReportsRange.yearly:
      final start = DateTime(currentStart.year - 1, 1, 1);
      final end = DateTime(currentStart.year, 1, 1);
      return _DateRange(start, end);
  }
}

bool _isWithin(DateTime date, DateTime start, DateTime end) {
  return !date.isBefore(start) && date.isBefore(end);
}

double _sumByType(List<Transaction> tx, TransactionType type) {
  return tx
      .where((t) => t.type == type)
      .fold<double>(0, (sum, t) => sum + t.amount);
}

double? _computeChange(double current, double previous) {
  if (previous == 0) {
    return current == 0 ? 0 : null;
  }
  return ((current - previous) / previous) * 100;
}

List<ReportBucket> _buildBuckets(
  List<Transaction> tx,
  ReportsRange range,
  DateTime start,
  DateTime end,
) {
  switch (range) {
    case ReportsRange.weekly:
      return List.generate(7, (index) {
        final bucketStart = DateTime(
          start.year,
          start.month,
          start.day + index,
        );
        final bucketEnd = DateTime(
          bucketStart.year,
          bucketStart.month,
          bucketStart.day + 1,
        );
        final value = tx
            .where((t) => _isWithin(t.date, bucketStart, bucketEnd))
            .fold<double>(0, (sum, t) => sum + t.amount);
        final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return ReportBucket(
          label: labels[bucketStart.weekday - 1],
          amount: value,
        );
      });
    case ReportsRange.monthly:
      final buckets = <ReportBucket>[];
      var week = 1;
      var cursor = start;
      while (cursor.isBefore(end)) {
        final weekEnd = cursor.add(const Duration(days: 7));
        final bucketEnd = weekEnd.isAfter(end) ? end : weekEnd;
        final value = tx
            .where((t) => _isWithin(t.date, cursor, bucketEnd))
            .fold<double>(0, (sum, t) => sum + t.amount);
        buckets.add(ReportBucket(label: 'W$week', amount: value));
        cursor = bucketEnd;
        week++;
      }
      return buckets;
    case ReportsRange.yearly:
      const labels = [
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
      return List.generate(12, (index) {
        final bucketStart = DateTime(start.year, index + 1, 1);
        final bucketEnd = DateTime(start.year, index + 2, 1);
        final value = tx
            .where((t) => _isWithin(t.date, bucketStart, bucketEnd))
            .fold<double>(0, (sum, t) => sum + t.amount);
        return ReportBucket(label: labels[index], amount: value);
      });
  }
}

List<CategoryBreakdown> _buildCategoryBreakdown(List<Transaction> tx) {
  final map = <String, double>{};

  for (final t in tx.where((element) => element.type == TransactionType.gave)) {
    final key = (t.category == null || t.category!.trim().isEmpty)
        ? 'Uncategorized'
        : t.category!.trim();
    map[key] = (map[key] ?? 0) + t.amount;
  }

  final entries = map.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return entries
      .map((entry) => CategoryBreakdown(name: entry.key, amount: entry.value))
      .toList();
}
