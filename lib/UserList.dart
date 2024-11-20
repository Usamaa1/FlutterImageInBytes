import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserList extends StatelessWidget {
  const UserList({super.key});

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: users.snapshots(), // Real-time updates
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No users found"));
          }

          final userDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: userDocs.length,
            itemBuilder: (context, index) {
              final data = userDocs[index].data() as Map<String, dynamic>?;

              if (data == null) {
                return const ListTile(title: Text("Invalid user data"));
              }
              List<int> array = data['image']
                  .replaceAll('[', '') // Remove the opening bracket
                  .replaceAll(']', '') // Remove the closing bracket
                  .split(',') // Split by commas
                  .map<int>(
                      (e) => int.parse(e.trim())) // Parse each item as int
                  .toList();

              // Convert to Uint8List
              Uint8List img = Uint8List.fromList(array);

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: MemoryImage(img),
                ),
                title: Text(data['username']?.toString() ?? 'No Username'),
                subtitle: Text(data['city']?.toString() ?? 'No City'),
              );
            },
          );
        },
      ),
    );
  }
}
