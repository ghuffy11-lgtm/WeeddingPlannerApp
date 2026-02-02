import 'package:equatable/equatable.dart';

/// Budget Item Entity
class BudgetItem extends Equatable {
  final String id;
  final String weddingId;
  final String category;
  final String title;
  final String? description;
  final double estimatedCost;
  final double actualCost;
  final bool isPaid;
  final DateTime? paidDate;
  final String? vendorId;
  final String? vendorName;
  final DateTime createdAt;

  const BudgetItem({
    required this.id,
    required this.weddingId,
    required this.category,
    required this.title,
    this.description,
    this.estimatedCost = 0,
    this.actualCost = 0,
    this.isPaid = false,
    this.paidDate,
    this.vendorId,
    this.vendorName,
    required this.createdAt,
  });

  /// Difference between estimated and actual
  double get difference => estimatedCost - actualCost;

  /// Is over budget?
  bool get isOverBudget => actualCost > estimatedCost;

  @override
  List<Object?> get props => [
        id,
        weddingId,
        category,
        title,
        description,
        estimatedCost,
        actualCost,
        isPaid,
        paidDate,
        vendorId,
        vendorName,
        createdAt,
      ];
}

/// Budget Category Summary
class BudgetCategorySummary extends Equatable {
  final String category;
  final double allocated;
  final double spent;
  final int itemCount;

  const BudgetCategorySummary({
    required this.category,
    required this.allocated,
    required this.spent,
    required this.itemCount,
  });

  double get remaining => allocated - spent;
  double get percentageSpent => allocated > 0 ? (spent / allocated) * 100 : 0;

  @override
  List<Object?> get props => [category, allocated, spent, itemCount];
}
