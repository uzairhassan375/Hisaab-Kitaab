enum ExpenseCategory {
  food,
  travel,
  shopping,
  emergency,
  misc,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get displayName {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.travel:
        return 'Travel';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.emergency:
        return 'Emergency';
      case ExpenseCategory.misc:
        return 'Misc';
    }
  }

  String get icon {
    switch (this) {
      case ExpenseCategory.food:
        return '🍔';
      case ExpenseCategory.travel:
        return '✈️';
      case ExpenseCategory.shopping:
        return '🛍️';
      case ExpenseCategory.emergency:
        return '🚨';
      case ExpenseCategory.misc:
        return '📦';
    }
  }
}

class ExpenseModel {
  final String expenseId;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final String? customCategory; // For custom category name
  final String paidBy;
  final List<String> involvedUsers; // Users involved in this expense
  final DateTime date;
  final DateTime createdAt;
  final String groupId;

  ExpenseModel({
    required this.expenseId,
    required this.title,
    required this.amount,
    required this.category,
    this.customCategory,
    required this.paidBy,
    required this.involvedUsers,
    required this.date,
    required this.createdAt,
    required this.groupId,
  });

  Map<String, dynamic> toMap() {
    return {
      'expenseId': expenseId,
      'title': title,
      'amount': amount,
      'category': category.name,
      'customCategory': customCategory,
      'paidBy': paidBy,
      'involvedUsers': involvedUsers,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'groupId': groupId,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      expenseId: map['expenseId'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      category: ExpenseCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => ExpenseCategory.misc,
      ),
      customCategory: map['customCategory'],
      paidBy: map['paidBy'] ?? '',
      involvedUsers: List<String>.from(map['involvedUsers'] ?? []),
      date: map['date'] != null
          ? DateTime.parse(map['date'])
          : DateTime.now(),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      groupId: map['groupId'] ?? '',
    );
  }

  ExpenseModel copyWith({
    String? expenseId,
    String? title,
    double? amount,
    ExpenseCategory? category,
    String? customCategory,
    String? paidBy,
    List<String>? involvedUsers,
    DateTime? date,
    DateTime? createdAt,
    String? groupId,
  }) {
    return ExpenseModel(
      expenseId: expenseId ?? this.expenseId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      customCategory: customCategory ?? this.customCategory,
      paidBy: paidBy ?? this.paidBy,
      involvedUsers: involvedUsers ?? this.involvedUsers,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      groupId: groupId ?? this.groupId,
    );
  }

  String get displayCategory {
    if (category == ExpenseCategory.misc && customCategory != null && customCategory!.isNotEmpty) {
      return customCategory!;
    }
    return category.displayName;
  }
}


