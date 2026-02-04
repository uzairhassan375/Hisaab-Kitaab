class MemberBalance {
  final String userId;
  final String userName;
  final double totalPaid;
  final double perHeadShare;
  final double balance;

  MemberBalance({
    required this.userId,
    required this.userName,
    required this.totalPaid,
    required this.perHeadShare,
    required this.balance,
  });
}

class Settlement {
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String toUserName;
  final double amount;

  Settlement({
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.amount,
  });
}

class GroupBalance {
  final double totalGroupExpense;
  final double perHeadShare;
  final List<MemberBalance> memberBalances;
  final List<Settlement> settlements;

  GroupBalance({
    required this.totalGroupExpense,
    required this.perHeadShare,
    required this.memberBalances,
    required this.settlements,
  });
}


