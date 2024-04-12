import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projectdraft/components/drawer.dart';
import 'package:projectdraft/components/textfield.dart';
import 'package:projectdraft/components/wallpost.dart';
import 'package:projectdraft/ext/helper.dart';
import 'package:projectdraft/pages/UserSelectionPage.dart';
import 'package:projectdraft/pages/profilepage.dart';

class Message {
  final String sender;
  final String receiver;
  final String message;
  final DateTime date;

  Message({
    required this.sender,
    required this.receiver,
    required this.message,
    required this.date,
  });
}

class HomePage extends StatefulWidget {
  HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentuser = FirebaseAuth.instance.currentUser!;
  final textcont = TextEditingController();

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  void postmessage() {
    if (textcont.text.isNotEmpty) {
      FirebaseFirestore.instance.collection("User Posts").add({
        'UserEmail': currentuser.email,
        'Message': textcont.text,
        'TimeStamp': Timestamp.now(),
        'Likes': [],
      });
    }
    setState(() {
      textcont.clear();
    });
  }

  void gotoprofilepage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Profilepage(),
      ),
    );
  }

  void gotomessagepage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserSelectionPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text(
          "Feed",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true, // Center the title
      ),
      drawer: MyDrawer(
        onProfileTap: gotoprofilepage,
        onSignOut: signUserOut,
        onHomeTap: () {},
        onMessageTap: gotomessagepage,
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Container(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: MyTextField(
                        controller: textcont,
                        hintText: 'What\'s Happening?',
                        obscureText: false,
                      ),
                    ),
                    const SizedBox(height: 10),
                    IconButton(
                      onPressed: postmessage,
                      icon: const Icon(Icons.auto_awesome_outlined),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("User Posts")
                    .orderBy(
                      "TimeStamp",
                      descending: true,
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final post = snapshot.data!.docs[index];
                        return Wallpost(
                          message: post['Message'],
                          currentuser: post['UserEmail'],
                          postid: post.id,
                          likes: List<String>.from(post['Likes'] ?? []),
                          time: formatDate(post['TimeStamp']),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error:${snapshot.error}'),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
            Text("User: " + currentuser.email!),
          ],
        ),
      ),
    );
  }
}
