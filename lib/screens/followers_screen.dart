import 'package:flutter/material.dart';
import '../services/api_service.dart';

class FollowersScreen extends StatefulWidget {
  final int sellerId;

  const FollowersScreen({
    super.key,
    required this.sellerId,
  });

  @override
  State<FollowersScreen> createState() =>
      _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  List followers = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadFollowers();
  }

  // ================= LOAD =================
  Future<void> loadFollowers() async {
    try {
      final data =
          await ApiService.getFollowers(widget.sellerId);

      setState(() {
        followers = data;
        loading = false;
      });
    } catch (e) {
      print("ERROR: $e");
      setState(() {
  loading = false;
});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Followers"),
        backgroundColor: Colors.deepPurple,
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : followers.isEmpty
              ? const Center(child: Text("No followers 😢"))
              : ListView.builder(
                  itemCount: followers.length,
                  itemBuilder: (context, i) {
                    final f = followers[i];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: f['image'] != null
                            ? NetworkImage(f['image'])
                            : const AssetImage(
                                    "assets/user.png")
                                as ImageProvider,
                      ),
                      title: Text(f['name'] ?? ""),
                      subtitle:
                          Text("@${f['username'] ?? ''}"),

                      onTap: () {
                        // 👇 لاحقاً: افتح بروفايل المستخدم
                        print("User ID: ${f['id']}");
                      },
                    );
                  },
                ),
    );
  }
}