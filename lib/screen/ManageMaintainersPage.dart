import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageMaintainersPage extends StatefulWidget {
  @override
  _ManageMaintainersPageState createState() => _ManageMaintainersPageState();
}

class _ManageMaintainersPageState extends State<ManageMaintainersPage> {
  final CollectionReference maintainersCollection =
  FirebaseFirestore.instance.collection('maintainers');

  // Delete a maintainer
  void _deleteMaintainer(String documentId) async {
    try {
      await maintainersCollection.doc(documentId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maintainer deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete maintainer: $e')),
      );
    }
  }

  // Navigate to the edit page (you can implement an edit form if needed)
  void _editMaintainer(String documentId) {
    // Navigate to edit page (you can implement an EditMaintainerPage)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality is not implemented yet.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Maintainers'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: maintainersCollection.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final maintainers = snapshot.data?.docs ?? [];

          if (maintainers.isEmpty) {
            return const Center(child: Text('No maintainers available.'));
          }

          return ListView.builder(
            itemCount: maintainers.length,
            itemBuilder: (context, index) {
              final doc = maintainers[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(data['name'] ?? 'Unnamed Maintainer'),
                  subtitle: Text(data['contact'] ?? 'No contact information'),
                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editMaintainer(doc.id);
                      } else if (value == 'delete') {
                        _deleteMaintainer(doc.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
