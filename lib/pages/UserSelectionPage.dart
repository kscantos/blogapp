import 'package:flutter/material.dart';
import 'package:projectdraft/pages/messages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Messages',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: FutureBuilder<List<String>>(
        future: fetchUserEmailList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text('No users available');
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final userEmail = snapshot.data![index];
                return ChatBubble(
                  username: userEmail,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MessengerPage(
                          receiverUserId: userEmail,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<String>> fetchUserEmailList() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('Users').get();

      final currentUsers = <String>[];

      querySnapshot.docs.forEach((doc) {
        final username = doc['username'] as String?;
        if (username != null) {
          // Process the email
          currentUsers.add(username);
        } else {
          print('Username field does not exist in the document: ${doc.id}');
        }
      });

      print('Usernames: $currentUsers');
      return currentUsers;
    } catch (e, stackTrace) {
      print('Error fetching usernames: $e\n$stackTrace');
      return [];
    }
  }
}

class ChatBubble extends StatelessWidget {
  final String username;
  final VoidCallback onTap;

  ChatBubble({required this.username, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.all(5.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          username,
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
