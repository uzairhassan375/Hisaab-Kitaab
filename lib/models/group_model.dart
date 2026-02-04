class GroupModel {
  final String groupId;
  final String groupName;
  final String createdBy;
  final List<String> members;
  final DateTime createdAt;

  GroupModel({
    required this.groupId,
    required this.groupName,
    required this.createdBy,
    required this.members,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'createdBy': createdBy,
      'members': members,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      groupId: map['groupId'] ?? '',
      groupName: map['groupName'] ?? '',
      createdBy: map['createdBy'] ?? '',
      members: List<String>.from(map['members'] ?? []),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  bool isAdmin(String userId) {
    return createdBy == userId;
  }

  GroupModel copyWith({
    String? groupId,
    String? groupName,
    String? createdBy,
    List<String>? members,
    DateTime? createdAt,
  }) {
    return GroupModel(
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      createdBy: createdBy ?? this.createdBy,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


