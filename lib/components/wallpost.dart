import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projectdraft/components/commentbutton.dart';
import 'package:projectdraft/components/deletebtn.dart';

import 'package:projectdraft/components/likebutton.dart';
import 'package:projectdraft/ext/helper.dart';
import 'package:projectdraft/components/comment.dart';

class Wallpost extends StatefulWidget {
  final String message;
  final String currentuser;
  final String time;
  final String postid;
  final List<String> likes;

  const Wallpost({
    Key? key,
    required this.message,
    required this.currentuser,
    required this.postid,
    required this.likes,
    required this.time,
  }) : super(key: key);

  @override
  State<Wallpost> createState() => _WallpostState();
}

class _WallpostState extends State<Wallpost> {
  final currentuser = FirebaseAuth.instance.currentUser!;
  bool isliked = false;

  final _commentTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isliked = widget.likes.contains(currentuser.email);
  }

  void togglelike() {
    setState(() {
      isliked = !isliked;
    });

    DocumentReference postref =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postid);

    if (isliked) {
      postref.update({
        'Likes': FieldValue.arrayUnion([currentuser.email])
      });
    } else {
      postref.update({
        'Likes': FieldValue.arrayRemove([currentuser.email])
      });
    }
  }

  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add comment"),
        content: TextField(
          controller: _commentTextController,
          decoration: InputDecoration(hintText: "Write a comment..."),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _commentTextController.clear();
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              addComment(_commentTextController.text);

              Navigator.pop(context);

              _commentTextController.clear();
            },
            child: Text("Post"),
          ),
        ],
      ),
    );
  }

  void addComment(String commentText) {
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postid)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": currentuser.email,
      "CommentTime": Timestamp.now()
    });
  }

  //delete

  void DeletePost() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Post"),
        content: const Text("Are you sure you want to delete this post?"),
        actions: [
          //cancel

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          //delete frfr

          TextButton(
            onPressed: () async {
              //firestore delete

              final commentDocs = await FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postid)
                  .collection("Comments")
                  .get();

              //delete allcomment  info

              for (var doc in commentDocs.docs) {
                await FirebaseFirestore.instance
                    .collection("User Posts")
                    .doc(widget.postid)
                    .collection("Comments")
                    .doc(doc.id)
                    .delete();
              }

              FirebaseFirestore.instance
                  .collection("User Posts")
                  .doc(widget.postid)
                  .delete()
                  .then((value) => print("Post Deleted"))
                  .catchError(
                      (error) => print("Failed to delete the post: $error"));

              //dismiss

              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //main wall

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.message ?? 'No message available'),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        widget.currentuser,
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      Text(
                        " . ",
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      Text(
                        widget.time,
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ],
              ),

              //deletebtn

              if (widget.currentuser == currentuser.email)
                DeleteButton(onTap: DeletePost)
            ],
          ),

          const SizedBox(width: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Like
              Column(
                children: [
                  LikeButton(
                    isliked: isliked,
                    onTap: togglelike,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.likes.length.toString(),
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(width: 10),

              // Comment
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("User Posts")
                    .doc(widget.postid)
                    .collection("Comments")
                    .orderBy("CommentTime", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return Column(
                    children: [
                      // Button
                      CommentButton(
                        onTap: showCommentDialog,
                      ),

                      const SizedBox(height: 5),

                      // Count
                      Text(
                        snapshot.data!.docs.length.toString(),
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("User Posts")
                .doc(widget.postid)
                .collection("Comments")
                .orderBy("CommentTime", descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: snapshot.data!.docs.map((doc) {
                  final commentData = doc.data() as Map<String, dynamic>;

                  return Comment(
                    text: commentData["CommentText"],
                    currentuser: commentData["CommentedBy"],
                    time: formatDate(commentData["CommentTime"]),
                  );
                }).toList(),
              );
            },
          )
        ],
      ),
    );
  }
}
