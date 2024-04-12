
import 'package:flutter/material.dart';

class Comment extends StatelessWidget {
  final String text;
  final String currentuser;
  final String time;

  const Comment({
    super.key,
    required this.text,
    required this.currentuser,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(text),
        const SizedBox(
          height: 5,
        ),
        Row(
          children: [
            Text(
              currentuser, 
              style: TextStyle(color: Colors.grey[400]),
            ),
            Text(
              " . ", 
              style: TextStyle(color: Colors.grey[400]),
            ),
              Text(time, 
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      ],
      ),
    );
  }
}
