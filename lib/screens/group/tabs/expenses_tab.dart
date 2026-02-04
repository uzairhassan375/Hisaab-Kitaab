import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../providers/group_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/expense_model.dart';
import 'add_expense_tab.dart';

class ExpensesTab extends StatefulWidget {
  const ExpensesTab({super.key});

  @override
  State<ExpensesTab> createState() => _ExpensesTabState();
}

class _ExpensesTabState extends State<ExpensesTab> {
  final TextEditingController _searchController = TextEditingController();
  ExpenseCategory? _selectedCategory;
  DateTimeRange? _selectedDateRange;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ExpenseModel> _getFilteredExpenses(List<ExpenseModel> expenses) {
    List<ExpenseModel> filtered = expenses;

    // Filter by search
    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where((expense) => expense.title
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    }

    // Filter by category
    if (_selectedCategory != null) {
      filtered = filtered
          .where((expense) => expense.category == _selectedCategory)
          .toList();
    }

    // Filter by date range
    if (_selectedDateRange != null) {
      filtered = filtered.where((expense) {
        return expense.date.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    return filtered;
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _editExpense(ExpenseModel expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Edit Expense'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          body: AddExpenseTab(expenseToEdit: expense),
        ),
      ),
    ).then((_) {
      // Refresh the list when returning from edit
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final expenses = groupProvider.expenses;
    final members = groupProvider.members;

    final filteredExpenses = _getFilteredExpenses(expenses);

    return Column(
      children: [
        // Search and filter bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search expenses...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<ExpenseCategory?>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Categories'),
                        ),
                        ...ExpenseCategory.values.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text('${category.icon} ${category.displayName}'),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectDateRange,
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        _selectedDateRange == null
                            ? 'Date Range'
                            : '${DateFormat('MMM d').format(_selectedDateRange!.start)} - ${DateFormat('MMM d').format(_selectedDateRange!.end)}',
                      ),
                    ),
                  ),
                  if (_selectedDateRange != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _selectedDateRange = null;
                        });
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
        // Expenses list
        Expanded(
          child: filteredExpenses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        expenses.isEmpty ? 'No expenses yet' : 'No expenses match filters',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredExpenses.length,
                  itemBuilder: (context, index) {
                    final expense = filteredExpenses[index];
                    final paidByMember = members.firstWhere(
                      (m) => m.userId == expense.paidBy,
                      orElse: () => members.isNotEmpty ? members.first : members.first,
                    );
                    final isCurrentUser = expense.paidBy == authProvider.currentUser?.userId;
                    
                    // Get involved users names
                    final involvedUserNames = expense.involvedUsers
                        .map((userId) {
                          final member = members.firstWhere(
                            (m) => m.userId == userId,
                            orElse: () => members.isNotEmpty ? members.first : members.first,
                          );
                          return member.name;
                        })
                        .toList();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          child: Text(
                            expense.category.icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        title: Text(
                          expense.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Paid by: ${paidByMember.name}'),
                            if (expense.involvedUsers.isNotEmpty && expense.involvedUsers.length < members.length)
                              Text(
                                'Involved: ${involvedUserNames.join(", ")}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                ),
                              ),
                            Text(
                              'Category: ${expense.displayCategory}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              DateFormat('MMM d, y').format(expense.date),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'PKR ${expense.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            if (isCurrentUser)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    color: Colors.blue,
                                    onPressed: () => _editExpense(expense),
                                    tooltip: 'Edit',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    color: Colors.red,
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Expense'),
                                          content: const Text(
                                            'Are you sure you want to delete this expense?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                              ),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await groupProvider.deleteExpense(expense.expenseId);
                                        if (context.mounted) {
                                          Fluttertoast.showToast(
                                            msg: 'Expense deleted',
                                            toastLength: Toast.LENGTH_SHORT,
                                          );
                                        }
                                      }
                                    },
                                    tooltip: 'Delete',
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
