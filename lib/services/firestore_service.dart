import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group_model.dart';
import '../models/expense_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User operations
  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.userId).set(user.toMap());
  }

  Future<UserModel?> getUser(String userId) async {
    DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<UserModel?> getUserByEmail(String email) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return UserModel.fromMap(snapshot.docs.first.data() as Map<String, dynamic>);
    }
    return null;
  }

  Stream<List<UserModel>> getUsersStream(List<String> userIds) {
    if (userIds.isEmpty) {
      return Stream.value([]);
    }
    return _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: userIds)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data()))
            .toList());
  }

  // Group operations
  Future<String> createGroup(GroupModel group) async {
    DocumentReference docRef = await _firestore.collection('groups').add(group.toMap());
    await docRef.update({'groupId': docRef.id});
    return docRef.id;
  }

  Stream<List<GroupModel>> getUserGroups(String userId) {
    return _firestore
        .collection('groups')
        .where('members', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              Map<String, dynamic> data = doc.data();
              data['groupId'] = doc.id;
              return GroupModel.fromMap(data);
            })
            .toList());
  }

  Future<GroupModel?> getGroup(String groupId) async {
    DocumentSnapshot doc = await _firestore.collection('groups').doc(groupId).get();
    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['groupId'] = doc.id;
      return GroupModel.fromMap(data);
    }
    return null;
  }

  Future<void> updateGroup(GroupModel group) async {
    await _firestore.collection('groups').doc(group.groupId).update(group.toMap());
  }

  Future<void> deleteGroup(String groupId) async {
    // Delete all expenses first
    QuerySnapshot expenses = await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('expenses')
        .get();
    
    for (var doc in expenses.docs) {
      await doc.reference.delete();
    }
    
    // Delete group
    await _firestore.collection('groups').doc(groupId).delete();
  }

  Future<void> addMemberToGroup(String groupId, String userId) async {
    DocumentReference groupRef = _firestore.collection('groups').doc(groupId);
    await groupRef.update({
      'members': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> removeMemberFromGroup(String groupId, String userId) async {
    DocumentReference groupRef = _firestore.collection('groups').doc(groupId);
    await groupRef.update({
      'members': FieldValue.arrayRemove([userId]),
    });
  }

  // Expense operations
  Future<String> addExpense(ExpenseModel expense) async {
    DocumentReference docRef = await _firestore
        .collection('groups')
        .doc(expense.groupId)
        .collection('expenses')
        .add(expense.toMap());
    await docRef.update({'expenseId': docRef.id});
    return docRef.id;
  }

  Stream<List<ExpenseModel>> getGroupExpenses(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              Map<String, dynamic> data = doc.data();
              data['expenseId'] = doc.id;
              data['groupId'] = groupId;
              return ExpenseModel.fromMap(data);
            })
            .toList());
  }

  Future<void> deleteExpense(String groupId, String expenseId) async {
    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await _firestore
        .collection('groups')
        .doc(expense.groupId)
        .collection('expenses')
        .doc(expense.expenseId)
        .update(expense.toMap());
  }
}


