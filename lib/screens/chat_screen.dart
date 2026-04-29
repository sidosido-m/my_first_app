import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ChatScreen extends StatefulWidget {
  final int receiverId;

  const ChatScreen({super.key, required this.receiverId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List messages = [];
  String? token;
  int? myId;

  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadChat();
  }

  Future<void> loadChat() async {
    token = await StorageService.getToken();
    myId = await StorageService.getUserId();

    final data = await ApiService.getMessages(
      token!,
      widget.receiverId,
    );

    setState(() {
      messages = data;
    });
  }

  Future<void> send() async {
    if (controller.text.isEmpty) return;

    await ApiService.sendMessage(
      token!,
      widget.receiverId,
      controller.text,
    );

    controller.clear();
    loadChat();
  }

  Widget buildMessage(m) {
    bool isMe = m['sender_id'] == myId;

    return Align(
      alignment:
          isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? Colors.deepPurple : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          m['message'],
          style: TextStyle(
            color: isMe ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat 💬"),
        backgroundColor: Colors.deepPurple,
      ),

      body: Column(
        children: [

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return buildMessage(messages[index]);
              },
            ),
          ),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: "Type message...",
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: send,
              )
            ],
          )
        ],
      ),
    );
  }
}