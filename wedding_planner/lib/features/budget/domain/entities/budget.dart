import 'package:equatable/equatable.dart';

/// Budget Category Enum
enum BudgetCategory {
  venue('Venue', '🏛️'),
  catering('Catering', '🍽️'),
  photography('Photography', '📸'),
  videography('Videography', '🎥'),
  music('Music & DJ', '🎵'),
  flowers('Flowers & Decor', '💐'),
  attire('Attire', '👗'),
  beauty('Beauty', '💄'),
  transportation('Transportation', '🚗'),
  stationery('Stationery', '✉️'),
  gifts('Gifts & Favors', '🎁'),
  rings('Rings & Jewelry', '💍'),
  officiant('Officiant', '📿'),
  cake('Cake & Desserts', '🎂'),
  rentals('Rentals', '🪑'),
  other('Other', '📦');

  final String displayName;
  final String icon;

  const BudgetCategory(this.displayName, this.icon);
}

/// Payment Status
enum PaymentStatus {
  pending('Pending', '⏳'),
  partiallyPaid('Partially Paid', '💳'),
  paid('Paid', '✅'),
  refunded('Refunded', '↩️');

  final String displayName;
  final String icon;

  const PaymentStatus(this.displayName, this.icon);
}

/// Budget Overview
class Budget extends Equatable {
  final String id;
  final String weddingId;
  final double totalBudget;
  final double totalSpent;
  final double totalPaid;
  final String currency;
  final List<CategoryBudget> categories;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Budget({
    required this.id,
    required this.weddingId,
    required this.totalBudget,
    required this.totalSpent,
    required this.totalPaid,
    this.currency = 'USD',
    required this.categories,
    required this.createdAt,
    this.updatedAt,
  });

  double get remaining => totalBudget - totalSpent;
  double get unpaid => totalSpent - totalPaid;
  double get percentageSpent => totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0;
  bool get isOverBudget => totalSpent > totalBudget;

  String get formattedTotalBudget => _formatCurrency(totalBudget);
  String get formattedTotalSpent => _formatCurrency(totalSpent);
  String get formattedRemaining => _formatCurrency(remaining);
  String get formattedUnpaid => _formatCurrency(unpaid);

  String _formatCurrency(double amount) {
    final symbol = _getCurrencySymbol();
    if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '$symbol${amount.toStringAsFixed(0)}';
  }

  String _getCurrencySymbol() {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'KWD':
        return 'KD ';
      case 'AED':
        return 'AED ';
      default:
        return '\$';
    }
  }

  @override
  List<Object?> get props => [
        id,
        weddingId,
        totalBudget,
        totalSpent,
        totalPaid,
        currency,
        categories,
        createdAt,
        updatedAt,
      ];
}

/// Category Budget
class CategoryBudget extends Equatable {
  final String id;
  final BudgetCategory category;
  final double allocated;
  final double spent;
  final double paid;
  final int itemCount;

  const CategoryBudget({
    required this.id,
    required this.category,
    required this.allocated,
    required this.spent,
    required this.paid,
    required this.itemCount,
  });

  double get remaining => allocated - spent;
  double get percentageSpent => allocated > 0 ? (spent / allocated) * 100 : 0;
  bool get isOverBudget => spent > allocated;

  @override
  List<Object?> get props => [id, category, allocated, spent, paid, itemCount];
}

/// Expense/Budget Item
class Expense extends Equatable {
  final String id;
  final String budgetId;
  final BudgetCategory category;
  final String title;
  final String? description;
  final double estimatedCost;
  final double actualCost;
  final PaymentStatus paymentStatus;
  final double paidAmount;
  final DateTime? dueDate;
  final DateTime? paidDate;
  final String? vendorId;
  final String? vendorName;
  final String? notes;
  final List<String>? receiptUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Expense({
    required this.id,
    required this.budgetId,
    required this.category,
    required this.title,
    this.description,
    this.estimatedCost = 0,
    this.actualCost = 0,
    this.paymentStatus = PaymentStatus.pending,
    this.paidAmount = 0,
    this.dueDate,
    this.paidDate,
    this.vendorId,
    this.vendorName,
    this.notes,
    this.receiptUrls,
    required this.createdAt,
    this.updatedAt,
  });

