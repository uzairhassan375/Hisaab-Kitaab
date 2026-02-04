import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import '../../../providers/group_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/expense_model.dart';

class AddExpenseTab extends StatefulWidget {
  final ExpenseModel? expenseToEdit;

  const AddExpenseTab({super.key, this.expenseToEdit});

  @override
  State<AddExpenseTab> createState() => _AddExpenseTabState();
}

class _AddExpenseTabState extends State<AddExpenseTab> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _customCategoryController = TextEditingController();
  ExpenseCategory _selectedCategory = ExpenseCategory.misc;
  bool _isCustomCategory = false;
  DateTime _selectedDate = DateTime.now();
  Map<String, bool> _selectedUsers = {};

  @override
  void initState() {
    super.initState();
    if (widget.expenseToEdit != null) {
      _titleController.text = widget.expenseToEdit!.title;
      _amountController.text = widget.expenseToEdit!.amount.toString();
      _selectedCategory = widget.expenseToEdit!.category;
      _selectedDate = widget.expenseToEdit!.date;
      if (widget.expenseToEdit!.customCategory != null && widget.expenseToEdit!.customCategory!.isNotEmpty) {
        _customCategoryController.text = widget.expenseToEdit!.customCategory!;
        _isCustomCategory = true;
      }
      for (String userId in widget.expenseToEdit!.involvedUsers) {
        _selectedUsers[userId] = true;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitExpense() async {
    if (_formKey.currentState!.validate()) {
      if (_isCustomCategory && _customCategoryController.text.trim().isEmpty) {
        Fluttertoast.showToast(
          msg: 'Please enter a custom category name',
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.red,
        );
        return;
      }

      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (groupProvider.currentGroup == null ||
          authProvider.currentUser == null) {
        return;
      }

      // Get selected users, if none selected, use all members
      List<String> involvedUsers = _selectedUsers.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      if (involvedUsers.isEmpty) {
        involvedUsers = groupProvider.currentGroup!.members;
      }

      final expense = ExpenseModel(
        expenseId: widget.expenseToEdit?.expenseId ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        category: _isCustomCategory ? ExpenseCategory.misc : _selectedCategory,
        customCategory: _isCustomCategory ? _customCategoryController.text.trim() : null,
        paidBy: authProvider.currentUser!.userId,
        involvedUsers: involvedUsers,
        date: _selectedDate,
        createdAt: widget.expenseToEdit?.createdAt ?? DateTime.now(),
        groupId: groupProvider.currentGroup!.groupId,
      );

      bool success;
      if (widget.expenseToEdit != null) {
        success = await groupProvider.updateExpense(expense);
      } else {
        success = await groupProvider.addExpense(expense);
      }

      if (mounted) {
        if (success) {
          Fluttertoast.showToast(
            msg: widget.expenseToEdit != null
                ? 'Expense updated successfully!'
                : 'Expense added successfully!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
          if (widget.expenseToEdit == null) {
            _formKey.currentState!.reset();
            _titleController.clear();
            _amountController.clear();
            _customCategoryController.clear();
            _selectedCategory = ExpenseCategory.misc;
            _isCustomCategory = false;
            _selectedDate = DateTime.now();
            _selectedUsers.clear();
          }
        } else {
          Fluttertoast.showToast(
            msg: 'Failed to ${widget.expenseToEdit != null ? "update" : "add"} expense. Please try again.',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final groupProvider = Provider.of<GroupProvider>(context);

    if (authProvider.currentUser == null || groupProvider.currentGroup == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final members = groupProvider.members;
    
    // Initialize selected users if not already set
    if (_selectedUsers.isEmpty && members.isNotEmpty) {
      for (var member in members) {
        _selectedUsers[member.userId] = true; // Default: all selected
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.expenseToEdit != null ? 'Edit Expense' : 'Add New Expense',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                hintText: 'e.g., Dinner, Snacks, Petrol',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount (PKR)',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Category selection
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<ExpenseCategory>(
                    value: _isCustomCategory ? ExpenseCategory.misc : _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      prefixIcon: const Icon(Icons.category),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: ExpenseCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text('${category.icon} ${category.displayName}'),
                      );
                    }).toList(),
                    onChanged: _isCustomCategory ? null : (value) {
                      if (value != null) {
                        setState(() {
                          _selectedCategory = value;
                          _isCustomCategory = false;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Checkbox(
                  value: _isCustomCategory,
                  onChanged: (value) {
                    setState(() {
                      _isCustomCategory = value ?? false;
                    });
                  },
                ),
                const Text('Custom'),
              ],
            ),
            if (_isCustomCategory) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _customCategoryController,
                decoration: InputDecoration(
                  labelText: 'Custom Category Name',
                  prefixIcon: const Icon(Icons.edit),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (_isCustomCategory && (value == null || value.isEmpty)) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
              ),
            ],
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _selectDate,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Paid by: ${authProvider.currentUser!.name}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            // Involved Users Section
            Text(
              'Select Users Involved in This Expense',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: members.map((member) {
                  return CheckboxListTile(
                    title: Text(member.name),
                    subtitle: Text(member.email),
                    value: _selectedUsers[member.userId] ?? false,
                    onChanged: (value) {
                      setState(() {
                        _selectedUsers[member.userId] = value ?? false;
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: groupProvider.isLoading ? null : _submitExpense,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: groupProvider.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.expenseToEdit != null ? 'Update Expense' : 'Add Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
