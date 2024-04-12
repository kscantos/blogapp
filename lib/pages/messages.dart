import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Message {
  final String sender;
  final String receiver;
  final String text;
  final DateTime timestamp;

  Message({
    required this.sender,
    required this.receiver,
    required this.text,
    required this.timestamp,
  });
}

class MessengerPage extends StatefulWidget {
  final String receiverUserId; // Change to user ID

  const MessengerPage({Key? key, required this.receiverUserId})
      : super(key: key);

  @override
  _MessengerPageState createState() => _MessengerPageState();
}

class _MessengerPageState extends State<MessengerPage> {
  final TextEditingController _messageController = TextEditingController();
  late String? currentUserId;
  late String? chatRoomId;
  late ScrollController _scrollController;

  get firstUserId_ => null;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    chatRoomId = generateChatRoomId(currentUserId!, widget.receiverUserId);
    _scrollController = ScrollController();
  }

  Future<void> _sendMessage(String message) async {
    final senderUserId = currentUserId;

    final messageData = {
      'sender': senderUserId,
      'receiver': widget.receiverUserId,
      'text': message,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Use the individual chat room ID
    await FirebaseFirestore.instance
        .collection('Chats')
        .doc(chatRoomId)
        .collection('messages')
        .add(messageData);

    // Scroll to the bottom after sending a message
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);

    _messageController.clear();
  }

  String generateChatRoomId(String userId1, String userId2) {
    // Ensure consistent order of user IDs
    String firstUserId = userId1.compareTo(userId2) < 0 ? userId1 : userId2;
    String secondUserId = userId1.compareTo(userId2) < 0 ? userId2 : userId1;

    // Combine user IDs to create the chat room ID
    return "$firstUserId_$secondUserId";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverUserId),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Chats')
                  .doc(chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp',
                      descending: false) // Ensure descending order
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  print(
                      'No data in the stream. Current chatRoomId: $chatRoomId');
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                print('Data in the stream. Snapshot data: ${snapshot.data}');

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final messages = (snapshot.data?.docs ?? [])
                    .map((QueryDocumentSnapshot doc) {
                  final timestamp = doc['timestamp'] as Timestamp?;
                  return Message(
                    sender: doc['sender'] as String,
                    receiver: doc['receiver'] as String,
                    text: doc['text'] as String,
                    timestamp:
                        timestamp != null ? timestamp.toDate() : DateTime.now(),
                  );
                }).toList();
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isCurrentUser = message.sender == currentUserId;

                    return Align(
                      alignment: isCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.all(8.0),
                        padding: EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isCurrentUser ? Colors.blue : Colors.green,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    _sendMessage(value);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                final message = _messageController.text.trim();
                if (message.isNotEmpty) {
                  _sendMessage(message);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
