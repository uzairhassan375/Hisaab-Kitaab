import '../models/expense_model.dart';
import '../models/balance_model.dart';

class BalanceCalculator {
  static GroupBalance calculateBalance(
    List<ExpenseModel> expenses,
    List<String> memberIds,
    Map<String, String> userIdToName,
  ) {
    // Calculate total group expense
    double totalGroupExpense = expenses.fold(0.0, (sum, expense) => sum + expense.amount);

    // Calculate total paid by each member
    Map<String, double> memberTotalPaid = {};
    Map<String, double> memberTotalOwed = {}; // What each member owes
    
    for (String memberId in memberIds) {
      memberTotalPaid[memberId] = 0.0;
      memberTotalOwed[memberId] = 0.0;
    }

    // Process each expense
    for (ExpenseModel expense in expenses) {
      // Add to paid amount
      memberTotalPaid[expense.paidBy] =
          (memberTotalPaid[expense.paidBy] ?? 0.0) + expense.amount;
      
      // Calculate per-head for this expense (only among involved users)
      List<String> involvedUsers = expense.involvedUsers.isNotEmpty 
          ? expense.involvedUsers 
          : memberIds; // If no involved users specified, split among all
      
      if (involvedUsers.isEmpty) {
        involvedUsers = memberIds;
      }
      
      double perHeadForExpense = involvedUsers.isNotEmpty 
          ? expense.amount / involvedUsers.length 
          : 0.0;
      
      // Add to owed amount for each involved user
      for (String userId in involvedUsers) {
        memberTotalOwed[userId] = (memberTotalOwed[userId] ?? 0.0) + perHeadForExpense;
      }
    }

    // Calculate balance for each member
    List<MemberBalance> memberBalances = memberIds.map((userId) {
      double totalPaid = memberTotalPaid[userId] ?? 0.0;
      double totalOwed = memberTotalOwed[userId] ?? 0.0;
      double balance = totalPaid - totalOwed;
      return MemberBalance(
        userId: userId,
        userName: userIdToName[userId] ?? 'Unknown',
        totalPaid: totalPaid,
        perHeadShare: totalOwed, // Individual per-head share for this member
        balance: balance,
      );
    }).toList();

    // Calculate average per head share (for display purposes)
    double totalOwed = memberTotalOwed.values.fold(0.0, (sum, value) => sum + value);
    double averagePerHead = memberIds.isNotEmpty ? totalOwed / memberIds.length : 0.0;

    // Calculate settlements (who owes who)
    List<Settlement> settlements = _calculateSettlements(memberBalances, userIdToName);

    return GroupBalance(
      totalGroupExpense: totalGroupExpense,
      perHeadShare: averagePerHead, // Average per head share
      memberBalances: memberBalances,
      settlements: settlements,
    );
  }

  static List<Settlement> _calculateSettlements(
    List<MemberBalance> memberBalances,
    Map<String, String> userIdToName,
  ) {
    List<Settlement> settlements = [];

    // Separate creditors (positive balance) and debtors (negative balance)
    List<MemberBalance> creditors = memberBalances
        .where((mb) => mb.balance > 0.01) // Small threshold to avoid floating point issues
        .toList()
      ..sort((a, b) => b.balance.compareTo(a.balance));

    List<MemberBalance> debtors = memberBalances
        .where((mb) => mb.balance < -0.01)
        .toList()
      ..sort((a, b) => a.balance.compareTo(b.balance));

    int creditorIndex = 0;
    int debtorIndex = 0;

    while (creditorIndex < creditors.length && debtorIndex < debtors.length) {
      MemberBalance creditor = creditors[creditorIndex];
      MemberBalance debtor = debtors[debtorIndex];

      double amountToSettle = creditor.balance.abs() < debtor.balance.abs()
          ? creditor.balance
          : debtor.balance.abs();

      if (amountToSettle > 0.01) {
        settlements.add(Settlement(
          fromUserId: debtor.userId,
          fromUserName: userIdToName[debtor.userId] ?? 'Unknown',
          toUserId: creditor.userId,
          toUserName: userIdToName[creditor.userId] ?? 'Unknown',
          amount: amountToSettle,
        ));

        // Update balances
        creditor = MemberBalance(
          userId: creditor.userId,
          userName: creditor.userName,
          totalPaid: creditor.totalPaid,
          perHeadShare: creditor.perHeadShare,
          balance: creditor.balance - amountToSettle,
        );

        debtor = MemberBalance(
          userId: debtor.userId,
          userName: debtor.userName,
          totalPaid: debtor.totalPaid,
          perHeadShare: debtor.perHeadShare,
          balance: debtor.balance + amountToSettle,
        );

        creditors[creditorIndex] = creditor;
        debtors[debtorIndex] = debtor;

        if (creditor.balance < 0.01) {
          creditorIndex++;
        }
        if (debtor.balance > -0.01) {
          debtorIndex++;
        }
      } else {
        break;
      }
    }

    return settlements;
  }
}


