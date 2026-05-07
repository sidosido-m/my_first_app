import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'dart:io';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final int receiverId;

  const ChatScreen({super.key, required this.receiverId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
   late IO.Socket socket;
  List messages = [];
  String? token;
  int? myId;
  File? imageFile;

  final controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

 @override
void initState() {
  super.initState();
  init();
}

Future<void> init() async {
  token = await StorageService.getToken();
  myId = await StorageService.getUserId();
  ApiService.markSeen(token!, widget.receiverId);
  await loadChat();
  connectSocket();
}
  void connectSocket() {
  socket = IO.io(
    "https://your-server.onrender.com",
    IO.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .build(),
  );

  socket.connect();

  socket.onConnect((_) {
    socket.emit("online", myId);
  });

socket.on("new-message", (data) {
  setState(() {
    messages.add(data);
  });

  Future.delayed(const Duration(milliseconds: 100), () {
    if (scrollController.hasClients) {
      scrollController.jumpTo(
        scrollController.position.maxScrollExtent,
      );
    }
  });
});
  socket.on("user-status", (data) {
    print(data);
  });
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

  socket.emit("send-message", {
    "senderId": myId,
    "receiverId": widget.receiverId,
    "message": controller.text,
    "type": "text"
  });

  controller.clear();
}

  Future<void> pickImage() async {
  final picked = await ImagePicker().pickImage(
    source: ImageSource.gallery,
  );

  if (picked != null) {
    setState(() {
      imageFile = File(picked.path);
    });
  }
}
Future<void> sendImage() async {
  final picked = await ImagePicker().pickImage(
    source: ImageSource.gallery,
  );

  if (picked == null) return;

  final String url = (await ApiService.uploadImage(File(picked.path)))!;
   if (url == null) return;
  socket.emit("send-message", {
    "senderId": myId,
    "receiverId": widget.receiverId,
    "message": url,
    "type": "image"
  });
}

  Widget buildMessage(m) {
  bool isMe = m['sender_id'] == myId;

  return Column(
    crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
    children: [

      // ===== TIME =====
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          m['created_at'] ?? "",
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ),

      Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [

          // ===== PROFILE IMAGE =====
          if (!isMe)
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(
                m['user_image'] ??
                    "https://i.pravatar.cc/150?img=3",
              ),
            ),

          const SizedBox(width: 8),

          // ===== MESSAGE =====
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isMe ? Colors.deepPurple : Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: m['type'] == 'image'
    ? Image.network(
        m['message'],
        width: 200,
        fit: BoxFit.cover,
      )
    : Text(
        m['message'] ?? "",
        style: TextStyle(
          color: isMe ? Colors.white : Colors.black,
        ),
      ),
          ),
        ],
      ),
    ],
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
              controller: scrollController,
              padding: const EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return buildMessage(messages[index]);
              },
            ),
          ),

          Row(
  children: [

    IconButton(
  icon: const Icon(Icons.image),
  onPressed: sendImage,
),

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