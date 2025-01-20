import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageToiletsPage extends StatefulWidget {
  @override
  _ManageToiletsPageState createState() => _ManageToiletsPageState();
}

class _ManageToiletsPageState extends State<ManageToiletsPage> {
  final CollectionReference toiletsCollection =
  FirebaseFirestore.instance.collection('toilets');

  void _deleteToilet(String documentId) async {
    try {
      await toiletsCollection.doc(documentId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Toilet deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete toilet: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Toilets'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: toiletsCollection.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final toilets = snapshot.data?.docs ?? [];

          if (toilets.isEmpty) {
            return const Center(child: Text('No toilets available.'));
          }

          return ListView.builder(
            itemCount: toilets.length,
            itemBuilder: (context, index) {
              final doc = toilets[index];
              final data = doc.data() as Map<String, dynamic>;
              final location = data['location'] ?? {};

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(data['name'] ?? 'Unnamed Toilet'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data['amenities'] != null)
                        Text('Amenities: ${data['amenities']}'),
                      if (location['latitude'] != null &&
                          location['longitude'] != null)
                        Text(
                          'Location: (${location['latitude']}, ${location['longitude']})',
                        ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteToilet(doc.id);
                      }
                      // Additional options like edit can be added here
                    },
                    itemBuilder: (context) => [
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
