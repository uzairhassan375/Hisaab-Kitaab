import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../providers/group_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/add_member_dialog.dart';

class MembersTab extends StatelessWidget {
  const MembersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final group = groupProvider.currentGroup;
    final members = groupProvider.members;

    if (group == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isAdmin = group.isAdmin(authProvider.currentUser?.userId ?? '');

    return Column(
      children: [
        if (isAdmin)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const AddMemberDialog(),
                );
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Invite Member'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        Expanded(
          child: members.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No members yet',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    final isGroupAdmin = group.createdBy == member.userId;
                    final isCurrentUser = member.userId == authProvider.currentUser?.userId;
                    final canRemove = isAdmin &&
                        !isGroupAdmin &&
                        !isCurrentUser &&
                        members.length > 1;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            member.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Text(
                              member.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            if (isGroupAdmin) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Admin',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(member.email),
                        trailing: canRemove
                            ? IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Remove Member'),
                                      content: Text(
                                        'Are you sure you want to remove ${member.name} from this group?',
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
                                          child: const Text('Remove'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    final success =
                                        await groupProvider.removeMember(member.userId);
                                    if (context.mounted) {
                                      if (success) {
                                        Fluttertoast.showToast(
                                          msg: 'Member removed',
                                          toastLength: Toast.LENGTH_SHORT,
                                        );
                                      } else {
                                        Fluttertoast.showToast(
                                          msg: 'Failed to remove member',
                                          toastLength: Toast.LENGTH_SHORT,
                                          backgroundColor: Colors.red,
                                        );
                                      }
                                    }
                                  }
                                },
                              )
                            : null,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}


