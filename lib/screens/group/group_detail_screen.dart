import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/group_provider.dart';
import '../../providers/auth_provider.dart';
import 'tabs/expenses_tab.dart';
import 'tabs/add_expense_tab.dart';
import 'tabs/members_tab.dart';
import 'tabs/summary_tab.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GroupProvider>(context, listen: false)
          .loadGroup(widget.groupId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    Provider.of<GroupProvider>(context, listen: false).clearCurrentGroup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final group = groupProvider.currentGroup;

    if (group == null && !groupProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Group')),
        body: const Center(child: Text('Group not found')),
      );
    }

    final isAdmin = group != null &&
        authProvider.currentUser != null &&
        group.isAdmin(authProvider.currentUser!.userId);

    return Scaffold(
      appBar: AppBar(
        title: Text(group?.groupName ?? 'Loading...'),
        actions: group != null && isAdmin
            ? [
                PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'rename',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Rename Group'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete Group', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'rename') {
                        _showRenameDialog(context, group);
                      } else if (value == 'delete') {
                        _showDeleteDialog(context);
                      }
                    },
                  ),
              ]
            : null,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.receipt), text: 'Expenses'),
            Tab(icon: Icon(Icons.add), text: 'Add'),
            Tab(icon: Icon(Icons.people), text: 'Members'),
            Tab(icon: Icon(Icons.summarize), text: 'Summary'),
          ],
        ),
      ),
      body: group == null
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: const [
                ExpensesTab(),
                AddExpenseTab(),
                MembersTab(),
                SummaryTab(),
              ],
            ),
    );
  }

  void _showRenameDialog(BuildContext context, group) {
    final controller = TextEditingController(text: group.groupName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Group'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Group Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final groupProvider =
                  Provider.of<GroupProvider>(context, listen: false);
              await groupProvider.updateGroupName(controller.text.trim());
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: const Text(
          'Are you sure you want to delete this group? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final groupProvider =
                  Provider.of<GroupProvider>(context, listen: false);
              await groupProvider.deleteGroup();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

