import 'package:flutter/material.dart';

class MyTextbox extends StatelessWidget {
  final String text;
  final String sectionname;
  final void Function()? onPressed;
  const MyTextbox({
    super.key,
    required this.text,
    required this.sectionname,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.only(left: 15, bottom: 15),
        margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  sectionname,
                  style: TextStyle(color: Colors.grey[500]),
                ),
                IconButton(
                  onPressed: onPressed,
                  icon: Icon(Icons.settings),
                  color: Colors.grey[500],
                ),
              ],
            ),

            //text
            Text(text),
          ],
        ));
  }
}