  double get difference => estimatedCost - actualCost;
  bool get isOverBudget => actualCost > estimatedCost;
  double get remainingPayment => actualCost - paidAmount;
  bool get isFullyPaid => paymentStatus == PaymentStatus.paid;
  bool get isDueSoon => dueDate != null &&
      dueDate!.difference(DateTime.now()).inDays <= 7 &&
      dueDate!.isAfter(DateTime.now());
  bool get isOverdue => dueDate != null &&
      dueDate!.isBefore(DateTime.now()) &&
      paymentStatus != PaymentStatus.paid;

  String get dueDateFormatted {
    if (dueDate == null) return 'No due date';
    final now = DateTime.now();
    final diff = dueDate!.difference(now).inDays;
    if (diff < 0) return '${-diff} days overdue';
    if (diff == 0) return 'Due today';
    if (diff == 1) return 'Due tomorrow';
    if (diff <= 7) return 'Due in $diff days';
    return '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}';
  }

  @override
  List<Object?> get props => [
        id,
        budgetId,
        category,
        title,
        description,
        estimatedCost,
        actualCost,
        paymentStatus,
        paidAmount,
        dueDate,
        paidDate,
        vendorId,
        vendorName,
        notes,
        receiptUrls,
        createdAt,
        updatedAt,
      ];
}

/// Request to create/update expense
class ExpenseRequest {
  final BudgetCategory category;
  final String title;
  final String? description;
  final double estimatedCost;
  final double actualCost;
  final PaymentStatus paymentStatus;
  final double paidAmount;
  final DateTime? dueDate;
  final String? vendorId;
  final String? notes;

  const ExpenseRequest({
    required this.category,
    required this.title,
    this.description,
    this.estimatedCost = 0,
    this.actualCost = 0,
    this.paymentStatus = PaymentStatus.pending,
    this.paidAmount = 0,
    this.dueDate,
    this.vendorId,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'category': category.name,
        'title': title,
        if (description != null) 'description': description,
        'estimatedCost': estimatedCost,
        'actualCost': actualCost,
        'paymentStatus': paymentStatus.name,
        'paidAmount': paidAmount,
        if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
        if (vendorId != null) 'vendorId': vendorId,
        if (notes != null) 'notes': notes,
      };
}

/// Request to update category allocation
class CategoryAllocationRequest {
  final BudgetCategory category;
  final double allocated;

  const CategoryAllocationRequest({
    required this.category,
    required this.allocated,
  });

  Map<String, dynamic> toJson() => {
        'category': category.name,
        'allocated': allocated,
      };
}

/// Budget Statistics
class BudgetStats extends Equatable {
  final double totalBudget;
  final double totalSpent;
  final double totalPaid;
  final double totalUnpaid;
  final int totalExpenses;
  final int paidExpenses;
  final int pendingExpenses;
  final int overdueExpenses;
  final List<CategoryBudget> topCategories;
  final List<Expense> upcomingPayments;

  const BudgetStats({
    required this.totalBudget,
    required this.totalSpent,
    required this.totalPaid,
    required this.totalUnpaid,
    required this.totalExpenses,
    required this.paidExpenses,
    required this.pendingExpenses,
    required this.overdueExpenses,
    required this.topCategories,
    required this.upcomingPayments,
  });

  double get percentageSpent => totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0;

  @override
  List<Object?> get props => [
        totalBudget,
        totalSpent,
        totalPaid,
        totalUnpaid,
        totalExpenses,
        paidExpenses,
        pendingExpenses,
        overdueExpenses,
        topCategories,
        upcomingPayments,
      ];
}
