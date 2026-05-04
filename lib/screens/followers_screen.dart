import 'package:flutter/material.dart';

class FollowersScreen extends StatelessWidget {
  final List followers;

  const FollowersScreen({super.key, required this.followers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Followers")),
      body: ListView.builder(
        itemCount: followers.length,
        itemBuilder: (context, index) {
          final f = followers[index];

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(f['image'] ?? ""),
            ),
            title: Text(f['name'] ?? ""),
          );
        },
      ),
    );
  }
}