import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../providers/group_provider.dart';
import '../providers/auth_provider.dart';

class CreateGroupDialog extends StatefulWidget {
  const CreateGroupDialog({super.key});

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _groupNameController = TextEditingController();

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);

      if (authProvider.currentUser == null) return;

      final success = await groupProvider.createGroup(
        _groupNameController.text.trim(),
        authProvider.currentUser!.userId,
      );

      if (mounted) {
        if (success) {
          Fluttertoast.showToast(
            msg: 'Group created successfully!',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
          Navigator.of(context).pop();
        } else {
          Fluttertoast.showToast(
            msg: 'Failed to create group. Please try again.',
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
    final groupProvider = Provider.of<GroupProvider>(context);

    return AlertDialog(
      title: const Text('Create New Group'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _groupNameController,
          decoration: InputDecoration(
            labelText: 'Group Name',
            hintText: 'e.g., Friends Trip, Food Party',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a group name';
            }
            return null;
          },
          autofocus: true,
        ),
      ),
      actions: [
        TextButton(
          onPressed: groupProvider.isLoading
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: groupProvider.isLoading ? null : _createGroup,
          child: groupProvider.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }
}


