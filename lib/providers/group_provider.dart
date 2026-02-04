import 'package:flutter/foundation.dart';
import '../models/group_model.dart';
import '../models/expense_model.dart';
import '../models/user_model.dart';
import '../models/balance_model.dart';
import '../services/firestore_service.dart';
import '../utils/balance_calculator.dart';

class GroupProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<GroupModel> _groups = [];
  GroupModel? _currentGroup;
  List<ExpenseModel> _expenses = [];
  List<UserModel> _members = [];
  GroupBalance? _groupBalance;
  bool _isLoading = false;

  List<GroupModel> get groups => _groups;
  GroupModel? get currentGroup => _currentGroup;
  List<ExpenseModel> get expenses => _expenses;
  List<UserModel> get members => _members;
  GroupBalance? get groupBalance => _groupBalance;
  bool get isLoading => _isLoading;

  // Load user groups
  void loadUserGroups(String userId) {
    _firestoreService.getUserGroups(userId).listen((groups) {
      _groups = groups;
      notifyListeners();
    });
  }

  // Load group details
  Future<void> loadGroup(String groupId) async {
    _isLoading = true;
    notifyListeners();

    _currentGroup = await _firestoreService.getGroup(groupId);
    
    if (_currentGroup != null) {
      // Load expenses
      _firestoreService.getGroupExpenses(groupId).listen((expenses) {
        _expenses = expenses;
        _calculateBalance();
        notifyListeners();
      });

      // Load members
      _firestoreService.getUsersStream(_currentGroup!.members).listen((users) {
        _members = users;
        _calculateBalance();
        notifyListeners();
      });
    }

    _isLoading = false;
    notifyListeners();
  }

  void _calculateBalance() {
    if (_currentGroup == null || _expenses.isEmpty || _members.isEmpty) {
      _groupBalance = null;
      return;
    }

    Map<String, String> userIdToName = {};
    for (var member in _members) {
      userIdToName[member.userId] = member.name;
    }

    _groupBalance = BalanceCalculator.calculateBalance(
      _expenses,
      _currentGroup!.members,
      userIdToName,
    );
    notifyListeners();
  }

  Future<bool> createGroup(String groupName, String createdBy) async {
    try {
      _isLoading = true;
      notifyListeners();

      GroupModel group = GroupModel(
        groupId: '',
        groupName: groupName,
        createdBy: createdBy,
        members: [createdBy],
        createdAt: DateTime.now(),
      );

      await _firestoreService.createGroup(group);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addMember(String email) async {
    if (_currentGroup == null) return false;

    try {
      UserModel? user = await _firestoreService.getUserByEmail(email);
      if (user != null) {
        await _firestoreService.addMemberToGroup(_currentGroup!.groupId, user.userId);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeMember(String userId) async {
    if (_currentGroup == null) return false;

    try {
      await _firestoreService.removeMemberFromGroup(_currentGroup!.groupId, userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateGroupName(String newName) async {
    if (_currentGroup == null) return false;

    try {
      GroupModel updatedGroup = _currentGroup!.copyWith(groupName: newName);
      await _firestoreService.updateGroup(updatedGroup);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteGroup() async {
    if (_currentGroup == null) return false;

    try {
      await _firestoreService.deleteGroup(_currentGroup!.groupId);
      _currentGroup = null;
      _expenses = [];
      _members = [];
      _groupBalance = null;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addExpense(ExpenseModel expense) async {
    try {
      await _firestoreService.addExpense(expense);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateExpense(ExpenseModel expense) async {
    try {
      await _firestoreService.updateExpense(expense);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteExpense(String expenseId) async {
    if (_currentGroup == null) return false;

    try {
      await _firestoreService.deleteExpense(_currentGroup!.groupId, expenseId);
      return true;
    } catch (e) {
      return false;
    }
  }

  void clearCurrentGroup() {
    _currentGroup = null;
    _expenses = [];
    _members = [];
    _groupBalance = null;
    notifyListeners();
  }
}


