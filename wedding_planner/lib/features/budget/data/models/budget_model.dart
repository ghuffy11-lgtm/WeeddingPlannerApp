import '../../domain/entities/budget.dart';

class BudgetModel extends Budget {
  const BudgetModel({
    required super.id,
    required super.weddingId,
    required super.totalBudget,
    required super.totalSpent,
    required super.totalPaid,
    super.currency,
    required super.categories,
    required super.createdAt,
    super.updatedAt,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    final categoriesJson = json['categories'] as List? ?? [];
    return BudgetModel(
      id: json['id'] as String,
      weddingId: (json['weddingId'] ?? json['wedding_id'] ?? '') as String,
      totalBudget: _parseDouble(json['totalBudget'] ?? json['total_budget']),
      totalSpent: _parseDouble(json['totalSpent'] ?? json['total_spent']),
      totalPaid: _parseDouble(json['totalPaid'] ?? json['total_paid']),
      currency: (json['currency'] ?? 'USD') as String,
      categories: categoriesJson
          .map((c) => CategoryBudgetModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseNullableDateTime(json['updatedAt'] ?? json['updated_at']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }

  static DateTime? _parseNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}

class CategoryBudgetModel extends CategoryBudget {
  const CategoryBudgetModel({
    required super.id,
    required super.category,
    required super.allocated,
    required super.spent,
    required super.paid,
    required super.itemCount,
  });

  factory CategoryBudgetModel.fromJson(Map<String, dynamic> json) {
    return CategoryBudgetModel(
      id: (json['id'] ?? '') as String,
      category: _parseCategory(json['category']),
      allocated: _parseDouble(json['allocated']),
      spent: _parseDouble(json['spent']),
      paid: _parseDouble(json['paid']),
      itemCount: (json['itemCount'] ?? json['item_count'] ?? 0) as int,
    );
  }

  static BudgetCategory _parseCategory(dynamic value) {
    if (value == null) return BudgetCategory.other;
    final categoryStr = value.toString().toLowerCase();
    return BudgetCategory.values.firstWhere(
      (c) => c.name.toLowerCase() == categoryStr,
      orElse: () => BudgetCategory.other,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}

class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.budgetId,
    required super.category,
    required super.title,
    super.description,
    super.estimatedCost,
    super.actualCost,
    super.paymentStatus,
    super.paidAmount,
    super.dueDate,
    super.paidDate,
    super.vendorId,
    super.vendorName,
    super.notes,
    super.receiptUrls,
    required super.createdAt,
    super.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      budgetId: (json['budgetId'] ?? json['budget_id'] ?? '') as String,
      category: _parseCategory(json['category']),
      title: (json['title'] ?? '') as String,
      description: json['description'] as String?,
      estimatedCost: _parseDouble(json['estimatedCost'] ?? json['estimated_cost']),
      actualCost: _parseDouble(json['actualCost'] ?? json['actual_cost']),
      paymentStatus: _parsePaymentStatus(json['paymentStatus'] ?? json['payment_status']),
      paidAmount: _parseDouble(json['paidAmount'] ?? json['paid_amount']),
      dueDate: _parseNullableDateTime(json['dueDate'] ?? json['due_date']),
      paidDate: _parseNullableDateTime(json['paidDate'] ?? json['paid_date']),
      vendorId: json['vendorId'] ?? json['vendor_id'] as String?,
      vendorName: json['vendorName'] ?? json['vendor_name'] as String?,
      notes: json['notes'] as String?,
      receiptUrls: (json['receiptUrls'] ?? json['receipt_urls']) != null
          ? List<String>.from(json['receiptUrls'] ?? json['receipt_urls'])
          : null,
      createdAt: _parseDateTime(json['createdAt'] ?? json['created_at']),
      updatedAt: _parseNullableDateTime(json['updatedAt'] ?? json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'budgetId': budgetId,
        'category': category.name,
        'title': title,
        if (description != null) 'description': description,
        'estimatedCost': estimatedCost,
        'actualCost': actualCost,
        'paymentStatus': paymentStatus.name,
        'paidAmount': paidAmount,
        if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
        if (paidDate != null) 'paidDate': paidDate!.toIso8601String(),
        if (vendorId != null) 'vendorId': vendorId,
        if (vendorName != null) 'vendorName': vendorName,
        if (notes != null) 'notes': notes,
        if (receiptUrls != null) 'receiptUrls': receiptUrls,
        'createdAt': createdAt.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  static BudgetCategory _parseCategory(dynamic value) {
    if (value == null) return BudgetCategory.other;
    final categoryStr = value.toString().toLowerCase();
    return BudgetCategory.values.firstWhere(
      (c) => c.name.toLowerCase() == categoryStr,
      orElse: () => BudgetCategory.other,
    );
  }

  static PaymentStatus _parsePaymentStatus(dynamic value) {
    if (value == null) return PaymentStatus.pending;
    final statusStr = value.toString().toLowerCase();
    // Handle camelCase conversion
    final normalizedStr = statusStr.replaceAll('partiallypaid', 'partiallypaid');
    return PaymentStatus.values.firstWhere(
      (s) => s.name.toLowerCase() == normalizedStr,
      orElse: () => PaymentStatus.pending,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }

  static DateTime? _parseNullableDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}

class BudgetStatsModel extends BudgetStats {
  const BudgetStatsModel({
    required super.totalBudget,
    required super.totalSpent,
    required super.totalPaid,
    required super.totalUnpaid,
    required super.totalExpenses,
    required super.paidExpenses,
    required super.pendingExpenses,
    required super.overdueExpenses,
    required super.topCategories,
    required super.upcomingPayments,
  });

  factory BudgetStatsModel.fromJson(Map<String, dynamic> json) {
    final categoriesJson = json['topCategories'] ?? json['top_categories'] ?? [];
    final paymentsJson = json['upcomingPayments'] ?? json['upcoming_payments'] ?? [];

    return BudgetStatsModel(
      totalBudget: _parseDouble(json['totalBudget'] ?? json['total_budget']),
      totalSpent: _parseDouble(json['totalSpent'] ?? json['total_spent']),
      totalPaid: _parseDouble(json['totalPaid'] ?? json['total_paid']),
      totalUnpaid: _parseDouble(json['totalUnpaid'] ?? json['total_unpaid']),
      totalExpenses: (json['totalExpenses'] ?? json['total_expenses'] ?? 0) as int,
      paidExpenses: (json['paidExpenses'] ?? json['paid_expenses'] ?? 0) as int,
      pendingExpenses: (json['pendingExpenses'] ?? json['pending_expenses'] ?? 0) as int,
      overdueExpenses: (json['overdueExpenses'] ?? json['overdue_expenses'] ?? 0) as int,
      topCategories: (categoriesJson as List)
          .map((c) => CategoryBudgetModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      upcomingPayments: (paymentsJson as List)
          .map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
