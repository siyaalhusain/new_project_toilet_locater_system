import 'package:flutter/material.dart';
import 'package:project_x/screen/ManageUser.dart';

import 'AddMaintainerPage.dart';
import 'AddToiletPage.dart';
import 'ManageMaintainersPage.dart';
import 'ManageToiletsPag.dart';

class ProfilePage extends StatelessWidget {
  final String role;

  ProfilePage({required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$role Profile'),
      ),
      body: Center(
        child: _getProfileContent(role, context),
      ),
    );
  }

  // Role-based content for the Profile Page
  Widget _getProfileContent(String role, BuildContext context) {
    switch (role) {
      case 'Admin':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome, Admin!', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageUsersPage()),
                );
              },
              child: const Text('Manage Users'),
            ),
            ElevatedButton(
              onPressed: () {


              },
              child: const Text('View Reports'),
            ),
          ],
        );
      case 'Owner':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome, Owner!', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the Add Toilet Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddToiletPage()),
                );
              },
              child: const Text('Add Toilets'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to the Manage Toilets Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageToiletsPage()),
                );
              },
              child: const Text('Manage Toilets'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to the Add Maintainer Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddMaintainerPage()),
                );
              },
              child: const Text('Add Maintainers'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to the Manage Maintainers Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageMaintainersPage()),
                );
              },
              child: const Text('Manage Maintainers'),
            ),
          ],
        );

      case 'User':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome, User!', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // User-specific functionality
              },
              child: const Text('Find Nearby Toilets'),
            ),
            ElevatedButton(
              onPressed: () {
                // User-specific functionality
              },
              child: const Text('View Reviews'),
            ),
          ],
        );
      case 'Maintainer':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome, Maintainer!', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Maintainer-specific functionality
              },
              child: const Text('View Assigned Tasks'),
            ),
            ElevatedButton(
              onPressed: () {
                // Maintainer-specific functionality
              },
              child: const Text('Update Maintenance Status'),
            ),
          ],
        );
      default:
        return const Text('Role not recognized.', style: TextStyle(fontSize: 24));
    }
  }
}
