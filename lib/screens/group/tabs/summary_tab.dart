import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/group_provider.dart';
import '../../../models/balance_model.dart';
import '../../../models/expense_model.dart';
import '../../../utils/currency_formatter.dart';

class SummaryTab extends StatelessWidget {
  const SummaryTab({super.key});

  List<Map<String, dynamic>> _calculateSettlementBreakdown(
    Settlement settlement,
    List<ExpenseModel> expenses,
    List<String> memberIds,
  ) {
    List<Map<String, dynamic>> breakdown = [];

    for (ExpenseModel expense in expenses) {
      List<String> involvedUsers = expense.involvedUsers.isNotEmpty
          ? expense.involvedUsers
          : memberIds;

      if (involvedUsers.isEmpty) {
        involvedUsers = memberIds;
      }

      // Check if both users are involved in this expense
      bool fromUserInvolved = involvedUsers.contains(settlement.fromUserId);
      bool toUserInvolved = involvedUsers.contains(settlement.toUserId);

      if (fromUserInvolved || toUserInvolved) {
        double perHead = involvedUsers.isNotEmpty
            ? expense.amount / involvedUsers.length
            : 0.0;

        double fromUserShare = fromUserInvolved ? perHead : 0.0;
        double toUserShare = toUserInvolved ? perHead : 0.0;

        // If the creditor (toUser) paid for this expense
        if (expense.paidBy == settlement.toUserId && fromUserInvolved) {
          breakdown.add({
            'expense': expense,
            'amount': fromUserShare,
            'reason': 'Your share',
            'perHead': perHead,
            'totalPeople': involvedUsers.length,
          });
        }
        // If the debtor (fromUser) paid but creditor is involved
        else if (expense.paidBy == settlement.fromUserId && toUserInvolved) {
          breakdown.add({
            'expense': expense,
            'amount': -toUserShare,
            'reason': '${settlement.toUserName}\'s share',
            'perHead': perHead,
            'totalPeople': involvedUsers.length,
          });
        }
      }
    }

    return breakdown;
  }

  void _showSettlementDetails(BuildContext context, Settlement settlement) {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final expenses = groupProvider.expenses;
    final members = groupProvider.members;
    final group = groupProvider.currentGroup;

    if (group == null) return;

    final breakdown = _calculateSettlementBreakdown(
      settlement,
      expenses,
      group.members,
    );


    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Settlement Details',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Card
                      Card(
                        color: Colors.blue.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'From:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    settlement.fromUserName,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'To:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    settlement.toUserName,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Amount:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(settlement.amount),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Expense Breakdown:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (breakdown.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No direct expense breakdown available. This settlement is calculated from overall balances.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        ...breakdown.map((item) {
                          final expense = item['expense'] as ExpenseModel;
                          final amount = item['amount'] as double;
                          final perHead = item['perHead'] as double;
                          final totalPeople = item['totalPeople'] as int;
                          final reason = item['reason'] as String;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          expense.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        CurrencyFormatter.format(expense.amount),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Paid by: ${members.firstWhere((m) => m.userId == expense.paidBy, orElse: () => members.first).name}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    'Split among: $totalPeople people',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    'Per person: ${CurrencyFormatter.format(perHead)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const Divider(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        reason,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        CurrencyFormatter.format(amount.abs()),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: amount > 0 ? Colors.red : Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: 16),
                      Card(
                        color: Colors.green.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Settlement:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(settlement.amount),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final balance = groupProvider.groupBalance;

    if (balance == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.summarize, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No expenses yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Add expenses to see balance summary',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Total Expense Card
          Card(
            color: Theme.of(context).colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    'Total Group Expense',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.format(balance.totalGroupExpense),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Member Balances with Per Head
          Text(
            'Member Balances',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ...balance.memberBalances.map((memberBalance) {
            final isPositive = memberBalance.balance > 0.01;
            final isNegative = memberBalance.balance < -0.01;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: isPositive
                      ? Colors.green.withOpacity(0.1)
                      : isNegative
                          ? Colors.red.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                  child: Icon(
                    isPositive
                        ? Icons.arrow_upward
                        : isNegative
                            ? Icons.arrow_downward
                            : Icons.check,
                    color: isPositive
                        ? Colors.green
                        : isNegative
                            ? Colors.red
                            : Colors.grey,
                  ),
                ),
                title: Text(
                  memberBalance.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  isPositive
                      ? 'Receives ${CurrencyFormatter.format(memberBalance.balance)}'
                      : isNegative
                          ? 'Payable ${CurrencyFormatter.format(memberBalance.balance.abs())}'
                          : 'Settled',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isPositive
                        ? Colors.green
                        : isNegative
                            ? Colors.red
                            : Colors.grey,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Paid:'),
                            Text(
                              CurrencyFormatter.format(memberBalance.totalPaid),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Per Head Share:'),
                            Text(
                              CurrencyFormatter.format(memberBalance.perHeadShare),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isPositive ? 'Will Receive:' : isNegative ? 'Payable:' : 'Balance:',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              CurrencyFormatter.format(memberBalance.balance.abs()),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isPositive
                                    ? Colors.green
                                    : isNegative
                                        ? Colors.red
                                        : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          // Settlements
          if (balance.settlements.isNotEmpty) ...[
            Text(
              'Settlements',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap on any settlement to view details',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 12),
            ...balance.settlements.map((settlement) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: Colors.blue.withOpacity(0.1),
                child: ListTile(
                  leading: const Icon(Icons.swap_horiz, color: Colors.blue),
                  title: Text(
                    '${settlement.fromUserName} → ${settlement.toUserName}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Tap to view details',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: Text(
                    CurrencyFormatter.format(settlement.amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () => _showSettlementDetails(context, settlement),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
