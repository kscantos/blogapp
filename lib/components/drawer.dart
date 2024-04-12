import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onSignOut;
  final VoidCallback onHomeTap;
  final VoidCallback onMessageTap;

  const MyDrawer({
    Key? key,
    required this.onProfileTap,
    required this.onSignOut,
    required this.onHomeTap,
    required this.onMessageTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: Column(
        children: [
          DrawerHeader(
            child: Icon(
              Icons.favorite,
              color: Colors.white,
              size: 64,
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: Colors.white),
            title: Text('H o m e', style: TextStyle(color: Colors.white)),
            onTap: onHomeTap,
          ),
          ListTile(
            leading: Icon(Icons.person, color: Colors.white),
            title: Text('P r o f i l e', style: TextStyle(color: Colors.white)),
            onTap: onProfileTap,
          ),
          ListTile(
            leading: Icon(Icons.message, color: Colors.white),
            title:
                Text('M e s s a g e s', style: TextStyle(color: Colors.white)),
            onTap: onMessageTap,
          ),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.white),
            title: Text('S i g n O u t', style: TextStyle(color: Colors.white)),
            onTap: onSignOut,
          ),
        ],
      ),
    );
  }
}
